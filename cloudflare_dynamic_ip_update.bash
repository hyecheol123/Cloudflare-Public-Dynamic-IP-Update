#!/usr/bin/env bash

## Author: Hyecheol (Jerry) Jang
## Shell Script that check current public (dynamic) ip address of server,
## and update it to the Cloudflare DNS record after comparing ip address registered to Cloudflare
## basic shell scripting guide https://blog.gaerae.com/2015/01/bash-hello-world.html

## Using dig command (https://en.wikipedia.org/wiki/Dig_(command)) to get current public IP address
currentIP=$(dig +short myip.opendns.com @resolver1.opendns.com)
if [ $? == 0 ] && [ ${currentIP} ]; then  ## when dig command run without error,
    ## Making substring, only retrieving ip address of this server
    ## https://stackabuse.com/substrings-in-bash/
    currentIP=$(echo $currentIP | cut -d'"' -f 2)
    echo "current public IP address is "$currentIP
else  ## error happens,
    echo "Check your internet connection, or google DNS server maybe interruptted"
    exit
fi


## Use Cloudflare API to retrieve recordIP
## https://api.cloudflare.com/
## Read configuration from separated cloudflare_config file (need to locate in the same directory)
## https://stackoverflow.com/questions/10929453/read-a-file-line-by-line-assigning-the-value-to-a-variable
## https://stackoverflow.com/questions/10586153/split-string-into-an-array-in-bash
SCRIPT_PATH=$(cd $(dirname $0) && pwd)
while IFS= read -r line || [[ -n "$line" ]]; do
	case "$line" in
		Auth-Key=*)
			key=${line/Auth-Key=/}
		;;
		Auth-Email=*)
			email=${line/Auth-Email=/}
		;;
		Zone-ID=*)
			zoneID=${line/Zone-ID=/}
		;;
		Update-Target=*)
			updateTarget=${line/Update-Target=/}
		;;
		Record-Type=*)
			type=${line/Record-Type=/}
		;;
	esac
done < $SCRIPT_PATH"/cloudflare_config"  ## use cloudflare_config file
unset IFS
unset SCRIPT_PATH

## If Auth-Email is empty, use Token Authentication.
if [ "$email" = '' ]; then
    curlHeader="Authorization: Bearer $key"
else
    curlHeader="X-Auth-Email: $email\nX-Auth-Key: $key"
fi
#### Commonly, the header includes Content-Type field
curlHeader="$curlHeader\nContent-Type: application/json"


## Make space for saving record's IP Address, Type, and Name
declare -a recordIP
declare -a recordName
declare -a dnsID
declare -a recordProxied


updateTargetIndex=0
count=0
while [ $updateTargetIndex -lt ${#updateTarget[@]} ]; do
    ## Extract name and type of DNS record from the configuration file
    name=${updateTarget[updateTargetIndex]}
    type=${recordType[updateTargetIndex]}
    
    ## run the commend to get other DNS record properties
    content=$(
        printf '%b' "$curlHeader" |
        curl -s -X GET "https://api.cloudflare.com/client/v4/zones/$zoneID/dns_records?name=${name}&type=${type}" \
             -H @-
    )

    ## Parse JSON  https://stackoverflow.com/questions/42427371/cloudflare-api-cut-json-response
    ## Using jq  https://stedolan.github.io/jq/
    if [ $(echo $content | jq '.success') = "true" ]; then
        ip=$(echo $content | jq '.result | map(.content) | add' | cut -d'"' -f 2)
        name=$(echo $content | jq '.result | map(.name) | add' | cut -d'"' -f 2)
        id=$(echo $content | jq '.result | map(.id) | add' | cut -d'"' -f 2)
        proxied=$(echo $content | jq '.result | map(.proxied) | add' | cut -d'"' -f 2)
        recordIP=(${recordIP[count]} $ip)
        recordName=(${recordName[count]} $name)
        dnsID=(${dnsID[count]} $id)
        recordProxied=(${recordProxied[count]} $proxied)
        count=$((${count}+1))

        unset id
        unset name
        unset ip
        unset content
        unset proxied

    else ## Error occurred while getting DNS record information
        echo "Error occurred while retrieving current information for "${name}" with type "${type}
    fi

    updateTargetIndex=$((${updateTargetIndex}+1))
done
echo ${count}" out of "${#updateTarget[@]}" DNS records successfully retrieved"
echo ""

unset updateTarget
unset count
unset updateTargetIndex


## Compare currentIP and recordIP
declare -a needUpdate  ## Array to store whether each record needs to be updated or not
for string in ${recordIP[@]}; do
    if [ ${string} == ${currentIP} ]; then
        needUpdate=(${needUpdate[@]} 'False')
    else
        needUpdate=(${needUpdate[@]} 'True')
    fi
    unset string
done
unset recordIP  ## X Need recordIP Anymore


## Update record if needed
count=0
while [ $count -lt ${#needUpdate[@]} ]; do
    if [ ${needUpdate[count]} == 'True' ]; then
        echo "record IP needs to be updated for "${recordName[count]}" with recordType "${recordType[count]}
        content=$(
            printf '%b' "$curlHeader" |
            curl -s -X PUT "https://api.cloudflare.com/client/v4/zones/$zoneID/dns_records/${dnsID[count]}" \
                 --data '{"type":"'"${recordType[count]}"'","name":"'"${recordName[count]}"'","content":"'"$currentIP"'","proxied":'${recordProxied[count]}'}' \
                 -H @-
        )

        if [ $(echo $content | jq '.success') = "true" ]; then
            echo "Success update record IP of "${recordName[count]}" with recordType "${recordType[count]}
        else
            echo "Fail to update record IP of "${recordName[count]}" with recordType "${recordType[count]}
            echo "Please Check result!!"
        fi
    else
        echo "record IP does not need to be updated for "${recordName[count]}" with recordType "${recordType[count]}
    fi
    echo ""
    count=$((${count}+1))

    unset content
done

unset count
unset currentIP
unset key
unset email
unset zoneID
unset recordType
unset recordName
unset dnsID
unset recordProxied
unset needUpdate
