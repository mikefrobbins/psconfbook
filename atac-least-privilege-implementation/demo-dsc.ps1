Configuration SetDemo {
Param(
    [string[]]$NodeName = 'localhost'
)
Import-DscResource –ModuleName 'PSDesiredStateConfiguration'
Node $NodeName
{
#region MakeMeAdmin Endpoint
Script MakeMeAdminEP {
 GetScript = {
  @{
   GetScript = $GetScript
   SetScript = $SetScript
   TestScript = $TestScript
   Result  = ($true)
  }
 }
 SetScript = {
  $null = mkdir 'C:\ProgramData\JEAConfiguration\Transcripts' -Force -Verbose:$false
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
  New-PSSessionConfigurationFile -Path 'C:\windows\temp\demo.pssc' @HT -Verbose:$false
  # Create the restricted remote endpoint
  $HT = @{
   Name = 'MakeMeAdmin' 
   # Force = [switch]::Present # Do not force because of NoServiceRestart
   SecurityDescriptorSddl = 'O:NSG:BAD:P(A;;GA;;;BA)(A;;GXGR;;;S-1-5-11)(A;;GA;;;RM)(A;;GA;;;IU)S:P(AU;FA;GA;;;WD)(AU;SA;GXGW;;;WD)'
  }
  # Use job to get rid of verbose stream although it's explicitely turned off
  Start-Job -ScriptBlock {
   # Use NoServiceRestart in DSC to avoid WinRM troubles
   Register-PSSessionConfiguration -Path 'C:\windows\temp\demo.pssc' @using:HT -Verbose:$false -NoServiceRestart
  } | 
  Wait-Job -Timeout 10
 }
 TestScript = { 
  return $false
 }
}
#endregion
#region Remove-UACUser.ps1
File RemoveUser {
 DestinationPath = 'C:\windows\Remove-UACUser.ps1'
 Ensure = 'Present';
 Force = $true
 Contents = @'
#Requires -RunAsAdministrator
[CmdletBinding()]
Param()
Begin {}
Process {
 # Define a whitelist
 $whitelist= @(
  "$($env:computername)\Administrator",
  (
   Get-CimInstance -ClassName Win32_UserAccount -Filter "LocalAccount='True'"|
   Where-Object { $_.SID -match 'S-1-5-21-(\d{9,10}-){3}500' }
  ).SID,
  "$($env:computername)\WDAGUtilityAccount" # Application Guard
 )

 # Remove any user that does not appear to be in the whitelist
 try {
    Get-LocalGroupMember -SID 'S-1-5-32-544' -ErrorAction Stop | 
    ForEach-Object {
     Write-Verbose -Message "Testing member: $($_.Name): $($_.SID.Value)"
     if (($_.SID.Value -in $whitelist) -or ($_.Name -in $whitelist)) {
      Write-Verbose -Message "User $($_.SID.Value) listed in the whitelist"
     } else {
      Write-Verbose -Message "Removing user $($_) not listed in the whitelist"

      try {
       Remove-LocalGroupMember -SID 'S-1-5-32-544' -Member "$($_.SID.Value)"
      } catch {
       Write-Warning -Message "Remove failed because $($_.Exception.Message)"
      }

      $logfile = "$($env:systemroot)\demo.log"
      # Add to log file
      '{0} ; {1} ; {2} ; {3} ; REMOVE ; {4} ' -f (
        ((Get-Date).ToString('yyyyMMddHHmmss')),
        ($Host.InstanceId.Guid.ToString()),
        ($_.SID.Value),
        $($_.Name),
        $($env:COMPUTERNAME)
       ) |
      Out-File -FilePath $logfile -Append -NoClobber -Encoding ASCII
     }
    } 
 } catch {
    Write-Warning -Message "Failed because $($_.Exception.Message)"
 }
}
End {}
'@
}
#endregion
#region MMA-Safeguard Scheduled Task
Script MMASafeguardScheduledTask {
 GetScript = {
  @{
   GetScript = $GetScript
   SetScript = $SetScript
   TestScript = $TestScript
   Result  = ($true)
  }
 }
 SetScript = {
  Register-ScheduledTask  -TaskName 'MMA-Safeguard' -Xml (
@'
<?xml version="1.0" encoding="UTF-16"?>
<Task version="1.4" xmlns="http://schemas.microsoft.com/windows/2004/02/mit/task">
<RegistrationInfo>
 <Author>SYSTEM</Author>
</RegistrationInfo>
<Triggers>
 <BootTrigger>
  <Enabled>true</Enabled>
 </BootTrigger>
 <EventTrigger>
  <Enabled>true</Enabled>
  <Subscription>
&lt;QueryList&gt;&lt;Query Id="0" Path="Security"&gt;
&lt;Select Path="Security"&gt;
*[System[Provider[@Name='Microsoft-Windows-Security-Auditing'] and 
EventID=4647]]&lt;/Select&gt;&lt;/Query&gt;&lt;/QueryList&gt;
  </Subscription>
 </EventTrigger>    
</Triggers>
<Principals>
 <Principal id="Author">
  <UserId>S-1-5-18</UserId>
  <RunLevel>HighestAvailable</RunLevel>
 </Principal>
</Principals>
<Settings>
 <MultipleInstancesPolicy>IgnoreNew</MultipleInstancesPolicy>
 <DisallowStartIfOnBatteries>false</DisallowStartIfOnBatteries>
 <StopIfGoingOnBatteries>false</StopIfGoingOnBatteries>
 <AllowHardTerminate>true</AllowHardTerminate>
 <StartWhenAvailable>false</StartWhenAvailable>
 <RunOnlyIfNetworkAvailable>false</RunOnlyIfNetworkAvailable>
 <IdleSettings>
  <StopOnIdleEnd>true</StopOnIdleEnd>
  <RestartOnIdle>false</RestartOnIdle>
 </IdleSettings>
 <AllowStartOnDemand>true</AllowStartOnDemand>
 <Enabled>true</Enabled>
 <Hidden>true</Hidden>
 <RunOnlyIfIdle>false</RunOnlyIfIdle>
 <DisallowStartOnRemoteAppSession>false</DisallowStartOnRemoteAppSession>
 <UseUnifiedSchedulingEngine>false</UseUnifiedSchedulingEngine>
 <WakeToRun>false</WakeToRun>
 <ExecutionTimeLimit>PT1H</ExecutionTimeLimit>
 <Priority>7</Priority>
</Settings>
<Actions Context="Author">
 <Exec>
  <Command>
C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe
  </Command>
  <Arguments>
-ExecutionPolicy Bypass -NoProfile -File "C:\Windows\Remove-UACUser.ps1"
  </Arguments>
 </Exec>
</Actions>
</Task>
'@
) -Force -Verbose:$false
 }
 TestScript = { 
  return $false
 }
 DependsOn = '[File]RemoveUser'
}
#endregion
#region Add-UACUser.ps1
File AddUser {
 DestinationPath = 'C:\windows\Add-UACUser.ps1'
 Ensure = 'Present';
 Force = $true
 Contents = @'
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
'@
}
#endregion
#region MakeMeAdmincmd
File MakeMeAdmincmd {
 DestinationPath = 'C:\Users\Public\Desktop\MakeMeAdmin.cmd'
 Ensure = 'Present';
 Force = $true
 Contents = @'
@echo off
set PS=%systemroot%\system32\WindowsPowerShell\v1.0\powershell.exe
"%PS%" -ExecutionPolicy Bypass -File "C:\windows\Add-UACUser.ps1"
'@
 DependsOn = '[File]AddUser'
}
#endregion
#region MakeMeAdmincmdRemoveBOM
Script MakeMeAdmincmdRemoveBOM {
 GetScript = {
  @{
   GetScript = $GetScript
   SetScript = $SetScript
   TestScript = $TestScript
   Result  = ($true)
  }
 }
 SetScript = {
  # Remove BOM because File DSC resource creates a UTF8 file with BOM
  [System.IO.File]::WriteAllLines(
   'C:\Users\Public\Desktop\MakeMeAdmin.cmd',
   (Get-Content -Path 'C:\Users\Public\Desktop\MakeMeAdmin.cmd'), 
   (New-Object System.Text.UTF8Encoding($False))
  )
 }
 TestScript = { 
  return $false
 }
 DependsOn = '[File]MakeMeAdmincmd'
}
#endregion
#region Script DemoLogACL
Script DemoLogACL {
 GetScript = {
  @{
   GetScript = $GetScript
   SetScript = $SetScript
   TestScript = $TestScript
   Result  = ($true)
  }
 }
 SetScript = {
  icacls --% C:\Windows\demo.log /grant Everyone:(W,RA)
 }
 TestScript = { 
  return $false
 }
 DependsOn = '[File]DemoLogFile'
} 
#endregion
#region DemoLogFile
File DemoLogFile {
 DestinationPath = 'C:\windows\demo.log'
 Ensure = 'Present';
 Force = $true
 Contents = [string]::Empty
}
#endregion
} #endof Node
} #endof Config

if (-not(test-path -Path C:\DSC -PathType Container)) {
    $null = mkdir C:\DSC
}
# Compile the configuration file to a MOF format
SetDemo -OutputPath C:\DSC -Verbose

# Create a HTTP listner required and not present by default in a Azure VM
Set-WSManQuickConfig -SkipNetworkProfileCheck -Force -Verbose

Unregister-PSSessionConfiguration -Name MakeMeAdmin -Force -Verbose:$false -ErrorAction SilentlyContinue

# Run the configuration on localhost
Start-DscConfiguration -Path C:\DSC -ComputerName localhost -Verbose -Force -Wait

Restart-Service -Name WinRM -Force -Verbose

break

# Test
New-LocalUser -Name test -Password (
    ConvertTo-SecureString -String 'test' -AsPlainText -Force
)
Add-LocalGroupMember -Group "Remote Desktop Users" -Member test
