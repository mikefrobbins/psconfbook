Function NewSPPartnerObject {
<#
Called by:  Get-SinkProfilePartner.
Purpose:    The purpose of this helper function is to return the SinkProfile partners on the local computer 
            from "C:\Users\<username>\Documents\SinkProfile\". Each XML file in this directory represents 
            a seperate SinkProfile partner.
#>
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory)]
        [string]$DocumentsPath
    )
    #region Create SinkProfile partner object.
    Get-ChildItem -Path $DocumentsPath -Filter '*.xml' | ForEach-Object {
        Import-Clixml -Path $_.FullName
    } # End ForEach-Object.
    #endregion.
} # End Function: NewSPPartnerObject.