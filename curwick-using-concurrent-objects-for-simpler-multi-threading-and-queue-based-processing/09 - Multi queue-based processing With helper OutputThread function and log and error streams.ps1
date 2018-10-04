##  Multi queue-based processing
##  With helper OutputThread function and log and error "streams"

#  Define variables
$ThreadCount = 5
$DateString  = (Get-Date).ToString( 'yyyy-MM-dd HH.mm.ss' )
$OutputPath  = "$Env:Temp\MultithreadingOutput.$DateString.Output.csv"
$ErrorPath   = "$Env:Temp\MultithreadingOutput.$DateString.Error.csv"
$LogPath     = "$Env:Temp\MultithreadingOutput.$DateString.Log.csv"

#  Define concurrent variables
$InputQueue  = [System.Collections.Concurrent.BlockingCollection[int]]@{}
$OutputQueue = [System.Collections.Concurrent.BlockingCollection[psobject]]@{}
$ErrorQueue  = [System.Collections.Concurrent.BlockingCollection[psobject]]@{}
$LogQueue    = [System.Collections.Concurrent.BlockingCollection[psobject]]@{}

#  Define output streams
$Reports = @(
    @{ Queue = $OutputQueue; Path = $OutputPath }
    @{ Queue = $ErrorQueue ; Path = $ErrorPath }
    @{ Queue = $LogQueue   ; Path = $LogPath } )

#  Define thread script
$Scriptblock = {
    Param (
        [System.Collections.Concurrent.BlockingCollection[int]]$InputQueue,
        [System.Collections.Concurrent.BlockingCollection[psobject]]$OutputQueue,
        [System.Collections.Concurrent.BlockingCollection[psobject]]$ErrorQueue,
        [System.Collections.Concurrent.BlockingCollection[psobject]]$LogQueue )
    
    #  Function to write to log queue
    function Write-Log ( $Text )
        {
        $LogQueue.Add( [pscustomobject]@{
            Date     = Get-Date
            ThreadID = $ThreadID
            Entry    = $Text } )
        }

    #  Function to write to error queue
    function Write-ErrorLog ( [string]$Text, $ErrorRecord )
        {
        #  Define error output object
        $ErrorObject = [pscustomobject]@{
            Date     = Get-Date
            ThreadID = $ThreadID
            Entry    = $Text
            ExceptionMessage = ''
            ExceptionType    = ''
            InnerExceptionMessage = '' }

        #  If an error record was included
        #    Add error record information to error object
        If ( $ErrorRecord -is [System.Management.Automation.ErrorRecord] )
            {
            $ErrorObject.ExceptionMessage      = $ErrorRecord.Exception.Message
            $ErrorObject.ExceptionType         = $ErrorRecord.Exception.GetType()
            $ErrorObject.InnerExceptionMessage = $ErrorRecord.Exception.InnerException.Message
            }

        #  Add error to error queue
        $ErrorQueue.Add( $ErrorObject )
        }

    #  Get thread ID for current thread
    $ThreadID = [appdomain]::GetCurrentThreadId()

#  For each item in input queue
ForEach ( $Item in $InputQueue.GetConsumingEnumerable() )
    {
        try
            {
            Write-Log -Text "Processing item [$Item]."

            #  Randomly throw error to test error queue
            If ( (Get-Random 3) -eq 0 )
                {
                1/0
                }

            `
            Write-Log -Text "Success processing item [$Item]."
            }
        catch
            {
            #  Log error
            $ErrorText = "Error processing item [$Item]."
            Write-Log      -Text $ErrorText
            Write-ErrorLog -Text $ErrorText -ErrorRecord $_
            }
        }
    }

#  Create runspace pool
$RunspacePool = [runspacefactory]::CreateRunspacePool( 1, $ThreadCount )
$RunspacePool.Open()

#  Create and start thread
ForEach ( $i in 1..$ThreadCount )
    {
    $Thread = New-MadThread -ScriptBlock $Scriptblock -RunspacePool $RunspacePool -UseEmbeddedParameters
    }
    
#  Start Ouput thread
$OutputThread = Start-MadOutputThread -Reports $Reports

#  Send input
1..10 | ForEach-Object { $InputQueue.Add( $_ ) }

#  Close input queues
$InputQueue.CompleteAdding()

#  Wait for completion
Wait-MadThread -Thread $Thread

#  Close output queues
$OutputQueue.CompleteAdding()
$ErrorQueue. CompleteAdding()
$LogQueue.   CompleteAdding()

#  Wait for completion
Wait-Thread -Thread $OutputThread