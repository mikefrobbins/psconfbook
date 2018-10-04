function Select-UniqueObject
{
[cmdletbinding()]
Param(
    [Parameter(ValueFromPipeline)]
    [object[]]
    $Inputobject
)
Begin
{
    $hashtable = @{}
}

Process
{
    foreach($element in $Inputobject)
    {
        if (-not $hashtable.ContainsKey($element))
        {
            $hashtable.Add($element, [string]::Empty)
        }
    }
}

End
{
    $hashtable.Keys
}

}