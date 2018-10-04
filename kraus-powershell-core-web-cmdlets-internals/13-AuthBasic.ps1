$Uri = 'https://httpbin.org/hidden-basic-auth/user/passwd'
$Credential = Get-Credential
Invoke-RestMethod -uri $Uri -Authentication Basic -Credential $Credential