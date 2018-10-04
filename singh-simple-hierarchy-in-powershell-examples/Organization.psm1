using namespace Microsoft.PowerShell.SHiPS

# root directory
class Org : SHiPSDirectory
{
    Org([string]$name): base([string]$name){}

    # GetChildItem() method is implemented in root class
    # to return department directories as child nodes
    [object[]] GetChildItem(){
        $obj =  @()
        $obj += [Finance]::new()
        $obj += [Marketing]::new()
        return $obj;
    }
}
# container or second level directory
class Finance : SHiPSDirectory
{
    Finance():base('Finance'){}
    [Object[]] GetChildItem(){
        $obj = @()
        $obj = [Bob]::new()
        return $obj
    }
}
# container or second level directory
class Marketing : SHiPSDirectory
{
    Marketing():base('Marketing'){}

    # GetChildItem() method is implemented in directory class
    # to return employees as leaf nodes
    [Object[]] GetChildItem(){
        $obj = @()
        $obj += [John]::new()
        $obj += [Bill]::new()
        return $obj
    }
}
# leaf node
class Bob : SHiPSLeaf
{
    # define 'static' variable $name
    # to return the value with property 'name' of the leaf node
    static $name = 'Bob'
    # your custom data can sit here as a property
    $data = [PSCustomObject]@{
                Id=101
                FirstName='Bob'
                LastName='Fracis'
            }
    # name of leaf node class passed to the base constructor
    Bob () : base ('Bob'){ }
}
# leaf node
class John : SHiPSLeaf
{
    static $name = 'John'
    $data = [PSCustomObject]@{
                Id=102
                FirstName='John'
                LastName='Hunt'
            }
    John () : base ('John'){ }
}
# leaf node
class Bill : SHiPSLeaf
{
    static $name = 'Bill'
    $data = [PSCustomObject]@{
                Id=103
                FirstName='Bill'
                LastName='Snyder'
            }
    Bill () : base ('Bill'){ }
}

# Export only the functions using PowerShell standard verb-noun naming.
Export-ModuleMember -Function *-*
