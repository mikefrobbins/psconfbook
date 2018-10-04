Function Get-SinkProfilePartner {
<#
.SYNOPSIS
    The Get-SinkProfilePartner function returns Sink Profile partners registered on the local computer.
.DESCRIPTION
    A Sink Profile partner is considered to be registered when a specific XML file has been created and is located in the following directory: "C:\Users\<username>\Documents\SinkProfile\." This function relies on at least one helper function in order to create a Sink Profile partner object that is then displayed by this function.
.EXAMPLE  
    Get-SinkProfilePartner
    PartnerName        : Box
        PartnerPath        : C:\users\tommymaynard\Box Sync\SinkProfile
        PartnerPathProfile : C:\users\tommymaynard\Box Sync\SinkProfile\profile.ps1
        PartnerPathXml     : C:\users\tommymaynard\Box Sync\SinkProfile\Box.xml
        DocumentsPath      : C:\Users\tommymaynard\Documents\SinkProfile
        DocumentsPathXml   : C:\Users\tommymaynard\Documents\SinkProfile\Box.xml

        In this example, the contents of all Sink Profile partner files are read in, and an object is created for each file.
.NOTES
    Name: Get-SinkProfilePartner
    Author: Tommy Maynard
#>
    [CmdletBinding()]
    Param ()

    Begin {
        $DocumentsPath = "$env:USERPROFILE\Documents\SinkProfile\"
    } # End Begin.

    Process {
        If (Test-Path -Path $DocumentsPath) {
            NewSPPartnerObject -DocumentsPath $DocumentsPath
        } Else {
            "Unable to locate the Sink Profile Documents directory: ""$DocumentsPath.""" | ForEach-Object {
                Write-Warning -Message $_; Write-Verbose -Message $_
            }
            break
        } # End If-Else.
    } # End Process.

    End {} # End End.
} # End Function: Get-SinkProfilePartner.