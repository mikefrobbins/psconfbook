##  Multi queue-based processing

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

#  Define output thread script
$OutputScriptblock = {
    Param (
        [System.Collections.Concurrent.BlockingCollection[psobject]]$OutputQueue,
        [string]$OutputPath )
    
    ForEach ( $Item in $OutputQueue.GetConsumingEnumerable() )
        {
        $Item | Export-Csv -Path $OutputPath -NoTypeInformation -Append -Encoding UTF8
        }
    }

#  Threads to run concurrently
$ThreadCount = 5

#  Create runspace pool
$RunspacePool = [runspacefactory]::CreateRunspacePool( 1, $ThreadCount )
$RunspacePool.Open()

#  Create and start thread
$Threads = @()
ForEach ( $i in 1..$ThreadCount )
    {
    $Threads += New-MadThread -ScriptBlock $Scriptblock -RunspacePool $RunspacePool -UseEmbeddedParameters
    }
    
#  Create runspace pool
$RunspacePool = [runspacefactory]::CreateRunspacePool( 1, 1 )
$RunspacePool.Open()

#  Start Ouput thread
$OutputThread = New-MadThread -ScriptBlock $OutputScriptblock -RunspacePool $RunspacePool -UseEmbeddedParameters

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