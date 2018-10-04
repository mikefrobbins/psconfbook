Function New-OnBoardFolders {
    [CmdletBinding()]
    param(
        [String]$FileServer = 'WIN2k16-001',
        [String]$CustomerName,
        [String]$CustomerCode,
        [String]$TicketNr
    )

    if (Test-Connection -ComputerName $FileServer){
        New-DefaultTargetFolders -CustomerCode $CustomerCode -FileServer $FileServer
        New-CustomerDFSnLink -CustomerCode $CustomerCode -FileServer $FileServer
    }
}
