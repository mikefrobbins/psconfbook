Function Get-AgedAccounts {
  Param (
    [string]$AccountType,
    [int]$AgedAccountThreshold,
    [int]$NewAccountThreshold
  )
  $LastLogonDate = (Get-Date).AddDays(-$AgedAccountThreshold)
  $WhenCreated   = (Get-Date).AddDays(-$NewAccountThreshold)
  If ($AccountType -eq "User") {
    $AgedAccounts = Get-ADUser -Filter {
      (enabled -eq $True -and PasswordNeverExpires -eq $False -and WhenCreated -lt $WhenCreated -and samAccountType -eq "805306368") -and
      ((LastLogonDate -lt $LastLogonDate) -or (LastLogonDate -notlike "*"))
    } -Properties lastLogonDate,whenCreated,passWordLastSet,whenChanged -Server $server |
      Select-Object -Properties distinguishedName,samAccountName,lastLogonDate,whenCreated,passWordLastSet,whenChanged,objectClass
    $AgedAccounts
  } ElseIf ($AccountType -eq "Computer") {
    $AgedAccounts = Get-ADComputer -Filter {
      (enabled -eq $True -and PasswordNeverExpires -eq $False -and WhenCreated -lt $WhenCreated -and samAccountType -eq "805306369") -and
      ((LastLogonDate -lt $LastLogonDate) -or (LastLogonDate -notlike "*"))
    } -Properties lastLogonDate,whenCreated,passWordLastSet,whenChanged -Server $server |
      Select-Object -Property distinguishedName,samAccountName,lastLogonDate,whenCreated,passWordLastSet,whenChanged,objectClass
    $AgedAccounts
  } Else {
    $AgedAccounts
  }
}
