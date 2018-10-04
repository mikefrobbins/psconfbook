$Uri = 'https://api.github.com/repos/powershell/powershell/issues'
Invoke-RestMethod -Uri $Uri -FollowRelLink -MaximumFollowRelLink 2