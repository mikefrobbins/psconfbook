##  NTFS permissions - Multi threaded, custom

function Get-MyACLMT
    {
    [cmdletbinding()]
    Param (
        [string]$Path,
        [string]$OutputPath,
        [int]$ThreadCount = 2 )

    #  Define concurrent variables
    $InputQueue  = [System.Collections.Concurrent.BlockingCollection[string]]@{}
    $OutputQueue = [System.Collections.Concurrent.BlockingCollection[psobject]]@{}

    #  Define File Processor script
    $Scriptblock = {
       Param (
          [System.Collections.Concurrent.BlockingCollection[string]]$InputQueue,
          [System.Collections.Concurrent.BlockingCollection[psobject]]$OutputQueue )

        ForEach ( $Path in $InputQueue.GetConsumingEnumerable() )
            {
            $ACL = Get-ACL -Path $Path
        
            ForEach ( $Permission in $ACL.Access )
                {

                If ( -not $Permission.IsInherited )
                    {
                    $OutputQueue.Add( [pscustomobject]@{
                        Path              = $Path
                        IdentityReference = [string]$Permission.IdentityReference
                        AccessControlType = [string]$Permission.AccessControlType
                        FileSystemRights  = [string]$Permission.FileSystemRights } )
                    }
                }
            }
        }

    #  Create runspace pool
    $RunspacePool = [runspacefactory]::CreateRunspacePool( 1, $ThreadCount )
    $RunspacePool.Open()

    $Threads = @()

    #  Create and start thread
    ForEach ( $i in 1..$ThreadCount )
        {
        $Threads += New-MadThread `
            -ScriptBlock  $Scriptblock `
            -RunspacePool $RunspacePool `
            -UseEmbeddedParameters
        }

    #  Start Ouput thread
    $OutputThread = Start-MadOutputThread -Queue $OutputQueue -Path $OutputPath

    Get-ChildItem -Path $Path -File -Recurse |
        ForEach-Object {
            While ( $InputQueue.Count -gt 100 )
                {
                Start-Sleep -Milliseconds 10
                }
            $InputQueue.Add( $_.FullName ) }

    $InputQueue.CompleteAdding()

    #  Wait for completion
    Wait-MadThread -Thread $Threads

    ##  Close input queue
    $OutputQueue.CompleteAdding()
    
    ##  Wait for completion
    Wait-MadThread -Thread $OutputThread
    }


$Timer = [System.Diagnostics.Stopwatch]::StartNew()
Get-MyACLMT -Path 'C:\Temp\tree' -OutputPath 'C:\Temp\ACLReport2.csv' -ThreadCount 2

[string]$Timer.Elapsed
$Timer.Restart()

Get-MyACLMT -Path 'C:\Temp\tree' -OutputPath 'C:\Temp\ACLReport2.csv' -ThreadCount 4

[string]$Timer.Elapsed