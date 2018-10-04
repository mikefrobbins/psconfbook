# Generate random string integers

$random = [System.Random]::new()
$stringList = [System.Collections.Generic.List[String]]::new()

foreach ($int in (0..4998))
{
    $randomNumber = $random.Next(0, 999888777)
    $stringList.Add("$randomNumber")
}
$stringList.Add($stringList[4998])


# Measuring Select-Object performance

$measured = [System.Collections.Generic.List[System.TimeSpan]]::new()

foreach ($run in (0..9))
{
    [System.GC]::Collect()
    $newList = [System.Collections.Generic.List[int]]::new()
    $measure = Measure-Command -Expression {
        $stringList | Select-Object -Unique
    }
    $measured.Add($measure)
}

$measured | Out-MeasureResult | Format-List


# Measuring Select-Object performance without the pipeline

$measured = [System.Collections.Generic.List[System.TimeSpan]]::new()

foreach ($run in (0..9))
{
    [System.GC]::Collect()
    $newList = [System.Collections.Generic.List[int]]::new()
    $measure = Measure-Command -Expression {
        $uniqueObjects = Select-Object -Unique -InputObject $stringList
    }
    $measured.Add($measure)
}

$measured | Out-MeasureResult | Format-List


# Measuring Select-UniqueObject function

$measured = [System.Collections.Generic.List[System.TimeSpan]]::new()

foreach ($run in (0..9))
{
    [System.GC]::Collect()
    $newList = [System.Collections.Generic.List[int]]::new()
    $measure = Measure-Command -Expression {
        $uniqueObjects = Select-UniqueObject -Inputobject $stringList
    }
    $measured.Add($measure)
}

$measured | Out-MeasureResult | Format-List
