try {
    Invoke-WebRequest -Uri 'https://httpbin.org/status/418'
}
catch {
    $Response = $_.Exception.Response
    $Exception = $_.Exception
    $ErrorRecord = $_
    if ($PSVersionTable.PSEdition -eq 'Core') {
        $ErrorRecord.ErrorDetails.ToString()
    }
    else {
        $Stream = $Response.GetResponseStream()
        $Stream.Position = 0
        $Reader = [System.IO.StreamReader]::new($Stream)
        $Reader.ReadToEnd()
    }
}