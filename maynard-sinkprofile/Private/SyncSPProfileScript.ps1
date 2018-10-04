Function SyncSPProfileScript {
<#
Called by:  Invoke-SinkProfileSync.
Purpose:    The purpose of this helper function is to sync the profile.ps1 file 
            from the location that holds the newest version of the profile script
            to the location that hold the oldest version.
#>
    [CmdletBinding()]
    Param (
        [Parameter()]
        [string]$PartnerPathProfile,

        [Parameter()]
        [string]$LocalProfileScriptNewest
    )

    Begin {} # End Begin.

    Process {
        If ($LocalProfileScriptNewest -eq $false) {
            #$ProfileScriptLastWrite -lt $PartnerProfileScriptLastWrite
            Copy-Item -Path $PartnerPathProfile -Destination $PROFILE.CurrentUserAllHosts

            Write-Output -InputObject 'The SinkProfile profile script has been updated.'
            Do {
                $Prompt = Read-Host -Prompt 'Enter r to Restart or c to Cancel'
            } Until ($Prompt -eq 'r' -or $Prompt -eq 'c')

            If ($Prompt -eq 'r') {
                Start-Process -FilePath (Get-Process -Id $PID).ProcessName
                Stop-Process -Id $PID
            } # End If.

        } ElseIf ($LocalProfileScriptNewest -eq $true) {
            #$ProfileScriptLastWrite -gt $PartnerProfileScriptLastWrite
            Copy-Item -Path $PROFILE.CurrentUserAllHosts -Destination $PartnerPathProfile
        } # End If-ElseIf.
    } # End Process.

    End {} # End End.
} # End Function: SyncSPProfileScript.