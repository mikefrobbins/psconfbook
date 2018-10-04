rm 'c:\temp\test.xlsx' -ErrorAction Ignore

$data = . $PSScriptRoot\data.ps1

$ExportExcelParams = @{
    Path = 'c:\temp\test.xlsx'
    Show = $true
    ConditionalText = @(
        New-ConditionalText North Black Red    
        New-ConditionalText South Black Orange
        New-ConditionalText East Black Yellow
        New-ConditionalText West Black Green
    )

    ConditionalFormat = New-ConditionalFormattingIconSet -Range "C:C" -ConditionalFormat ThreeIconSet -IconType Arrows
}


$chartDefinition = New-ExcelChart -YRange UnitSold -XRange Region -Title "Units Sold By Region" -NoLegend

$data | Export-Excel @ExportExcelParams -AutoNameRange -ExcelChartDefinition $chartDefinition 