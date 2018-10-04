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
}

$ConditionaFormat = New-ConditionalFormattingIconSet -Range "C:C" -ConditionalFormat ThreeIconSet -IconType Arrows

$data | Export-Excel @ExportExcelParams -ConditionalFormat $ConditionaFormat