Function NewSPPartnerDirectory {
<#
Called by:  Add-SinkProfilePartner.
Purpose:    The purpose of this helper function is to create a directory called
            SinkProfile inside the current user's sync partner (ie Dropbox), 
            such as "C:\Users\tommymaynard\Dropbox\SinkProfile\".
#>
    Param (
        [Parameter()]
        [string]$PartnerPath
    )

    If (-Not(Test-Path -Path $PartnerPath)) {
        New-Item -Path $PartnerPath -ItemType Directory | Out-Null
        Start-Sleep -Milliseconds 500

        If ((Get-Item -Path $PartnerPath).Exists) {
            $true
        } Else {
            $false
        } # End If-Else.

    } Else {
        $true
    } # End If-Else.
} # End Function: NewSPPartnerDirectory.