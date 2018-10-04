Function NewSPProfileScript {
<#
Called by:  New-SinkProfileFixture.
Purpose:    The purpose of this helper function is to create the profile.ps1
            profile scripts (CurrentUserAllHosts) with the required structure.
#>
    Param (
        [Parameter()]
        [string[]]$ComputerName
    )

    $FixtureContent = @"
#region Code for all computers. 
Switch (`$env:COMPUTERNAME) {
"@
    Foreach ($Computer in $ComputerName) {
$FixtureContent += @"

    {`$_ -eq '$Computer'} {
        # Enter code here for the "$Computer" computer.
    }

"@
    } # End ForEach-Object.
$FixtureContent += @"

    {`$_ -eq $("'" + ($ComputerName -join "' -or `$_ -eq '") + "'")} {
        # Enter code here for all $($ComputerName.Count) computers.
        `$SinkProfile = `$true
    }

    default {}
} # End Switch.
#endregion.

#region Invoke Invoke-SinkProfileSync function.
Invoke-SinkProfileSync
#endregion.
"@

    Set-Content -Path $Profile.CurrentUserAllHosts -Value $FixtureContent
} # End Function: NewSPProfileScript.