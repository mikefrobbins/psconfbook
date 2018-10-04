# Collection ForEach method

$lookupIDs = 45355,78999
$measured = [System.Collections.Generic.List[System.TimeSpan]]::new()

foreach ($run in (0..9))
{
    [gc]::Collect()
    $measure = Measure-Command -Expression {
        $csvObjects.ForEach({
            if ($_.Id -in $LookupIDs) {
                $_
            }
        })
    }
    $measured.Add($measure)
}

$measured | Out-MeasureResult | Format-List


# Collection Where method

$lookupIDs = 45355,78999
$measured = [System.Collections.Generic.List[System.TimeSpan]]::new()

foreach ($run in (0..9))
{
    [gc]::Collect()
    $measure = Measure-Command -Expression {
        $csvObjects.Where({
            $_.Id -in $LookupIDs
        })
    }
    $measured.Add($measure)
}

$measured | Out-MeasureResult | Format-List