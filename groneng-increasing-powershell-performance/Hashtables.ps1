# Converting sample data to a hash table

$measured = [System.Collections.Generic.List[System.TimeSpan]]::new()

foreach ($run in (0..9))
{
    $csvHash = @{}
    [System.GC]::Collect()
    $measure = Measure-Command -Expression {
        foreach($object in $csvObjects)
        {
            $csvHash[$object.Id] = $object
        }
    }
    $measured.Add($measure)
}

$measured | Out-MeasureResult | Format-List

# Measuring hash table performance

$lookupIDs = 45355,78999
$measured = [System.Collections.Generic.List[System.TimeSpan]]::new()

foreach ($run in (0..9))
{
    [System.GC]::Collect()
    $measure = Measure-Command -Expression {
        $csvHash[$LookupIDs]
    }
    $measured.Add($measure)
}

$measured | Out-MeasureResult | Format-List
