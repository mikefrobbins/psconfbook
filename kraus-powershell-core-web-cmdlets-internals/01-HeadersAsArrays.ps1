$Uri = 'https://httpbin.org/response-headers?X-Header=Value1&X-Header=Value2'
$Result = Invoke-WebRequest -Uri $Uri
$Result.Headers.'X-Header'
$Result.Headers.'X-Header'.Count