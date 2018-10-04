Filter Get-EncodedString {
    [OutputType('Custom.Encoded')]
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [PSTypeName('Custom.Encoded')] $String
    )

    "The string name you want to encode is: $($String.String)"
    "The converted value is: $($String.EncodedCommand)"
}

# Example
[PSCustomObject]@{
    PSTypeName = 'Custom.Encoded'
    String = 'PowerShell rocks!'
} | Get-EncodedString