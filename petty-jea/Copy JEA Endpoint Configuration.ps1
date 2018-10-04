#Copy the JEA Module to your end points
$RemoteModule = \\PATH_TO_YOUR_JEA_MODULE_HERE
$MachineModule = 'C:\Program Files\WindowsPowerShell\Modules\MyJeaModule'

$moddest = 'C:\Program Files\WindowsPowerShell\Modules'

if (-NOT (Test-Path $MachineModule)) {Copy-Item -Path $RemoteModule `
-Destination $moddest -Recurse -Force}

$RemoteModuleHash = Get-ChildItem $RemoteModule -Recurse | Get-FileHash |
select @{Label="Path";Expression={$_.Path.Replace($RemoteModule,"")}},Hash
$MachineModuleHash = Get-ChildItem $MachineModule -Recurse | Get-FileHash |
select @{Label="Path";Expression={$_.Path.Replace($MachineModule,"")}},Hash
$moddiffEM = ''

Compare-Object $RemoteModuleHash $MachineModuleHash -Property Path,Hash `
-IncludeEqual -PassThru | Where-Object {$_.SideIndicator -ne '==' } |
ForEach-Object -process {
$moddiffEM = 'y'
}

if ($moddiffEM) {
Copy-Item -Path $RemoteModule -Destination $moddest -Recurse -Force
}

#Copy Endpoint Configuration Files
$RemoteConfiguration = "Path_To_My_Jea_Configuration"
$LocalConfiguration = 'C:\ProgramData\JEAConfiguration'

$JeaDestination = 'C:\ProgramData'

if (-NOT (Test-Path $LocalConfiguration)) {
Copy-Item -Path $RemoteConfiguration -Destination $JeaDestination -Recurse `
-Force
Register-PSSessionConfiguration -Path `
"$LocalConfiguration\MyJeaConfiguration.pssc" -name EM -Force
}

if (-NOT (Test-Path $LocalConfiguration\*.pssc)) {
Copy-Item -Path $RemoteConfiguration -Destination $JeaDestination -Recurse `
-Force
Register-PSSessionConfiguration -Path `
"$LocalConfiguration\MyJeaConfiguration.pssc" -name EM -Force
}

$RemoteConfigurationHash = Get-ChildItem $RemoteConfiguration -Recurse |
Get-FileHash | select @{Label="Path";
Expression={$_.Path.Replace($RemoteConfiguration,"")}},Hash
$LocalConfigurationHash = Get-ChildItem $LocalConfiguration -Recurse |
Get-FileHash | select @{Label="Path";
Expression={$_.Path.Replace($LocalConfiguration,"")}},Hash
$jeadiffEM = ''

Compare-Object $RemoteConfigurationHash $LocalConfigurationHash `
-Property Path,Hash -IncludeEqual -PassThru |
Where-Object {$_.SideIndicator -ne '==' } |
ForEach-Object -process {
$jeadiffEM = 'y'
}

if ($jeadiffEM) {
Copy-Item -Path $RemoteConfiguration -Destination $JeaDestination -Recurse `
 -Force
Register-PSSessionConfiguration `
-Path "$LocalConfiguration\MyJeaConfiguration.pssc" -name EM -Force
}