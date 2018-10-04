<#
  .SYNOPSIS
    Disables inactive accounts and deletes stale ones.
  .DESCRIPTION
    This Active directory cleanup script disables inactive user and
    computer accounts as defined by our organizational requirements.
    It also deletes stale computer accounts and can be modified to
    delete stale user accounts, both as defined by our organizational
    requirements. It writes the results of all actions into date-
    stamped CSV files on the machine it is run from.

    Note that you can modify the script to show you what it _would_
    do if run, but you will need to remove the commented `-WhatIf`
    parameters from Disable-ADAccount and Remove-ADObject both.
  .PARAMETER ScriptPath
    The path to the folder where the named exception list is kept and
    where the output should be logged. Must be the full path. It is
    strongly recommend you do _not_ override this without good reason.
    Make sure to include a trailing `\` - failure to do so will cause
    strings to build incorrectly.
  .PARAMETER LogDirectory
    The folder beneath the ScriptPath in which the log output is
    written; make sure to include a trailing `\` - failure to do so
    will cause strings to build incorrectly.
  .PARAMETER Date
    The date the script is run on, defaults to today as a date string;
    if run on February 1, 2018 it would default to `01-02-2018`. This
    is functionally a constant and need not be changed.
  .PARAMETER NamedExceptions
    The list of computer and user accounts which are excepted from
    the disable/delete policies, listed by distinguished name. By
    default this points to `ADNamedExceptions.txt` in the ScriptPath.
    If you DO decide to override this, be aware that any missing
    exceptions may be disabled or deleted! Also, note that you must
    provide a list of distinguished names, not the path to another
    exception file!
  .PARAMETER Server
    The Active Directory Domain Services instance to point the queries,
    disable, and remove calls against. By default points to
    `DC002.fqdn.domain.com`. If that DC is down you may want to point
    the script at another.
  .INPUTS
    None. You cannot pipe input to this function.
  .OUTPUTS
    System.Int32, System.String

    The script will first return two integers - these represent the
    number of inactive accounts to disable and the number of stale
    accounts to delete, respectively.

    It will then return two paths to CSV files; these are the log
    files containing information about the accounts that the script
    attempted to disable/delete respectively. The CSV files will contain
    information about the accounts themselves as well as a property,
    `ScriptDisabled` or `ScriptDeleted` which will return `true` if
    the intended action did not error and `false` if it did. If the
    account was not acted on because it was found in an exception
    list, this property will instead be a string with the message
    "Match found in named exceptions file".
  .EXAMPLE
    .\Update-InactiveOrStaleADAccounts.ps1

    This executes the script using all of the default parameters.
    It will return two integers representing the number of accounts
    to be disabled/deleted as well as the paths to CSV files
    representing the logs of the script's actions.
  .EXAMPLE
    .\Update-InactiveOrStaleADAccounts.ps1 -Server DC003.fqdn.other-domain.com

    This executes the script but targets a different domain controller
    in another domain. It will otherwise behave exactly the same.

    WARNING: If it is not run from the same domain it is targeting
    the script will fail; It does not include any method to authenticate
    against an alternate domain at this time.
  .EXAMPLE
    $Exceptions = 'CN=Jane Doe,OU=Sales,DC=Domain,DC=COM'
    .\Update-InactiveOrStaleADAccounts.ps1 -NamedExceptions $Exceptions

    This executes the script but passes an alternative exception list.
    In this case, **only** Jane Doe will be excepted from the attempts
    to disable inactive accounts and delete stale accounts! If you want
    to _add_ a name to the exception list you need to update the text
    file or otherwise pass the full list of folks to except as an array
    of strings to this parameter! THIS IS VERY RISKY!
  .NOTES
    This script is a legacy script that has been running in production
    (with unknown, untracked changes) since Summer 2013. IThe script
    is used to ensure we are meeting our organizational requirements
    for disabling inactive accounts and deleting stale ones.

    It requires some refactoring that will come in later updates.
    Namely, it needs:
    - To handle `WhatIf` runs without requiring editing the script.
    - To cleanup the parameters:
      - NamedExceptions should be handled better
      - Several parameters need to be removed or placed as constants
      - Expected types should be specified for each parameter
      - The script should take pipeline input for the exception list
      - Users should be able to pass a credential for AD commands
    - The output for the number of accounts to disable/delete should
      be sensible verbose messages
    - The messaging for the log output should be cleaned up
      - The logs right now may not actually verify if an account was
        acted on or not - at best they're ambiguous and optimistic

    As these problems are resolved they'll be removed from this list.
  .LINK
    https://itdocs.domain.com/ops/scripts/Update-InactiveOrStaleADAccounts
  .LINK
    https://itdocs.domain.com/security/accounts/Standards#inactive-accounts
  .LINK
    https://itdocs.domain.com/security/accounts/Standards#stale-accounts
#>
Param (
  $ScriptPath      = "C:\Automation\AD\Cleanup\",
  $LogDirectory    = "logfiles\",
  $Date            = (Get-Date).ToString("dd-MM-yyyy"),
  $NamedExceptions = (Get-Content $ScriptPath`ADnamedExceptions.txt),
  $Server          = "DC002.fqdn.domain.com"
)

