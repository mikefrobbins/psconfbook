Function StartSPBackup {
<#
Called by:  Complete-SinkProfilePartner.
Purpose:    The purpose of this helper function is to backup the CurrentUserAllHosts
            (profile.ps1) profile script, if it already exists. The "2" in the 
            filename indicates it was the second (or third, fourth, etc.) computer 
            in the SinkProfile sync group.
#>
    $ProfilePath = $PROFILE.CurrentUserAllHosts
    If (Test-Path -Path $ProfilePath) {
        Get-Item -Path $ProfilePath |
            Copy-Item -Destination "$ProfilePath.$(Get-Date -Format 'DyyMMddTHHmmss.fff').2.bak"
    }
} # End Function: StartSPBackup.