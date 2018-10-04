#Requires -RunAsAdministrator

@'
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
'@ | Out-File -FilePath 'C:\windows\Remove-UACUser.ps1' -Encoding ascii


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
) -Force
