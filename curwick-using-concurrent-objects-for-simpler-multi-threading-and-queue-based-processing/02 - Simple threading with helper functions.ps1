#  Simple threading with helper functions

#  Define input parameters
$MyParam1 = 2

#  Define thread script
$Scriptblock = { Param ( $MyParam1 ) return [pscustomobject]@{ X = $MyParam1; X2 = $MyParam1 * 2 } }

#  Create runspace pool
$RunspacePool = [runspacefactory]::CreateRunspacePool( 1, 1 )
$RunspacePool.Open()

#  Create and start thread
$Thread = New-MadThread -ScriptBlock $Scriptblock -RunspacePool $RunspacePool -UseEmbeddedParameters
    
#  Wait for completion
Wait-MadThread -Thread $Thread -NoDispose

#  Get result
$Result = $Thread.PowerShell.EndInvoke( $Thread.Handler )

# Clean up
$PowerShell.Dispose()
$RunspacePool.Dispose()