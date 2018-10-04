Using namespace System.Windows
Using namespace System.Windows.Controls
Add-Type -AssemblyName PresentationFramework

#Create a window
$properties=@{Property=@{ SizeToContent = 'WidthAndHeight'}}
$w = New-Object Window @Properties

$margin=@{Margin=new-object Thickness(10,0,0,10)}

$lbl=new-object Label -Property $Margin
$lbl.Content='Enter your name'

$txtName=new-object TextBox -Property $Margin
$txtName.Name='txtName'
$txtName.Text='Name'

$lblGreeting=new-object Label -Property $Margin
$lblGreeting.Content='Hello, World'

$btnPersonalize=new-object Button -Property $Margin
$btnPersonalize.Content='Personalize'
$btnPersonalize.Add_Click({$lblGreeting.Content="Hello, $($txtName.Text)"})

$stack=new-object StackPanel -Property @{Margin=new-object Thickness(5)}
$stack.Children.Add($lbl)
$stack.Children.Add($txtName)
$stack.Children.Add($btnPersonalize)
$stack.Children.Add($lblGreeting)

$w.Content=$stack

$w.ShowDialog() | out-null