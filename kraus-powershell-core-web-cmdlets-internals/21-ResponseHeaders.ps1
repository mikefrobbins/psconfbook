$Uri = 'https://httpbin.org/get'
Invoke-RestMethod -Uri $Uri -ResponseHeadersVariable Headers
$Headers