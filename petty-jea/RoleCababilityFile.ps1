New-PSRoleCapabilityFile -Path 'C:\Program Files\WindowsPowerShell\Modules\`
Demo\RoleCapabilities\helpdesk.psrc'


#Just Cmdlets
$CapabilityFile = @{
    Path = 'C:\Program Files\WindowsPowerShell\Modules\HelpDesk\RoleCapabilities\`
    helpdesk.psrc'
    VisibleCmdlets = "get-service"
}
New-PSRoleCapabilityFile @CapabilityFile


$CapabilityFile = @{
    Path = 'C:\Program Files\WindowsPowerShell\Modules\HelpDesk\RoleCapabilities\`
    helpdesk.psrc'
    VisibleCmdlets = @{Name = 'Restart-Service';
                       Parameters = @{Name = 'Name'; ValidateSet = 'Spooler'}}
}
New-PSRoleCapabilityFile @CapabilityFile




#Adding functions
$CapabilityFile = @{
    Path = 'C:\Program Files\WindowsPowerShell\Modules\HelpDesk\RoleCapabilities\`
    helpdesk.psrc'
    VisibleCmdlets = "get-process","get-service","restart-computer"
    VisibleFunctions='Disable-ScheduledTask',
    'Enable-ScheduledTask',
    'Start-ScheduledTask',
    'Stop-ScheduledTask',
    'Where-Object',
    'Select-Object',
    'Get-SmbOpenFile',
    'Close-SmbOpenFile'
}

New-PSRoleCapabilityFile @CapabilityFile