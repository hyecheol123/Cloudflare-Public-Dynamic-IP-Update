# Cloudflare Public Dynamic IP Update
Updating public dynamic IP address to existing cloudflare DNS record  
Only support chaning IP of A records. If you specifically want support for other records type, please open an issue.

## Requirement
Using [curl](https://en.wikipedia.org/wiki/CURL) and [jq](https://stedolan.github.io/jq/) (Need to install **epel-release** prior to install jq in CentOS).  
Check whether jq is installed on your system or not before use this script.<br>  

**Need to run `configure.bash` once before execute `cloudflare_dynamic_ip_update.bash`.**  
While running `configure.bash`, you are prompt to enter API token. The API token should have `Zone:Read` and `DNS:Edit` permission. If you need detailed guideline how to get API Token, please check [this document](https://github.com/hyecheol123/Cloudflare-Public-Dynamic-IP-Update/blob/feature-%237/docs/How_To_Issue_API_Token.md).


## Tested Environment
If you used this code in other OS and confirm that it works successfully (in all situation), please make an issue with brief test result.<br/>
As soon as I check the issue, I will update the list.

#### Test Condition
- Current IP is same as record's IP, must see the proper message indicating the identity
- Current IP is not same as record's IP, record's IP must be updated and see the proper message indicating the record has been updated
- Has no connection, and see the error message

#### Tested OS List
As the script has been modified a lot, the previous tested version list has been removed. You are welcome to create an issue with test results.
- Ubuntu 20.04 LTS
- Debian GNU/Linux 10 (buster) *arm64*


## Other contributors
- [Rp70](https://github.com/Rp70) provides update to support API Token and records with same name. *[PR #5](https://github.com/hyecheol123/Cloudflare-Public-Dynamic-IP-Update/pull/5)*


## Contact
If you have any question or want to report an error (or any other suggestion), simply make an issue with description.
