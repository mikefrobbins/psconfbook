$MultipartContent = [System.Net.Http.MultipartFormDataContent]::new()
$StringHeader = [System.Net.Http.Headers.ContentDispositionHeaderValue]::new(
    "form-data"
)
$StringHeader.Name = "TestString"
$StringContent = [System.Net.Http.StringContent]::new("Test Value")
$StringContent.Headers.ContentDisposition = $StringHeader
$MultipartContent.Add($StringContent)
$Uri = 'https://httpbin.org/post'
Invoke-WebRequest -Uri $Uri -Body $MultipartContent -Method 'POST'