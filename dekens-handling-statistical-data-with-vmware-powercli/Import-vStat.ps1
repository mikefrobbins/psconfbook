function Import-vStat{
    <#
    .SYNOPSIS
    Import vSphere statistical data
    .DESCRIPTION
    The function imports default vSphere statistical data,
    that was exported with Export-vStat, for a speficied timerange.
    .EXAMPLE
    Import-vStat -Start $start -Finish $finish
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
        [String]$Path = '.'
    )

    $strStart = $start.ToString('yyyyMMddHHmm')
    $strFinish = $finish.ToString('yyyyMMddHHmm')

    # Read statistical data

    foreach($statFile in Get-ChildItem -Path $Path -Filter 'Stat*.zip'){
        $strFStart,$strFFinish = $statFile.BaseName.Split('-')[1..2]

        if(($strStart -le $strFStart -and $strFinish -ge $strFFinish) -or
           ($strStart -ge $strFStart -and $strStart -le $strFFinish) -or
           ($strFinish -ge $strFStart -and $strFinish -ge $strFFinish)){
            Try{
                $sUnzip = @{
                    Path = $statFile.FullName
                    DestinationPath = $Path
                    Force = $true
                }
                Expand-Archive @sUnzip
                $xmlcliName = $statFile.FullName.Replace('zip','clixml')
                Import-Clixml -Path $xmlcliName
            }
            Catch{
                Write-Error "Reading from $($statFile.Fullname) failed"
            }
        }
    }
}