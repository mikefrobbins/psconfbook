$Grouping = $Results | Group-Object Type

foreach ($Obj in $Grouping) {
    #$Obj
    
    [System.Collections.ArrayList]$AvgResults = @()
    foreach ($Row in $Obj.Group) {
        if ($Row.Minutes -gt 0) {
            $CalcTime = [timespan]("$($Row.Minutes):$($Row.Seconds)")
            $CalcTime = $CalcTime + [timespan]::FromMilliseconds($Row.Milliseconds)
            [void]$AvgResults.Add($CalcTime)
        } else {
            $CalcTime = [timespan]("00:00:$($Row.Seconds)")
            $CalcTime = $CalcTime + [timespan]::FromMilliseconds($Row.Milliseconds) 
            [void]$AvgResults.Add($CalcTime)
        }
    }

    [PSCustomObject]@{
        Type = $Obj.Group.Type[0]
        Minutes = ($AvgResults.TotalMilliseconds | Measure-Object -Average).Average / 60000
        Seconds = ($AvgResults.TotalMilliseconds | Measure-Object -Average).Average / 1000
    }
}