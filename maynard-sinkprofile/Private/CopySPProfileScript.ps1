Function CopySPProfileScript {
<#
Called by:  Complete-SinkProfilePartner.
Purpose:    The purpose of this helper function is to copy the CurrentUserAllHosts
            profile script from the partner folder (Dropbox, etc.) to the local
            system.
#>
    Param (
        [Parameter(Mandatory)]
        [string]$PartnerPathProfile
    )
    Copy-Itsem -Path $PartnerPathProfile -Destination (Split-Path -Path $PROFILE.CurrentUserAllHosts)
} # End Function: CopySPProfileScript.