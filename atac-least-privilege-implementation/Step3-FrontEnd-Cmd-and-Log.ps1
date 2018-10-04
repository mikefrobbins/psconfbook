#Requires -RunAsAdministrator

@'
[CmdletBinding()]
Param()
Begin {}
Process {
 $PSSessionHT = @{
  ComputerName = 'localhost'
  ConfigurationName = 'MakeMeAdmin'
  ErrorAction = 'SilentlyContinue'
 }
 $HT = @{
  Session = New-PSSession @PSSessionHT
  ScriptBlock = { Add-MyAccountToLocalAdministratorsGroup }
 }
 Invoke-Command @HT
 $LogHT = @{
  FilePath = "$($env:systemroot)\demo.log"
  Encoding = 'ASCII'
  Force = [switch]::Present
  NoClobber = [switch]::Present
  Append = [switch]::Present
 }
 '{0} ; {1} ; {2} ; {3} ; ADD ; {4}' -f (
  (Get-Date).ToString('yyyyMMddHHmmss')
 ),($Host.InstanceId.Guid.ToString()),
 ([System.Security.Principal.WindowsIdentity]::GetCurrent().User.Value),
 "$($env:userdomain)\$($env:username)",
 "$($env:computername)" |
 Out-File @LogHT

 $timeout = 20
 $titlemsg = "Information message: "
 $txtboxlabel = @"
Your account has been granted administrative privileges on this computer.
"@

 # Display the popup    
 $obj = new-object -comobject wscript.shell
 $obj.popup($txtboxlabel,$timeout,$titlemsg,0)
}
End {}
'@ | Out-File -FilePath 'C:\windows\Add-UACUser.ps1' -Encoding ascii -Force

# Create the cmd script on every users' desktop
$AllUsersDesktopCmdFile = 'C:\Users\Public\Desktop\MakeMeAdmin.cmd'
@'
@echo off
set PS=%systemroot%\system32\WindowsPowerShell\v1.0\powershell.exe
"%PS%" -ExecutionPolicy Bypass -File "C:\windows\Add-UACUser.ps1"
'@ |
Out-File -FilePath $AllUsersDesktopCmdFile -Encoding ascii -Force

# Create an empty file
New-Item -Path C:\Windows\demo.log -ItemType File -Value $null -Force

# Set allow everyone to append data
icacls --% C:\Windows\demo.log /grant Everyone:(W,RA)
