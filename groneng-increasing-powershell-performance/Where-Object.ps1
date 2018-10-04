$lookupIDs = 45355,78999
$measured = [System.Collections.Generic.List[System.TimeSpan]]::new()

foreach ($run in (0..9))
{
    [gc]::Collect()
    $measure = Measure-Command -Expression {
        $csvObjects | Where-Object Id -in $LookupIDs
    }
    $measured.Add($measure)
}

$measured | Out-MeasureResult | Format-List
