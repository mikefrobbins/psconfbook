##  ConcurrentQueue for communication with thread

#  Define concurrent variables
$InputQueue  = [System.Collections.Concurrent.ConcurrentQueue[int]]@{}
$OutputQueue = [System.Collections.Concurrent.ConcurrentQueue[psobject]]@{}

#  Send input
1..10 | ForEach-Object { $InputQueue.Enqueue( $_ ) }

#  Define thread script
$Scriptblock = {
    Param (
        [System.Collections.Concurrent.ConcurrentQueue[int]]$InputQueue,
        [System.Collections.Concurrent.ConcurrentQueue[psobject]]$OutputQueue )
    
    $Item = 0

    While ( $InputQueue.TryDequeue( [ref]$Item ) )
        {
        Start-Sleep -Milliseconds (Get-Random 100)

        $OutputQueue.Enqueue( [pscustomobject]@{
            X  = $Item
            X2 = $Item * 2 } )
        }
    }

#  Create runspace pool
$RunspacePool = [runspacefactory]::CreateRunspacePool( 1, 1 )
$RunspacePool.Open()

#  Create and start thread
$Thread = New-MadThread -ScriptBlock $Scriptblock -RunspacePool $RunspacePool -UseEmbeddedParameters
    
#  Wait for completion
Wait-MadThread -Thread $Thread

#  Get result
$Result = [array]$OutputQueue