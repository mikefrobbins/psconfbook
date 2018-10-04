Remove-Item 'c:\temp\test.xlsx' -ErrorAction Ignore

$data = . $PSScriptRoot\data.ps1

$ExportExcelParams = @{
    Path      = 'c:\temp\test.xlsx'
    TableName = 'RegionTable'
    Show      = $true
}

$data | Export-Excel @ExportExcelParams