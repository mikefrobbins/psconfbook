$measured = [System.Collections.Generic.List[System.TimeSpan]]::new()

foreach ($run in (0..9))
{
    [System.GC]::Collect()
    $newList = [System.Collections.Generic.List[int]]::new()
    $measure = Measure-Command -Expression {
        foreach ($int in (0..4999))
        {
            $newList.Add($int)
        }
    }
    $measured.Add($measure)
}

$measured | Out-MeasureResult | Format-List