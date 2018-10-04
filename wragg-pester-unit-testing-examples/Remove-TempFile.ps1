function Remove-TempFile {
    [cmdletbinding(SupportsShouldProcess)]
    Param(
        $Path
    )
    $TempFiles = Get-TempFile -Path $Path
    $TempFiles | ForEach-Object {
        if ($pscmdlet.ShouldProcess($_, 'Remove-TempFile')) {
            $TempFiles | Remove-Item
        }
    }
}