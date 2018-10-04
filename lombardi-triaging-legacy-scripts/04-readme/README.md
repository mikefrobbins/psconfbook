# Update-InactiveOrStaleADAccounts

This Active directory cleanup script disables inactive user and computer accounts as defined by our organizational requirements.
It also deletes stale computer accounts and can be modified to delete stale user accounts, both as defined by our organizational requirements.
It writes the results of all actions into date-stamped CSV files on the machine it is run from.

## Running the Script

Running the script must be done from inside a PowerShell prompt on a machine with the script downloaded locally.
The account running the script **must** have permissions in Active Directory to query, disable, and delete accounts.
Navigate to the folder containing the script, open a powershell prompt in that folder, and then type the following before hitting enter:

```powershell
.\Update-InactiveOrStaleADAccounts.ps1
```

This executes the script using all of the default parameters.
It will return two integers representing the number of accounts to be disabled/deleted as well as the paths to CSV files representing the logs of the script's actions.
For example, if run on November 5, 2016, the output might look something like this:

```
4
9
C:\Automation\AD\Cleanup\logfiles\11-05-2016-disabled accounts.csv
C:\Automation\AD\Cleanup\logfiles\11-05-2016-deleted accounts.csv
```

Each of those CSV files contains information about users who the script attempted to disable or delete.
For example, you could review the results of those CSV files by importing them into PowerShell objects.

```powershell
$LogFolder = 'C:\Automation\AD\Cleanup\logfiles'
$LogFile = "$LogFolder\11-05-2016-disabled accounts.csv"
$DisableResults = Import-Csv -Path $LogFile
$DisableResults | Select-Object -First 1 | Format-List -Property *
```

That would display results _like_ these (note that the names and
values are just examples):

```
distinguishedName: CN=Jane Doe,OU=Sales,DC=Domain,DC=COM
samAccountName:    janedoe
lastLogonDate:     9/29/2018 3:22:36 PM
whenCreated:       3/12/2013 2:44:51 PM
passWordLastSet:   5/15/2018 9:13:09 AM
whenChanged:       5/29/2018 10:04:16 AM
objectClass:       User
ScriptDisabled:    Match found in named exceptions file
```

Note that, if Jane Doe's account had been disabled (instead of being in an exception list) the value of `ScriptDisabled` would have been `True`.
If the script had failed to disable Jane Doe's account for any reason - if the command failed, for example - the value of `ScriptDisabled` would then have been `False`.

The results from the log file for accounts the script attempted to delete would look the same, with one exception: the last property would be `ScriptDeleted` instead of `ScriptDisabled`.

You could inspect the results of the CSV using PowerShell however you like.
For example, you could just get the list of user accounts that the script failed to disable:

```powershell
$FilterScript = {
    ($_.ObjectClass -eq 'User') -and
    ($_.ScriptDisabled -eq $false)
}
$DisableResults |
    Where-Object -FilterScript $FilterScript |
    Select-Object -ExpandProperty samAccountName
```

That might retun a list like this:

```
johndoe
prateeksingh
latoyajohnson
```

And you could then troubleshoot why those accounts could not be disabled.

For more information on how to run the script, including more examples and information about the parameters, check out the script's help info:

```powershell
Get-Help .\Update-InactiveOrStaleADAccounts.ps1 -ShowWindow
```

That will open a new window with the full help file for the script.

You can download the script from our script share directly at the following URL:

    `https://packages.domain.com/ops/scripts/Update-InactiveOrStaleADAccounts`

Alternatively, you can open a PowerShell prompt on your local machine (or on whichever computer you're putting the script on) and run the following code:

```powershell
$BaseUrl = 'https://packages.domain.com/ops/scripts/'
$ScriptName = 'Update-InactiveOrStaleADAccounts'
$DownloadParameters = @{
  Uri = $BaseUrl + $ScriptName + '.zip'
  UseBasicParsing = $true
  OutFile = '.\Update-InactiveOrStaleADAccounts.zip'
}
Invoke-WebRequest @DownloadParameters
$ExpandParameters = @{
  Path = '.\Update-InactiveOrStaleADAccounts.zip'
  DestinationPath = 'C:\Automation\AD\Cleanup'
  Force = $true
}
Expand-Archive @ExpandParameters
Push-Location C:\Automation\AD\Cleanup
```

This will download the script, unzip it to the appropriate folder, and set that folder as the current directory.
From this point you can run the scripts as in the examples above.

## Notes

> **WARNING:** By default the script **will** disable inactive and delete stale accounts!
> You can overwrite this behavior by uncommenting the `WhatIf` parameters in the script.

This script is a legacy script that has been running in production (with unknown, untracked changes) since Summer 2013.
IThe script is used to ensure we are meeting our organizational requirements for disabling inactive accounts and deleting stale ones.

It requires some refactoring that will come in later updates.
Namely, it needs:

- [ ] To handle `WhatIf` runs without requiring editing the script.
- To cleanup the parameters:
  - [ ] NamedExceptions should be handled better
  - [ ] Several parameters need to be removed or placed as constants
  - [ ] Expected types should be specified for each parameter
  - [ ] The script should take pipeline input for the exception list
  - [ ] Users should be able to pass a credential for AD commands
- [ ] The output for the number of accounts to disable/delete should
  be sensible verbose messages
- [ ] The messaging for the log output should be cleaned up
  - The logs right now may not actually verify if an account was
    acted on or not - at best they're ambiguous and optimistic