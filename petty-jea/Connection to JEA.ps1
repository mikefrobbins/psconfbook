Register-PSSessionConfiguration -Name HelpDesk -Path "C:\ProgramData\JEAConfiguration\HelpDesk.pssc"

Enter-PSSession -ComputerName SRV1 -ConfigurationName HelpDesk -Credentials Demo\User1