Function CopySPPartnerFile {
<#
Called by:  Complete-SinkProfilePartner.
Purpose:    The purpose of this helper function is to copy the partner file from 
            the partner folder (Dropbox, etc.) to the local system.
#>
    Param (
        [Parameter(Mandatory)]
        [string]$PartnerPathXml,

        [Parameter()]
        [string]$DocumentsPath
    )
    Copy-Item -Path $PartnerPathXml -Destination $DocumentsPath
} # End Function: CopySPPartnerFile.