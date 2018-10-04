function Export-vStat{
    <#
    .SYNOPSIS
    Export vSphere statistical data as a zipped XMLCLI file
    .DESCRIPTION
    The function retrieves default vSphere statistical data
    for the speficied timerange.
    The data is exported as XMLCLI, and the file is Zipped.
    .EXAMPLE
    Export-vStat -Entity $esx -Start $start -Finish $finish
    .PARAMETER Entity
    One or more vSphere objects
    .PARAMETER Start
    STart of the interval
    .PARAMETER Finish
    End of the interval
    .PARAMETER Path
    The location where the file is to be created
    #>
    [CmdletBinding()]
    param(
        [DateTime]$Start,
        [DateTime]$Finish,
        [PSObject[]]$Entity,
        [String]$Path = '.'
    )

    $strStart = $Start.ToString('yyyyMMddHHmm')
    $strFinish = $Finish.ToString('yyyyMMddHHmm')
    $reportName = "$path\Stat-$strStart-$strFinish.clixml"

    $sStat = @{
        Entity = $Entity
        Start = $Start
        Finish = $Finish
        Realtime = $true
        ErrorAction = 'SilentlyContinue'
    }
    Try{
        Get-Stat @sStat |
        Export-Clixml -Path $reportName
    }
    Catch{
        Write-Error "Statistical data retrieval/save failed"
        return
    }

    # Zip the data

    $sCompress = @{
        Path = $reportName
        DestinationPath = $reportName.Replace('clixml','zip')
        CompressionLevel = 'Optimal'
    }
    try{
        Compress-Archive @sCompress
        Remove-Item -Path $reportName
    }
    Catch{
        Write-Error "Compression of $reportName failed"
    }
}