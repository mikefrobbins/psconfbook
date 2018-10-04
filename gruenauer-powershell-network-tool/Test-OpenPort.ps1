function Test-OpenPort {
[CmdletBinding()]
param
(
    [Parameter(Position=0)]
    $Target='localhost',
    [Parameter(Mandatory=$true, Position=1,
    Helpmessage = 'Enter Port Numbers.
    Separate them by comma.')]
    $Port
)

$result=@()
foreach ($i in $Target)
    {
        foreach ($p in $Port)
            {
             $a=Test-NetConnection -ComputerName $i -Port $p `
             -WarningAction SilentlyContinue
             $result+=New-Object -TypeName PSObject `
             -Property ([ordered]@{
                         'Target'=$a.ComputerName;
                         'RemoteAddress'=$a.RemoteAddress;
                         'Port'=$a.RemotePort;
                         'Status'=$a.tcpTestSucceeded
                        })
            }
    }
Write-Output $result
}