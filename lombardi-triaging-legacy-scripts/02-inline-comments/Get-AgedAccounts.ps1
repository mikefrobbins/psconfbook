
Function Get-AgedAccounts {
  Param (
    [string]$AccountType,
    [int]$AgedAccountThreshold,
    [int]$NewAccountThreshold
  )
  # Here we retrieve the date for `AgedAccountThreshold` days ago.
  # Any account whose last logon was before this date is considered inactive.
  $LastLogonDate = (Get-Date).AddDays(-$AgedAccountThreshold)
  # Here we retrieve the date for `NewAccountThreshold` days ago.
  # Any account which was created before this date is eligible for being marked inactive.
  $WhenCreated   = (Get-Date).AddDays(-$NewAccountThreshold)
  If ($AccountType -eq "User") {
    # If the account type is specified as user, we need to filter AD to only return user accounts.
    # We also filter to only return accounts which:
    # - are enabled,
    # - whose password expires,
    # - were created before the new account threshold days ago,
    # - and which have not logged in since the aged account threshold days ago.
    # We then return the results to the pipeline.
    $AgedAccounts = Get-ADUser -Filter {
      (enabled -eq $True -and PasswordNeverExpires -eq $False -and WhenCreated -lt $WhenCreated -and samAccountType -eq "805306368") -and
      ((LastLogonDate -lt $LastLogonDate) -or (LastLogonDate -notlike "*"))
    } -Properties lastLogonDate,whenCreated,passWordLastSet,whenChanged -Server $server |
      Select-Object -Properties distinguishedName,samAccountName,lastLogonDate,whenCreated,passWordLastSet,whenChanged,objectClass
    $AgedAccounts
  } ElseIf ($AccountType -eq "Computer") {
    # If the account type is specified as computer, we need to filter AD to only return computer accounts.
    # We also filter to only return accounts which:
    # - are enabled,
    # - whose password expires,
    # - were created before the new account threshold days ago,
    # - and which have not been logged into since the aged account threshold days ago.
    # We then return the results to the pipeline.
    $AgedAccounts = Get-ADComputer -Filter {
      (enabled -eq $True -and PasswordNeverExpires -eq $False -and WhenCreated -lt $WhenCreated -and samAccountType -eq "805306369") -and
      ((LastLogonDate -lt $LastLogonDate) -or (LastLogonDate -notlike "*"))
    } -Properties lastLogonDate,whenCreated,passWordLastSet,whenChanged -Server $server |
      Select-Object -Property distinguishedName,samAccountName,lastLogonDate,whenCreated,passWordLastSet,whenChanged,objectClass
    $AgedAccounts
  } Else {
    # If neither account type was specified, return $null
    $AgedAccounts
  }
}
