$Params = @{
    Uri = 'http://httpbin.org/headers'
    headers = @{
        'if-match' = '12345'
    }
}
Invoke-WebRequest @Param