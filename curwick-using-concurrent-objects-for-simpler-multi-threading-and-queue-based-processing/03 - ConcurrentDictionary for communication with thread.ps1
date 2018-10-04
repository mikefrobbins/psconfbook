##  ConcurrentDictionary for communication with thread

#  Define concurrent variables
$SharedValues = [System.Collections.Concurrent.ConcurrentDictionary[string,psobject]]@{}
$SharedValues['Input'] = 2

#  Define thread script
$Scriptblock = {
    Param ( [System.Collections.Concurrent.ConcurrentDictionary[string,psobject]]$SharedValues )

    $SharedValues['Output'] = [pscustomobject]@{
        X  = $SharedValues['Input']
        X2 = $SharedValues['Input'] * 2 } }

#  Create runspace pool
$RunspacePool = [runspacefactory]::CreateRunspacePool( 1, 1 )
$RunspacePool.Open()

#  Create and start thread
$Thread = New-MadThread -ScriptBlock $Scriptblock -RunspacePool $RunspacePool -UseEmbeddedParameters
    
#  Wait for completion
Wait-MadThread -Thread $Thread

#  Get result
$Result = $SharedValues['Output']