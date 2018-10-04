Using namespace System.Windows.Controls

Import-Module -Name WPFBot3000 -Force
Import-Module -Name contextsensitivemenus -Force

write-host 'Retrieving List of Modules, please be patient'
$modules = Get-Module -ListAvailable

$listViewAction={
    $l=$this.Window.GetControlByName('Commands')
    if(-not $l){return}
    $l.Items.Clear()
    if($this.SelectedItem){
        $moduleName=$this.SelectedItem.ToString()
        Import-module $moduleName
        (Get-Module $moduleName|
         select-object -expand ExportedCommands).Values | foreach-object {
            $lvi=new-object ListBoxItem -Property @{ Content=$_.Name
                                                     Tag=$_ }
            $l.Items.Add($_) | out-null
        }
    }
}

$w=window {
    ComboBox ModuleName -contents (get-Module -ListAvailable)`
        -property @{MinWidth=100}
    ListBox Commands -property @{MinWidth=100;MaxHeight=300}

} -Events @{Name='ModuleName'
            EventName='SelectionChanged'
            Action=$listViewAction
           }
Add-TypeMenuItem -typename System.Management.Automation.CommandInfo `
     -items @{'Show Command'={Show-Command $args[0]}
              'Get-Help'={Get-Help $args[0].Name}
             }
Add-ContextMenuToControl -window $w -controlName Commands

$w.ShowDialog() | out-null