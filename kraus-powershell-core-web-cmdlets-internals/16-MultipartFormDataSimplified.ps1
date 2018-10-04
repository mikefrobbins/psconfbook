$ResumePath = 'c:\temp\Text.txt'
'I <3 Web Cmdlets!' | Set-Content -Path $ResumePath
$Form = @{
    FirstName = 'Mark'
    LastName = 'Kraus'
    Resume = Get-Item -Path $ResumePath
}
$Uri = 'https://httpbin.org/post'
Invoke-RestMethod -Uri $Uri -Form $Form -Method POST