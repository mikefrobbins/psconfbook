try {
    Invoke-WebRequest -Uri 'https://httpbin.org/status/418'
}
catch {
    $_.Exception.Response.GetType().FullName
}