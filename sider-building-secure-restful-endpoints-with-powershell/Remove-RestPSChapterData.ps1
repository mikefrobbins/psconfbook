<#
    .DESCRIPTION
        This script will clean your machine up from the default RestPS configuration and testing.
        This is specific to the chapter titled 'Building Secure RESTful Endpoints with PowerShell'
    .EXAMPLE
        Remove-RestPSChapterData.ps1
    .NOTES
    	This will return null
#>

# Clean up C:\RestPS directory
if (Test-Path -Path 'C:\RestPS')
{
    Write-Output 'Removing c:\RestPS'
    Get-Item -Path 'C:\RestPS' | Remove-Item -Recurse -Force -Confirm:$false
}
else
{
    Write-Output 'Path C:\RestPS did not exist.'
}

# Remove Certificates
$Certificates = @('CN=RESTServer.PowerShellDemo.io', 'CN=DemoClient.PowerShellDemo.io', 'CN=PowerShellDemo.io Root Cert', 'CN=badCert.PowerShellDemo.io')
foreach ($Certificate in $Certificates)
{
    Write-Output "Removing Certificate for: $Certificate"
    Get-ChildItem -Path Cert:\LocalMachine\My\ | Where-Object { $_.Subject -eq $Certificate} | Remove-Item -Force -Confirm:$false
    if ($Certificate -like "*Root Cert*")
    {
        Write-Output 'Removing Root Cert from Root Store.'
        Get-ChildItem -Path Cert:\LocalMachine\Root\ | Where-Object { $_.Subject -eq $Certificate} | Remove-Item -Force -Confirm:$false
    }
}