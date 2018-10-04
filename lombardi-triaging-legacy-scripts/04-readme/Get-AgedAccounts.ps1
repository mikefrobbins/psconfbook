<#
  .SYNOPSIS
    Return inactive user or computer accounts from AD
  .DESCRIPTION
    Return an array of either user or computer accounts which meet the
    following criteria:
    
    - The account is enabled.
    - The account does not have a password which never expires.
    - The account was created more than NewAccountThreshold days ago.
    - The account hasn't been logged into in more than AgedAccountThreshold days.
    
    This is used in the script for updating inactive or stale AD accounts
    to determine which inactive accounts should be disabled.
  .PARAMETER AccountType
    Specify either 'user' to return inactive user accounts or 'computer'
    to return stale computer accounts. If you specify neither, the
    script will return $null.
  .PARAMETER AgedAccountThreshold
    The number of days that must have elapsed since the account was
    last logged into in order to be considered inactive.
  .PARAMETER NewAccountThreshold
    The number of days that an account must be older than in order
    to be eligible for being considered inactive.
  .EXAMPLE
    .\Get-AgedAccounts.ps1 -AccountType User -AgedAccountThreshold 60 -NewAccountThreshold 21

    This will return the list of all user accounts in the domain which
    are enabled, whose password expires, were created more than 21 days
    ago, and have not been logged into in the last sixty days.
  .INPUTS
    None. You cannot pipe input to this function.
  .OUTPUTS
    [System.Object][]

    The script will return either $null or array of objects with the
    following properties:

    - distinguishedName
    - samAccountName
    - lastLogonDate
    - whenCreated
    - passWordLastSet
    - whenChanged
    - objectClass
  .NOTES
    This script is a legacy script that has been running in production
    (with unknown, untracked changes) since Summer 2013. IThe script
    is used to ensure we are meeting our organizational requirements
    for disabling inactive accounts and deleting stale ones.

    It requires some refactoring that will come in later updates.
    Namely, it needs:
    - To cleanup the parameters:
      - The AccountType should be from a validated set
      - You should be able to specify either account type or both, and
        get back the appropriate stale accounts.
    - There should be verbose messaging to explain what is happening
    - We should not allow you to run the function without either account
      type specified, this is not a use case.
    - We should just return the objects directly to the pipeline instead
      of caching them in a variable.
    - The filters and property lists should be extracted for clarity
      and simplification into variables in the begin block.
  .LINK
    https://itdocs.domain.com/ops/scripts/Get-DisabledAccounts
  .LINK
    https://itdocs.domain.com/security/accounts/Standards#inactive-accounts
#>
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
