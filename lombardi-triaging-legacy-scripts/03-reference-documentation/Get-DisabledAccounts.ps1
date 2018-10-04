<#
  .SYNOPSIS
    Return disabled and stale user or computer accounts from AD
  .DESCRIPTION
    Return an array of either user or computer accounts which are both
    disabled and stale from Active Directory. This is used in the script
    for updating inactive or stale AD accounts to determine which stale
    accounts should be deleted.
  .PARAMETER AccountType
    Specify either 'user' to return stale user accounts or 'computer'
    to return stale computer accounts. If you specify neither, the
    script will return $null.
  .PARAMETER LastModifiedThreshold
    The number of days that must have elapsed since the account was
    last modified in order to be considered stale.
  .EXAMPLE
    .\Get-DisabledAccounts.ps1 -AccountType User -LastModifiedThreshold 183

    This will return the list of all user accounts in the domain which
    are disabled and have not been modified in the last 183 days.
  .INPUTS
    None. You cannot pipe input to this function.
  .OUTPUTS
    [System.Object][]

    The script will return either $null or array of objects with the
    following properties:

    -distinguishedName
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
      - The LastModifiedThreshold should default to our organizational
        specifications for stale accounts (60 days)
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
    https://itdocs.domain.com/security/accounts/Standards#stale-accounts
#>
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
