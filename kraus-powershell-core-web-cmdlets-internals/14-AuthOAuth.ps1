$uri = 'https://httpbin.org/headers'
$Token = Read-Host -AsSecureString -Prompt "Enter OAuth Token"
Invoke-RestMethod -uri $uri -Authentication OAuth -Token $Token