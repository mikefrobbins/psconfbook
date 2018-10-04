##  BlockingCollection for communications with threads

#  Define variables
$ThreadCount = 5

#  Define concurrent variables
$InputQueue  = [System.Collections.Concurrent.BlockingCollection[int]]@{}
$OutputQueue = [System.Collections.Concurrent.BlockingCollection[psobject]]@{}

#  Define thread script
$Scriptblock = {
    Param (
        [System.Collections.Concurrent.BlockingCollection[int]]$InputQueue,
        [System.Collections.Concurrent.BlockingCollection[psobject]]$OutputQueue )
    
    ForEach ( $Item in $InputQueue.GetConsumingEnumerable() )
        {
        $OutputQueue.Add( [pscustomobject]@{
            X  = $Item
            X2 = $Item * 2 } )
        }
    }

#  Create runspace pool
$RunspacePool = [runspacefactory]::CreateRunspacePool( 1, $ThreadCount )
$RunspacePool.Open()

$Threads = @()

#  Create and start thread
ForEach ( $i in 1..$ThreadCount )
    {
    $Threads += New-MadThread -ScriptBlock $Scriptblock -RunspacePool $RunspacePool -UseEmbeddedParameters
    }
    
#  Send input
1..10 | ForEach-Object { $InputQueue.Add( $_ ) }

#  Close input queue
$InputQueue.CompleteAdding()

#  Wait for completion
Wait-MadThread -Thread $Threads

#  Get result
$Result = [array]$OutputQueue