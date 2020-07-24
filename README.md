# Cloudflare Public Dynamic IP Update
Updating public dynamic IP address to existing cloudflare DNS record  
Only support chaning IP of A records. If you specifically want support for other records type, please open an issue.

## Requirement
Using [curl](https://en.wikipedia.org/wiki/CURL) and [jq](https://stedolan.github.io/jq/) (Need to install **epel-release** prior to install jq in CentOS). <br/>
Check whether jq is installed on your system or not before use this script

Need to customize cloudflare_config file before using this script.  

- **Auth-Key**  
Authorization key for cloudflare API. Able to find it at **My Profile** page. Substitute **[Your_CloudFlare_API_Auth_Key]** with your API key. To edit DNS zone entry, the API key need to have  **DNS:write permission** on the zones you want to update IP address.
This code support either global API key or API Token. If you want to use API token instead of Global API key, you should leave ***Auth-Email*** blank (`Auth-Email=`).   
*Follow this [Instruction](https://support.cloudflare.com/hc/en-us/articles/200167836-Where-do-I-find-my-Cloudflare-API-key-)*
- **Auth-Email**  
Your Cloudflare account login email. Substitute **[Your_CloudFlare_Account_Email]** with yours.  
If you want to use API token instead of Global API key, you should leave ***Auth-Email*** blank (`Auth-Email=`).   
- **Zone-ID**  
You can find zone ID of your DNS Zone on the right sidebar of cloudflare DNS overview page, under API tab. Substitute **[DNS_Zone_ID_of_Your_Domain]** with yours.
- **Update-Target**  
Meaning list of domain address that you want to update linking ip address via this script. List must be separated by single comma(,).
Substitute **[List_Of_Domain_Address_You_Want_To_Update]** with your list.  
*e.g. "google.com,google.com,www.google.com"*


## Tested Environment
If you used this code in other OS and confirm that it works successfully (in all situation), please make an issue with brief test result.<br/>
As soon as I check the issue, I will update the list.

#### Test Condition
- Current IP is same as record's IP, must see the proper message indicating the identity
- Current IP is not same as record's IP, record's IP must be updated and see the proper message indicating the record has been updated
- Has no connection, and see the error message

#### Tested OS List
- Ubuntu 18.04.2 LTS
- Ubuntu 20.04 LTS
- CentOS Linux release 7.6.1810
- CentOS 6.6 (Final)
- Debian GNU/Linux 10 (buster) *arm64*
- ~Raspberry Pi OS 10 (buster) -- Tested on *Raspberry Pi 3 Model B+* by [*Jonathan Engqvist*](https://github.com/Nebour)~ (Tested on Old Version of Code) 


## Other contributors
- [Rp70](https://github.com/Rp70) provides update to support API Token and records with same name. *[PR #5](https://github.com/hyecheol123/Cloudflare-Public-Dynamic-IP-Update/pull/5)*


## Contact
If you have any question or want to report an error (or any other suggestion), simply make an issue with description.
