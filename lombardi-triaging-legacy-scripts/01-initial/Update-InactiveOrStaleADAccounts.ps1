Param (
  $ScriptPath      = "C:\Automation\AD\Cleanup\",
  $LogDirectory    = "logfiles\",
  $Date            = (Get-Date).ToString("dd-MM-yyyy"),
  $NamedExceptions = (Get-Content $ScriptPath`ADnamedExceptions.txt),
  $Server          = "DC002.fqdn.domain.com"
)

. .\Get-AgedAccounts.ps1
. .\Get-DisabledAccounts.ps1

$AgedAccounts  = $null
$AgedAccounts  = Get-AgedAccounts User 60 21
$AgedAccounts += Get-AgedAccounts Computer 45 14
$AgedAccounts.Count
$DisabledAccounts   = $null
$DisabledAccounts   = Get-DisabledAccounts Computer 183
# $DisabledAccounts += Get-DisabledAccounts User 183
$DisabledAccounts.Count

ForEach ($AgedAccount in $AgedAccounts) {
  If ($NamedExceptions -contains $AgedAccount.DistinguishedName) {
    $Result = "Match found in named exceptions file"
  } Else {
    Disable-ADAccount $AgedAccount.DistinguishedName -Server $Server # -WhatIf
    $Result = $?
  }
  Add-Member -InputObject $AgedAccount -MemberType NoteProperty -Name ScriptDisabled -Value $Result
}
$LogFile = $Date + "disabled accounts.csv"
$AgedAccounts |
  Export-Csv $ScriptPath$LogDirectory$LogFile -NoTypeInformation

ForEach ($DisabledAccount in $DisabledAccounts) {
  If ($NamedExceptions -contains $DisabledAccount.DistinguishedName) {
    $Result = "Match found in named exceptions file"
  } Else {
    Remove-ADObject $DisabledAccount.DistinguishedName -Server $Server -Confirm:$False -Recursive # -WhatIf
    $Result = $?
  }
  Add-Member -InputObject $DisabledAccount -MemberType NoteProperty -Name ScriptDeleted -Value $Result
}
$LogFile = $Date + "-deleted accounts.csv"
$DisabledAccounts |
  Export-Csv $ScriptPath$LogDirectory$LogFile -NoTypeInformation