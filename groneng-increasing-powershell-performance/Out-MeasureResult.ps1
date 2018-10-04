function Out-MeasureResult
{
<#
.Synopsis
   Outputs an object that shows maximum, minimum and average of an collection of 
   System.TimeSpan objects.
.EXAMPLE
    $measured = [System.Collections.Generic.List[System.TimeSpan]]::new()
    foreach ($run in (0..9))
    {
        [System.GC]::Collect()

        $measure = Measure-Command -Expression {
            $stringBuilder = [System.Text.StringBuilder]::new()
            foreach ($int in (0..10000))
            {
                $stringBuilder.Append(" ")
            }
        }
        $measured.Add($measure)
    }

    $measured | Out-MeasureResult

    MaxMilliseconds MinMilliseconds AvgMilliseconds
    --------------- --------------- ---------------
          2570,0842       1852,0017      2241,86343

.INPUTS
   Accepts an System.TimeSpan object or a collection of System.TimeSpan objects
#>
[cmdletbinding()]
Param(
    [Parameter(ValueFromPipeline)]
    [System.Timespan[]]
    $Measurement
)
    Begin
    {
        $list = [System.Collections.Generic.List[System.TimeSpan]]::new()
    }

    Process
    {
        if ($Measurement -is [array])
        {
            $list.AddRange($Measurement)
        }
        else
        {
            $list.Add($Measurement)
        }
    }

    End
    {
        $max = ($list | Measure-Object -Property Ticks -Maximum).Maximum
        $min = ($list | Measure-Object -Property Ticks -Minimum).Minimum
        $avg = $list | Measure-Object -Property TotalMilliseconds -Average
        $maxObj = $list.Where({$_.Ticks -eq $max})
        $minObj = $list.Where({$_.Ticks -eq $min})
        [PSCustomObject]@{
            MaxMilliseconds = [int]$maxObj.TotalMilliseconds
            MinMilliseconds = [int]$minObj.TotalMilliseconds
            AvgMilliseconds = [int]$avg.Average
        }
    }
}