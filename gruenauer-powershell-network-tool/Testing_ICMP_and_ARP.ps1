$IPAddress=Read-Host -Prompt 'Enter IP Address'
arp.exe -d
$ping=Test-Connection -ComputerName $IPAddress -Count 1 -Quiet
$arp=[boolean](arp.exe -a | Select-String "$IPAddress")
If (-not $ping -and $arp) {
Write-Host "ICMP: failure, ARP: successful. Possible Cause on ${IPAddress}:
Windows Firewall is blocking traffic"
}