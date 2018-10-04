# ForEach-Object

$LookupIDs = 45355,78999
$measured = [System.Collections.Generic.List[System.TimeSpan]]::new()

foreach ($run in (0..9))
{
    [gc]::Collect()
    $measure = Measure-Command -Expression {
        $csvObjects | ForEach-Object {
            if ($_.Id -in $LookupIDs) {
                $_
            }
        }
    }
    $measured.Add($measure)
}

$measured | Out-MeasureResult | Format-List

#Foreach statement

$LookupIDs = 45355,78999
$measured = [System.Collections.Generic.List[System.TimeSpan]]::new()

foreach ($run in (0..9))
{
    [gc]::Collect()
    $measure = Measure-Command -Expression {
        foreach ($object in $csvObjects)  
        {
            if ($object.Id -in $LookupIDs)
            {
                $object
            }
        }
    }
    $measured.Add($measure)
}

$measured | Out-MeasureResult | Format-List