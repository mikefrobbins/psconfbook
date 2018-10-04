$measured = [System.Collections.Generic.List[System.TimeSpan]]::new()

foreach ($run in (0..9))
{
    [System.GC]::Collect()
    $newArray = @()
    $measure = Measure-Command -Expression {
        foreach ($int in (0..4999))
        {
            $newArray += $int
        }
    }
    $measured.Add($measure)
}

$measured | Out-MeasureResult | Format-List
