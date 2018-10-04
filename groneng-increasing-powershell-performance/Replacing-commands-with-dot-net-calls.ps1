# Measuring performance of the 'Get-Random' cmdlet

$measured =  $measured = [System.Collections.Generic.List[System.TimeSpan]]::new()

foreach ($run in (0..9))
{
    [System.GC]::Collect()
    $measure = Measure-Command -Expression {
        foreach ($int in (0..9999))
        {
            Get-Random
        }
    }
    $measured.Add($measure)
}

$measured | Out-MeasureResult | Format-List


# Measuring performance of the 'System.Random' class

$measuredDotNet = [System.Collections.Generic.List[System.TimeSpan]]::new()

foreach ($run in (0..9))
{
    [System.GC]::Collect()
    $measure = Measure-Command -Expression {
        $randomGenerator = [System.Random]::new()
        foreach ($int in (0..9999))
        {
            $randomGenerator.Next()
        }
    }
    $measuredDotNet.Add($measure)
}

$measuredDotNet | Out-MeasureResult | Format-List


# Measuring performance of the 'Random' cmdlet (short for 'Get-Random')

$measured = [System.Collections.Generic.List[System.TimeSpan]]::new()

foreach ($run in (0..9))
{
    [System.GC]::Collect()
    $measure = Measure-Command -Expression {
        foreach ($int in (0..9999))
        {
            Random
        }
    }
    $measured.Add($measure)
}

$measured | Out-MeasureResult | Format-List