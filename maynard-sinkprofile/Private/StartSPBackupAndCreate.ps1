Function StartSPBackupAndCreate {
<#
Called by:  New-SinkProfileFixture.
Purpose:    The purpose of this helper function is to backup the CurrentUserAllHosts 
            (profile.ps1) profile script, if that is necessary. Additionally, it
            will create a new CurrentUserAllHosts profile script. The "1" in the 
            filename indicates it was the first computer in the SinkProfile sync
            group.
#>
    Param (
        [Parameter()]
        [string[]]$ProfileNeeds
    )

    $ProfilePath = $PROFILE.CurrentUserAllHosts
    Switch ($ProfileNeeds) {
        'backup' {
            Get-Item -Path $ProfilePath |
                Copy-Item -Destination "$ProfilePath.$(Get-Date -Format 'DyyMMddTHHmmss.fff').1.bak"
        }
        'create' {
            New-Item -Path $ProfilePath -Force | Out-Null
        }
    } # End Switch.
} # End Function: StartSPBackupAndCreate.