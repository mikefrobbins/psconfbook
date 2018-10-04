Import-Module -Name WPFBot3000
Import-Module -Name ContextSensitiveMenus -force
#associate these menu items with "Service" objects
$items=@{
          Start={$args[0] | Start-Service}
          Stop={$args[0] | Stop-Service}
          Status={$args[0] | Get-Service}
}
Add-TypeMenuItem -typename System.ServiceProcess.ServiceController -items $items

#associate this menu item with System.Object (all objects get this)
$default_items=@{ShowProperties ={$args[0]| select-object *}}
Add-TypeMenuItem -typename System.Object -items $default_items

$w=Window {
   ListBox Services -Contents (get-service) -Property @{MaxHeight=400}
}

Add-ContextMenuToControl -Window $w -ControlName Services

$w.ShowDialog() | out-null