Function GetSPProfileNeed {
<#
Called by:  New-SinkProfileFixture.
Purpose:    The purpose of this helper function is to 
#>
    If (Test-Path -Path $PROFILE.CurrentUserAllHosts) {
        'backup','create'
    } Else {
        'create'
    } # End If-Else.
} # End Function: GetSPProfileNeed.