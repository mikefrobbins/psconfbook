$Params = @{
    Uri = 'https://i.imgur.com/gXnRf4J.jpg'
    OutFile = 'C:\temp\Rin.jpg'
}
Invoke-WebRequest @Params
# Kill download

$Params = @{
    Uri = 'https://i.imgur.com/gXnRf4J.jpg'
    OutFile = 'C:\temp\Rin.jpg'
}
Invoke-WebRequest @Params -Resume