<#
  Here we dot-source two scripts which include custom functions to
  retrieve accounts from Active Directory; Get-AgedAccounts retrieves
  accounts which have been inactive for more than X days & are older
  than Y days. Get-DisabledAccounts retreives accounts which have been
  disabled for more than X days. Both functions can retrieve computer
  objects _or_ user objects. This logic is extracted away for re-use
  elsewhere.
#>
. .\Get-AgedAccounts.ps1
. .\Get-DisabledAccounts.ps1

# Retrieve the user/computer accounts to be disabled.
# These queries are hardcoded per our organizational standard.
$AgedAccounts  = $null
$AgedAccounts  = Get-AgedAccounts -AccountType User -AgedAccountThreshold 60 -NewAccountThreshold 21
$AgedAccounts += Get-AgedAccounts -AccountType Computer -AgedAccountThreshold 45 -NewAccountThreshold 14
# This line displays the number of accounts to be disabled and can
# probably be removed in a future commit.
$AgedAccounts.Count
# Retrieve the disabled computer accounts to be deleted.
# This query is hardcoded per our organizational standard.
$DisabledAccounts    = $null
$DisabledAccounts    = Get-DisabledAccounts -AccountType Computer -LastModifiedThreshold 183
# Uncomment the following line to also delete disabled user accounts.
# WARNING: Doing so is not easy to recover from, make sure you're following SOP!
# $DisabledAccounts += Get-DisabledAccounts -AccountType User -LastModifiedThreshold 183
# This line displays the number of accounts to be deleted and can
# probably be removed in a future commit.
$DisabledAccounts.Count

ForEach ($AgedAccount in $AgedAccounts) {
  If ($NamedExceptions -contains $AgedAccount.DistinguishedName) {
    # Skip the disable call if the account's distinguished name is
    # in an exception list; This makes the result a string instead
    # of a boolean, complicating post-hoc queries. This may be
    # addressed in a future commit.
    $Result = "Match found in named exceptions file"
  } Else {
    # You must remember to uncomment the whatif param to verify which
    # accounts WILL BE DISABLED. This should be handled at a higher
    # level for the script, not here. This should be addressed in a
    # future commit.
    Disable-ADAccount $AgedAccount.DistinguishedName -Server $Server # -WhatIf
    # Note that this stores the result as whether or not Disable-ADAccount
    # ran without error. It does not _necessarily_ ensure the account
    # was disabled! This should be addressed in a future commit.
    $Result = $?
  }
  Add-Member -InputObject $AgedAccount -MemberType NoteProperty -Name ScriptDisabled -Value $Result
}
$LogFile = $Date  + "disabled accounts.csv"
# We write the results of the disable attempts to a date-stamped
# logfile CSV for later review.
$AgedAccounts |
  Export-Csv $ScriptPath$LogDirectory$LogFile -NoTypeInformation

  ForEach ($DisabledAccount in $DisabledAccounts) {
    If ($NamedExceptions -contains $DisabledAccount.DistinguishedName) {
        # Skip the delete call if the account's distinguished name
        # is in an exception list; This makes the result a string
        # instead of a boolean, complicating post-hoc queries. This
        # may be addressed in a future commit.
        $Result = "Match found in named exceptions file"
    } Else {
        # You must remember to uncomment the whatif param to verify
        # which accounts WILL BE DELETED. This should be handled at
        # a higher level for the script, not here. This should be
        # addressed in a future commit.
        Remove-ADObject $DisabledAccount.DistinguishedName -Server $Server -Confirm:$False -Recursive # -WhatIf
        # Note that this stores the result as whether or not Disable-ADAccount
        # ran without error. It does not _necessarily_ ensure the account
        # was disabled! This should be addressed in a future commit.
        $Result = $?
    }
    Add-Member -InputObject $DisabledAccount -MemberType NoteProperty -Name ScriptDeleted -Value $Result
}
$LogFile = $Date  + "-deleted accounts.csv"
# We write the results of the removal attempts to a date-stamped
# logfile CSV for later review.
$DisabledAccounts |
  Export-Csv $ScriptPath$LogDirectory$LogFile -NoTypeInformation
