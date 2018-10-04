Function NewSPDocumentsAndPartnerFile {
<#
Called by:  Add-SinkProfilePartner.
Purpose:    The purpose of this helper function is to create a sync partner file in both 
            the Documents and Partner directories, such as "C:\Users\tommymaynard\Documents\SinkProfile\" 
            and "C:\Users\tommymaynard\Dropbox\SinkProfile\".
#>
    Param (
        [Parameter()]
        [string]$PartnerName,

        [Parameter()]
        [string]$PartnerPath,

        [Parameter()]
        [string]$DocumentsPath
    )

    $Object = [pscustomobject]@{
        PartnerName = $PartnerName
        PartnerPath = $PartnerPath
        PartnerPathProfile = "$($PartnerPath)\profile.ps1"
        PartnerPathXml = "$(Join-Path -Path $PartnerPath -ChildPath $PartnerName).xml"
        DocumentsPath = $DocumentsPath
        DocumentsPathXml = "$(Join-Path -Path $DocumentsPath -ChildPath $PartnerName).xml"
    }

    try {
        $Object | Export-Clixml -Path $Object.PartnerPathXml
        $Object | Export-Clixml -Path $Object.DocumentsPathXml
    } catch {
        Write-Warning -Message 'An exception or error occurred.'
    } # End try-catch.
} # End Function: NewSPDocumentsAndPartnerFile.