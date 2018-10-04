##  Multi queue-based processing
##  With helper OutputThread function

#  Define variables
$ThreadCount = 5
$DateString  = (Get-Date).ToString( 'yyyy-MM-dd HH.mm.ss' )
$OutputPath  = "$Env:Temp\MultithreadingOutput.$DateString.csv"

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
    
#  Start Ouput thread
$OutputThread = Start-MadOutputThread -Queue $OutputQueue -Path $OutputPath

#  Send input
1..10 | ForEach-Object { $InputQueue.Add( $_ ) }

#  Close input queue
$InputQueue.CompleteAdding()

#  Wait for completion
Wait-MadThread -Thread $Threads

#  Close input queue
$OutputQueue.CompleteAdding()

#  Wait for completion
Wait-MadThread -Thread $OutputThread