
#Requires -RunAsAdministrator

Set-WSManQuickConfig -SkipNetworkProfileCheck -Force -Verbose

# WinRM is required
Set-Service -Name 'WinRM' -StartupType 'Automatic' -PassThru |
Start-Service

$null = mkdir 'C:\ProgramData\JEAConfiguration\Transcripts' -Force

# Create a PowerShell Session Configuration (pssc) file
$HT = @{
    SchemaVersion = '2.0.0.0'
    GUID = '576308c6-4dd0-4a8c-b638-3a9a6f1a358b'
    Author = 'Emin'
    SessionType = 'RestrictedRemoteServer'
    TranscriptDirectory = 'C:\ProgramData\JEAConfiguration\Transcripts'
    RunAsVirtualAccount = $true
    ModulesToImport = 'Microsoft.PowerShell.LocalAccounts'
    VisibleFunctions = 'Add-MyAccountToLocalAdministratorsGroup'
    FunctionDefinitions = @{
        Name = 'Add-MyAccountToLocalAdministratorsGroup'
        ScriptBlock = {
            Param()
            Begin {}
            Process {
                $HT = @{
                    Group = 'Administrators'
                    Member = "$($PSSenderInfo.UserInfo.Identity.Name)"
                }
                Microsoft.PowerShell.LocalAccounts\Add-LocalGroupMember @HT
            }
            End {}
        }
    }
}
New-PSSessionConfigurationFile -Path 'C:\windows\temp\demo.pssc' @HT

# Create the restricted remote endpoint
$HT = @{
    Name = 'MakeMeAdmin'
    Force = [switch]::Present
    SecurityDescriptorSddl = 'O:NSG:BAD:P(A;;GA;;;BA)(A;;GXGR;;;S-1-5-11)(A;;GA;;;RM)(A;;GA;;;IU)S:P(AU;FA;GA;;;WD)(AU;SA;GXGW;;;WD)'
}

Register-PSSessionConfiguration -Path 'C:\windows\temp\demo.pssc' @HT
