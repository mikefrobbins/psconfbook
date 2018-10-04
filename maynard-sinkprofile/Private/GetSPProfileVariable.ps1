Function GetSPProfileVariable {
<#
Called by:  New-SinkProfileFixture.
Purpose:    The purpose of this helper function is to determine if the 
            $PROFILE automatic variable exists.
#>
    If ($PROFILE) {
        $true
    } Else {
        $false
    } # End If-Else.
} # End Function: GetSPProfileVariable.