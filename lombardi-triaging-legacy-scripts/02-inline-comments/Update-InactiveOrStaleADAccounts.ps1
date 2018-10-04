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
