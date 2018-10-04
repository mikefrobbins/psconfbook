$Date = Get-Date
$csvObjects = foreach($int in (0..99999))
{
    [PSCustomObject]@{
        Id = $int + 10
        Msg = "this belongs to id $int"
        Date = $date.AddSeconds($int)
        Random = Get-Random
        Ticks = $date.AddTicks($int).Ticks
    }
}