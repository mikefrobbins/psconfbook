##  Simple threading, no helper functions

#  Define input parameters
$Parameters = @{ MyParam1 = 2 }

#  Define thread script
$Scriptblock = { Param ( $MyParam1 ) return [pscustomobject]@{ X = $MyParam1; X2 = $MyParam1 * 2 } }

#  Create runspace pool
$RunspacePool = [runspacefactory]::CreateRunspacePool( 1, 1 )
$RunspacePool.Open()

#  Create thread
$PowerShell = [PowerShell]::Create()
$PowerShell.RunspacePool = $RunspacePool
    
#  Add script
[void]$PowerShell.AddScript( $Scriptblock )
    
#  Add parameters
[void]$PowerShell.AddParameters( $Parameters )
    
#  Start thread
$Handler = $PowerShell.BeginInvoke()

#  Wait for completion
While ( -not $Handler.IsCompleted ) { Start-Sleep -Milliseconds 100 }

#  Get result
$Result = $PowerShell.EndInvoke( $Handler )

# Clean up
$PowerShell.Dispose()
$RunspacePool.Dispose()