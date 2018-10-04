Function Get-DisabledAccounts {
  Param (
    [string]$AccountType,
    [int]$LastModifiedThreshold
  )
  # Here we retrieve the date for `LastModifiedThreshold` days ago.
  # Any account which hasn't been modified since this date is considered stale.
  $LastModifiedDate = (Get-Date).AddDays(-$LastModifiedThreshold)
  If ($AccountType -eq "User") {
    # If the account type is specified as user, we need to filter AD to only return user accounts.
    # We also filter to only return accounts which are disabled and which haven't been modified since the last modified threshold.
    # We then return the results to the pipeline.
    $DisabledAccounts = Get-ADUser -Filter {
      enabled -eq $False -and samAccountType -eq "805306368" -and whenChanged -lt $LastModifiedDate
    } -properties lastLogonDate,whenCreated,passWordLastSet,whenChanged -server $server |
      Select-Object -Property distinguishedName,samAccountName,lastLogonDate,whenCreated,passWordLastSet,whenChanged,objectClass
    $DisabledAccounts
  } ElseIf ($AccountType -eq "Computer") {
    # If the account type is specified as computer, we need to filter AD to only return computer accounts.
    # We also filter to only return accounts which are disabled and which haven't been modified since the last modified threshold.
    # We then return the results to the pipeline.
    $DisabledAccounts = Get-ADComputer -Filter {
      enabled -eq $False -and samAccountType -eq "805306369" -and whenChanged -lt $LastModifiedDate
    } -properties lastLogonDate,whenCreated,passWordLastSet,whenChanged -server $server |
      Select-Object -Property distinguishedName,samAccountName,lastLogonDate,whenCreated,passWordLastSet,whenChanged,objectClass
    $DisabledAccounts
  } Else {
    # If neither account type was specified, return $null
    $DisabledAccounts
  }
}
