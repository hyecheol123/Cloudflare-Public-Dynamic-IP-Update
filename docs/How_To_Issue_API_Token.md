# How to Issue API Token
While creating config file, we are using `Zone:Read` permission, and while updating ip of DNS entry, we are using `DNS:edit` permission. Therefore, individual user should issue Cloudflare API Tokens.  

## Important Steps to Issue Cloudflare API Token
*Last Update: Jul. 24. 2020*<br>  

The procedure to get cloudflare's API token is illustrated in the [official document](https://support.cloudflare.com/hc/en-us/articles/200167836-Managing-API-Tokens-and-Keys#12345680).
However, I want to guide you how to make tokens having specific permissions.  

- At **step 5** of official guide, you should click **Create Custom Token - Get Started**.
- On **Permissions Tab**, select proper permissions. See the image below.  
  ![cloudflare_API_permission.png](https://github.com/hyecheol123/Cloudflare-Public-Dynamic-IP-Update/blob/master/docs/images/cloudflare_API_permission.png?raw=true)
  - `Zone:Read` permission means **Zone - Zone - Read**
  - `DNS:Edit` permission means **Zone - DNS - Edit**