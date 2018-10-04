##  NTFS permissions - Multi threaded, helper functions

function Get-MyACL2
    {
    [cmdletbinding()]
    Param (
        [parameter( ValueFromPipeline = $True )]
        [string]$Path )
    
    Process
        {
        $ACL = Get-ACL -Path $Path

        ForEach ( $Permission in $ACL.Access )
            {
            If ( -not $Permission.IsInherited )
                {
                [pscustomobject]@{
                    Path              = $Path
                    IdentityReference = [string]$Permission.IdentityReference
                    AccessControlType = [string]$Permission.AccessControlType
                    FileSystemRights  = [string]$Permission.FileSystemRights }
                }
            }
        }
    }


$Timer = [System.Diagnostics.Stopwatch]::StartNew()

Get-ChildItem -Path 'C:\Temp\tree' -Recurse |
    Select-Object -ExpandProperty FullName |
    Invoke-MadMultithread Get-MyACL2 |
    Export-CSV -Path 'C:\Temp\ACLReport2.csv' -NoTypeInformation

[string]$Timer.Elapsed
$Timer.Restart()

Get-ChildItem -Path 'C:\Temp\tree' -Recurse |
    Select-Object -ExpandProperty FullName |
    Invoke-MadMultithread Get-MyACL2 -Threads 4 |
    Export-CSV -Path 'C:\Temp\ACLReport2.csv' -NoTypeInformation

[string]$Timer.Elapsed