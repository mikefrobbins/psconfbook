Function NewSPDocumentsDirectory {
<#
Called by:  Add-SinkProfilePartner, Complete-SinkProfilePartner.
Purpose:    The purpose of this helper function is to create a directory called
            SinkProfile inside the current user's Documents folder, such as 
            "C:\Users\tommymaynard\Documents\SinkProfile\".
#>
    Param (
        [Parameter()]
        [string]$DocumentsPath
    )

    If (-Not(Test-Path -Path $DocumentsPath)) {
        New-Item -Path $DocumentsPath -ItemType Directory | Out-Null
        Start-Sleep -Milliseconds 500

        If ((Get-Item -Path $DocumentsPath).Exists) {
            $true
        } Else {
            $false
        } # End If-Else.

    } Else {
        $true
    } # End If-Else.
    pause
} # End Function: NewSPDocumentsDirectory.