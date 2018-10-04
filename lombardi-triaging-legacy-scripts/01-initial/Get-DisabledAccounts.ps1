Function Get-DisabledAccounts {
  Param (
    [string]$AccountType,
    [int]$LastModifiedThreshold
  )
  $LastModifiedDate = (Get-Date).AddDays(-$LastModifiedThreshold)
  If ($AccountType -eq "User") {
    $DisabledAccounts = Get-ADUser -Filter {
      enabled -eq $False -and samAccountType -eq "805306368" -and whenChanged -lt $LastModifiedDate
    } -properties lastLogonDate,whenCreated,passWordLastSet,whenChanged -server $server |
      Select-Object -Property distinguishedName,samAccountName,lastLogonDate,whenCreated,passWordLastSet,whenChanged,objectClass
    $DisabledAccounts
  } ElseIf ($AccountType -eq "Computer") {
    $DisabledAccounts = Get-ADComputer -Filter {
      enabled -eq $False -and samAccountType -eq "805306369" -and whenChanged -lt $LastModifiedDate
    } -properties lastLogonDate,whenCreated,passWordLastSet,whenChanged -server $server |
      Select-Object -Property distinguishedName,samAccountName,lastLogonDate,whenCreated,passWordLastSet,whenChanged,objectClass
    $DisabledAccounts
  } Else {
    $DisabledAccounts
  }
}
