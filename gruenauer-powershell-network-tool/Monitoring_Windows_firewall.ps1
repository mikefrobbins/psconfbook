$fresult=@()
$servers=(Get-ADComputer -Filter * -Properties Operatingsystem |
          Where-Object {$_.operatingsystem -like "*server*"}).Name

foreach ($s in $servers) {

        $check=Invoke-Command -ComputerName $s `
        -ScriptBlock {Get-NetFirewallProfile -Profile Domain |
        Select-Object -ExpandProperty Enabled} `
        -ErrorAction SilentlyContinue

        $fresult+=New-Object -TypeName PSCustomObject `
        -Property ([ordered]@{
           'Server'= $check.PSComputerName
           'FirewallEnabled' = $check.Value

        })

        }

Write-Output $fresult