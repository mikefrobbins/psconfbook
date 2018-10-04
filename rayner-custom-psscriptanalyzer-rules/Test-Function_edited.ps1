function Test-Function {
    param (
        [Parameter(Mandatory)]$FirstParameter
    )
    Write-Output $FirstParameter
}