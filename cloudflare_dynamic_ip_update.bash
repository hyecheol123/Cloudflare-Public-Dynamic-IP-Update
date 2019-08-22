#!/usr/bin/env bash

## Author: Hyecheol (Jerry) Jang
## Shell Script that check current public (dynamic) ip address of server,
## and update it to the Cloudflare DNS record after comparing ip address registered to Cloudflare
## basic shell scripting guide https://blog.gaerae.com/2015/01/bash-hello-world.html

## Using dig command (https://en.wikipedia.org/wiki/Dig_(command)) to get current public IP address
currentIP=$(dig -4 TXT +short o-o.myaddr.1.google.com @ns1.google.com)
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
SCRIPT_PATH=$(dirname $(realpath $0))
readResult=""  ## Store configuration
while IFS= read -r line || [[ -n "$line" ]]; do
    readResult+=" "  ## Delimiter: space
    readResult+="$line"
done < $SCRIPT_PATH"/cloudflare_config"  ## use cloudflare_config file
unset IFS
unset SCRIPT_PATH

## After retrieve information from file, cut result string into configuration elements
key=$(echo $(echo $readResult | cut -d' ' -f 1) | cut -d'=' -f 2)
email=$(echo $(echo $readResult | cut -d' ' -f 2) | cut -d'=' -f 2)
zoneID=$(echo $(echo $readResult | cut -d' ' -f 3) | cut -d'=' -f 2)
IFS=',' read -r -a updateTarget <<< "$(echo $(echo $readResult | cut -d' ' -f 4) | cut -d'=' -f 2)"
unset readResult
unset IFS

## Make space for saving record's IP Address, Type, and Name
declare -a recordIP
declare -a recordType
declare -a recordName
declare -a dnsID
declare -a recordProxied
for string in ${updateTarget[@]}; do  ## retrieve record's IP Address and save to recordIP
    content=$(
        curl -s -X GET "https://api.cloudflare.com/client/v4/zones/$zoneID/dns_records?name=${string}" \
            -H "X-Auth-Email: $email" \
            -H "X-Auth-Key: $key" \
            -H "Content-Type: application/json"
    )
    ## Parse JSON  https://stackoverflow.com/questions/42427371/cloudflare-api-cut-json-response
    ## Using jq  https://stedolan.github.io/jq/
    ip=$(echo $content | jq '.result | map(.content) | add' | cut -d'"' -f 2)
    rType=$(echo $content | jq '.result | map(.type) | add' | cut -d'"' -f 2)
    name=$(echo $content | jq '.result | map(.name) | add' | cut -d'"' -f 2)
    id=$(echo $content | jq '.result | map(.id) | add' | cut -d'"' -f 2)
    proxied=$(echo $content | jq '.result | map(.proxied) | add' | cut -d'"' -f 2)
    recordIP=(${recordIP[@]} $ip)
    recordType=(${recordType[@]} $rType)
    recordName=(${recordName[@]} $name)
    dnsID=(${dnsID[@]} $id)
    recordProxied=(${recordProxied[@]} $proxied)
    unset id
    unset rType
    unset name
    unset ip
    unset content
    unset string
    unset proxied
done
unset updateTarget

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
        echo "record IP needs to be updated for "${recordName[count]}
        success=$(
            curl -s -X PUT "https://api.cloudflare.com/client/v4/zones/$zoneID/dns_records/${dnsID[count]}" \
                -H "X-Auth-Email: $email" \
                -H "X-Auth-Key: $key" \
                -H "Content-Type: application/json" \
                --data '{"type":"'"${recordType[count]}"'","name":"'"${recordName[count]}"'","content":"'"$currentIP"'","proxied":'${recordProxied[count]}'}' | \
            jq '.success' | cut -d'"' -f 2
        )
        if [ $success == true ]; then
            echo "Success update record IP of "${recordName[count]}
        else
            echo "Fail to update record IP of "${recordName[count]}"\n""Please Check result!!"
        fi
    else
        echo "record IP does not need to be updated for "${recordName[count]}
    fi
    count=$((${count}+1))
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
