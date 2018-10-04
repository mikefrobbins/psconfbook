function New-CO ($var, $string) {
    Set-Variable -Name $var -Scope Global -Value (
        [PSCustomObject]@{
            PSTypeName = 'Custom.Encoded'
            String     = $string
        })
}

New-CO Data "Awesome!"

$Data | Get-EncodedString