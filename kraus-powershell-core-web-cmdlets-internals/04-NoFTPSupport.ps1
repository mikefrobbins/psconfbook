$Params = @{
    OutFile = '{0}/1KB.zip' -f $PWD.Path
    Uri = 'ftp://speedtest.tele2.net/1KB.zip'
}
Invoke-WebRequest @Params