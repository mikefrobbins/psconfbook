#Requires -RunAsAdministrator

# Create a temporary test user
New-LocalUser -Name test -Password (
    ConvertTo-SecureString -String 'test' -AsPlainText -Force
)

# Add this user to the local administrators group
Add-LocalGroupMember -Group Administrators -Member test

# View local administrators group members
Get-LocalGroupMember -Group Administrators

# Run the removal task
Start-ScheduledTask -TaskName MMA-Safeguard

# View local administrators group members
Get-LocalGroupMember -Group Administrators

#
Get-Content -Path C:\Windows\demo.log

Import-Csv -Path C:\Windows\demo.log -Delimiter ";" -Header @(
    'Date','UID','SID','UserName','Action','Computer'
 ) |
 Out-GridView
