Function Complete-SinkProfilePartner {
<#
.SYNOPSIS
    The Complete-SinkProfilePartner function completes a partnership with a service that allows syncing of files between multiple computers.
.DESCRIPTION
    This function is to be used on computers that are a part of a sync group; however, it should only be invoked on computers after the initial work is completed on the first computer in the sync group. The second (third, fourth, etc.) computer's name should have been a parameter value provided the ComputerName parameter on the New-SinkProfileFixture function ran on the initial computer in the sync group. This is what ensures the profile script will apply to all the computers in the sync group.
.PARAMETER PartnerPath
    The PartnerPath parameter requires a path value to the folder that syncs with the chosen syncing service, such as Dropbox. If the "C:\Users\tommymaynard\Dropbox" folder syncs with Dropbox, this value would be entered as the value for the PartnerPath parameter.
.EXAMPLE
    Complete-SinkProfilePartner -
.NOTES
    Name: Complete-SinkProfilePartner
    Author: Tommy Maynard
#>
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory)]
        [string]$PartnerName,

        [Parameter(Mandatory)]
        [string]$PartnerPath
    )

    Begin {
        $DocumentsPath = "$env:USERPROFILE\Documents\SinkProfile"
        $PartnerFilePath = "$PartnerPath\SinkProfile\$PartnerName.xml"

    } # End Begin.

    Process {
        If (Test-Path -Path $PartnerFilePath) {
            $PartnerPathsFromFile = Import-Clixml -Path $PartnerFilePath

            Write-Verbose -Message 'Attempting to back up existing CurrentUserAllHosts profile script.'
            StartSPBackup

            Write-Verbose -Message 'Attempting to copy CurrentUserAllHosts profile script to the local system.'
            CopySPProfileScript -PartnerPathProfile $PartnerPathsFromFile.PartnerPathProfile

            Write-Verbose -Message "Attempting to create a local storage location in ""$DocumentsPath."""
            NewSPDocumentsDirectory -DocumentsPath $DocumentsPath | Out-Null # Also used by Add-SinkProfilePartner.

            Write-Verbose -Message 'Attempting to copy partner file to local system.'
            CopySPPartnerFile -PartnerPathXml $PartnerPathsFromFile.PartnerPathXml -DocumentsPath $DocumentsPath
        } Else {
            Write-Warning -Message 'Unable to locate partner file in partner path.'
        }
    } # End Process.

    End {} # End End.
} #End Function: Complete-SinkProfilePartner.