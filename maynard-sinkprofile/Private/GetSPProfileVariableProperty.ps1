Function GetSPProfileVariableProperty {
<#
Called by:  New-SinkProfileFixture.
Purpose:    The purpose of this helper function is to determine if the $PROFILE 
            variable includeds a CurrentUserAllHosts property.
#>
    If (Get-Member -InputObject $PROFILE -Name CurrentUserAllHosts -MemberType NoteProperty) {
        $true
    } Else {
        $false
    } # End If-Else.
} # End Function: GetSPProfileVariableProperty.