##  NTFS permissions - Single threaded

function Get-MyACL
   {
   [cmdletbinding()]
   Param (
       [string]$Path,
       [string]$OutputPath )
   
   Get-ChildItem -Path $Path -Recurse |
       ForEach-Object {
           $ACL = Get-ACL -Path $_.Fullname

           ForEach ( $Permission in $ACL.Access )
               {
               If ( -not $Permission.IsInherited )
                   {
                   [pscustomobject]@{
                       Path              = $_.FullName
                       IdentityReference = [string]$Permission.IdentityReference
                       AccessControlType = [string]$Permission.AccessControlType
                       FileSystemRights  = [string]$Permission.FileSystemRights }
                   }
               }
           } |
       Export-CSV -Path $OutputPath -NoTypeInformation
   }

$Timer = [System.Diagnostics.Stopwatch]::StartNew()

Get-MyACL -Path 'C:\Temp\tree' -OutputPath 'C:\Temp\ACLReport1.csv'

[string]$Timer.Elapsed