Function Add-SinkProfilePartner {
<#
.SYNOPSIS
    The Add-SinkProfilePartner function creates a partnership with a service that allows syncing of files between multiple computers.
.DESCRIPTION 
    The function uses helper functions in order to create a directory called SinkProfile inside the current user's Documents folder, such as "C:\Users\tommymaynard\Documents\SinkProfile\", 
    create a directory called SinkProfile inside the current user's sync partner (ie Dropbox), such as "C:\Users\tommymaynard\Dropbox\SinkProfile\", and 
.PARAMETER PartnerName
    The PartnerName parameter is the name of the selective service, such as Dropbox, that will be used with the SinkProfile PowerShell module.
.PARAMETER PartnerPath
    The PartnerPath parameter requires a path value to the folder that syncs with the chosen syncing service, such as Dropbox. If the "C:\Users\tommymaynard\Dropbox" folder syncs with Dropbox, this value would be entered as the value for the PartnerPath parameter.
.EXAMPLE
    Add-SinkProfilePartner -PartnerName Dropbox -PartnerPath 'C:\Users\tommymaynard\Dropbox'
    This example creates a SinkProfile partner file for Dropbox using the partner name of "Dropbox." This same file will also be stored in C:\Users\tommymaynard\Documents\SinkProfile.
.EXAMPLE
    Add-SinkProfilePartner -PartnerName Box -PartnerPath 'C:\Users\tommymaynard\Box Sync\'
    This example create a SinkProfile partner file for Box using the partner name of "Box." Notice the difference in this example, in that PartnerName value differs from the final directory of the PartnerPath value (Box Sync).
    This same file will also be stored in C:\Users\tommymaynard\Documents\SinkProfile.
.NOTES
    Name: Add-SinkProfilePartner
    Author: Tommy Maynard
#>
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory)]
        [string]$PartnerName,

        [Parameter(Mandatory)]
        [string]$PartnerPath,

        [Parameter()]
        [switch]$Force
    )

    Begin {
        $DocumentsPath = "$env:USERPROFILE\Documents\SinkProfile"
        $PartnerPath = "$($PartnerPath.TrimEnd('\'))\SinkProfile"
    } # End Begin.

    Process {
        If (NewSPDocumentsDirectory -DocumentsPath $DocumentsPath) {
            Write-Verbose -Message "Creating local storage location in ""$DocumentsPath."""

            If (NewSPPartnerDirectory -PartnerPath $PartnerPath) {
                Write-Verbose -Message "Creating partner storage location in ""$PartnerPath."""
                
                $Params = @{
                    PartnerName = $PartnerName
                    PartnerPath = $PartnerPath
                    DocumentsPath = $DocumentsPath
                }

                If (-Not(Test-Path -Path "$(Join-Path -Path $PartnerPath -ChildPath '\profile.ps1')")) {
                    Write-Verbose -Message "Creating a partner configuration file."
                    NewSPDocumentsAndPartnerFile @Params
                }
            }

        } Else {
            "Unable to create or verify directory." | ForEach-Object {
                Write-Warning -Message $_; Write-Verbose -Message $_
            } # End ForEach-Object.
        } # End If-Else.
    } # End Process.

    End {} # End End.
} # End Function: Add-SinkProfilePartner.