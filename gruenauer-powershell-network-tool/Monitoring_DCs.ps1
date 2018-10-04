$dcs=(Get-ADDomainController -Filter *).Name
foreach ($item in $dcs) {
 Try
 {
 Test-Connection $item -Count 1 -ErrorAction Stop | Out-Null
 }
 Catch
 {
 $faulty=Get-ADDomainController $item | Select-Object IPv4Address,Site
 $date=Get-Date
 Send-MailMessage `
 -From Alert@domain.com `
 -To p.gruenauer@domain.com `
 -SmtpServer EX01 `
 -Subject "Site: $faulty.Site | $item is down" `
 -Body "$faulty.IPv4Address could not be reached at $date.`n`n
 If you receive this message again in 15 minutes,
 $item is probably down."
}
}