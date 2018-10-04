Remove-Item 'c:\temp\test.xlsx' -ErrorAction Ignore

$data = . $PSScriptRoot\data.ps1

$ExportExcelParams = @{
    Path = 'c:\temp\test.xlsx'
    Show = $true
}

$North = New-ConditionalText -ConditionalTextColor Black -BackgroundColor Red    -Text North
$South = New-ConditionalText -ConditionalTextColor Black -BackgroundColor Orange -Text South
$East  = New-ConditionalText -ConditionalTextColor Black -BackgroundColor Yellow -Text East
$West  = New-ConditionalText -ConditionalTextColor Black -BackgroundColor Green  -Text West

$data | Export-Excel @ExportExcelParams -ConditionalText $North, $South, $East, $West