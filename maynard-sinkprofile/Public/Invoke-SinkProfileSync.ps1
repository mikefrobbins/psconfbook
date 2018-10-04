Function Invoke-SinkProfileSync {
<#
.SYNOPSIS
    The Invoke-SinkProfileSync function ensures the newest version of the CurrentUserAllHosts profile script is useable in the local file system.
.DESCRIPTION
    If the newest version of the CurrentUserAllHosts profile script is newer on the computer vs. in the partner folder, it will copy it from the its place in the WindowsPowerShell folder (C:\Users\<username>\Documents\WindowsPowerShell\), to its place in the partner folder, such as C:\Users\<username>\Dropbox\SinkProfile\profile.ps1. This function makes use of the Get-SinkProfilePartner public function.
.EXAMPLE
    Invoke-SinkProfileSync
    This example copies the newest CurrentUserAllHosts profile script from the location with the newest version to the location of the oldest version.
.NOTES
    Name: Invoke-SinkProfileSync
    Author: Tommy Maynard
#>
    [CmdletBinding()]
    Param ()

    Begin {} # End Begin.

    Process {
        #region Sync of all Sink Profile partners.
        Get-SinkProfilePartner | ForEach-Object {
            $Params = @{
                PartnerPathProfile = $_.PartnerPathProfile
                ProfileScriptLastWrite = (Get-Item -Path $PROFILE.CurrentUserAllHosts).LastWriteTime
                PartnerProfileScriptLastWrite = If ((Get-Item $_.PartnerPathProfile -OutVariable LWT -ErrorAction SilentlyContinue).LastWriteTime) {
                    $LWT.LastWriteTime
                } Else {
                    Get-Date -Date '01/01/1600'
                }
            }
            $Params += @{
                LocalProfileScriptNewest = $Params.ProfileScriptLastWrite -gt $Params.PartnerProfileScriptLastWrite
                MatchingProfileScripts = $Params.PartnerProfileScriptLastWrite -eq $Params.ProfileScriptLastWrite
            }

            If ($Params.MatchingProfileScripts -eq $true) {
                $Sync = $false
                Write-Verbose -Message 'Copying profile script is not necessary in either direction.'
            } Else {

                $Sync = $true
                If ($Params.LocalProfileScriptNewest -eq $false) {
                    Write-Verbose -Message 'Copying profile script from partner to local system.'

                } ElseIf ($Params.LocalProfileScriptNewest -eq $true) {
                    Write-Verbose -Message 'Copying profile script from local system to partner.'
                } # End If-ElseIf.
            } # End If-Else.
        } # End ForEach-Object.
        #endregion.
    } # End Process.

    End {
        If ($Sync) {
            $Params = @{
                PartnerPathProfile = $Params.PartnerPathProfile
                LocalProfileScriptNewest = $Params.LocalProfileScriptNewest
            }
            SyncSPProfileScript @Params
        }
    } # End End.
} # End Function: Invoke-SinkProfileSync.