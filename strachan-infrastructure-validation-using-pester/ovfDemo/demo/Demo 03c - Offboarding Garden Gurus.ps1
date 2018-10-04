#region New onboarding Customer
Import-Module C:\scripts\modules\ovfDemo\ovfDemo.psm1

$paramCustomer = @{
    CustomerName = 'Garden Gurus'
    CustomerCode = '014456'
    TicketNr     = '20180327002'
}

Write-Host "Offboarding customer $($paramCustomer.CustomerName)" -ForegroundColor Magenta
New-OffBoard @paramCustomer -Verbose
Pause
Clear-Host

Write-Host "Running Offboard OVF test for $($paramCustomer.CustomerName)" -ForegroundColor Magenta
Test-OffBoard @paramCustomer
Write-Host 'Sending slack notification' -ForegroundColor Magenta
Send-SlackOvfNotification @paramCustomer -Mode Offboard
#Send-TeamsOvfNotification @paramCustomer -Mode Offboard
Pause
Clear-Host

Write-Host "Offboarding customer  folders for $($paramCustomer.CustomerName)" -ForegroundColor Magenta
New-OffBoardFolders -FileServer WIN2k16-001 @paramCustomer -Verbose
Pause
Clear-Host

Write-Host "Running OffboardFolders OVF test for $($paramCustomer.CustomerName)" -ForegroundColor Magenta
Test-OffBoardFolders -FileServer WIN2k16-001 @paramCustomer
Write-Host 'Sending slack notification' -ForegroundColor Magenta
Send-SlackOvfNotification @paramCustomer -Mode OffboardFolders
#Send-TeamsOvfNotification @paramCustomer -Mode OffboardFolders
#endregion
