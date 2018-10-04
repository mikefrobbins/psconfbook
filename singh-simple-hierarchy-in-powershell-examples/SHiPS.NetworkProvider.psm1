using namespace Microsoft.PowerShell.SHiPS

[SHiPSProviderAttribute(UseCache=$true)]
class Network : SHiPSDirectory{
    Network([string]$name): base([string]$name){
    }

    [object[]] GetChildItem(){
        $obj =  @()
        $obj += [IP]::new()
        $obj += [Adapter]::new()
        $obj += [Route]::new()
        return $obj;
    }
}

[SHiPSProvider()]
class IP : SHiPSDirectory{
    IP () : base ("IP"){
    }

    [Object[]] GetChildItem(){
        $obj =  @()
        $obj += [IPAddress]::new()
        $obj += [Config]::new()
        return $obj;
    }
}

[SHiPSProvider()]
class Config : SHiPSDirectory{
    Config () : base ("Config"){
    }

    [Object[]] GetChildItem(){
        $Obj = @()
        $Obj += Get-NetIPConfiguration
        return $obj
    }
}


[SHiPSProvider()]
class IPAddress : SHiPSDirectory{
    IPAddress () : base ("IPAddress"){
    }

    [Object[]] GetChildItem(){
        $Obj = @()
        $Obj += Get-NetIPAddress | Select-Object interface*, IPAddress, *length
        return $obj
    }
}

[SHiPSProvider()]
class Adapter : SHiPSDirectory{
    Adapter () : base ("Adapter"){
    }

    [Object[]] GetChildItem(){
        $obj =  @()
        $obj += [Property]::new()
        $obj += [AdvancedProperty]::new()
        $obj += [Binding]::new()
        return $obj;
    }
}

# define dynamic parameters
[SHiPSProvider()]
class DynamicParam
{
    [Parameter()]
    [ValidateSet($true, $false)] $Connected
}

[SHiPSProvider()]
class Property : SHiPSDirectory{
    Property () : base ("Property"){
    }

    [Object[]] GetChildItem(){
        $obj =  @()
        $Param = $this.ProviderContext.DynamicParameters -as [DynamicParam]
        if($Param.Connected -eq $true){
            $obj += Get-NetAdapter | Where-Object MediaConnectionState -eq Connected
        }
        elseif($Param.Connected -eq $false){
            $obj += Get-NetAdapter | Where-Object MediaConnectionState -ne Connected
        }
        else{
            $obj += Get-NetAdapter
        }
        return $obj | Select-Object Name, InterfaceIndex, InterfaceDescription, Status, MacAddress
    }

    [Object[]] GetChildItemDynamicParameters(){
        return [DynamicParam]::new()
    }
}

[SHiPSProvider()]
class AdvancedProperty : SHiPSDirectory{
    AdvancedProperty () : base ("AdvancedProperty"){
    }

    [Object[]] GetChildItem(){
        $obj =  @()
        $obj += Get-NetAdapterAdvancedProperty
        return $obj;
    }
}

[SHiPSProvider()]
class Binding : SHiPSDirectory{
    Binding () : base ("Binding"){
    }

    [Object[]] GetChildItem(){
        $obj =  @()
        $obj += Get-NetAdapterBinding
        return $obj
    }
}

[SHiPSProvider()]
class Route : SHiPSDirectory{
    Route () : base ("Route"){
    }

    [Object[]] GetChildItem(){
        $obj =  @()
        $obj += Get-NetRoute
        return $obj;
    }
}


# Export only the functions using PowerShell standard verb-noun naming.
# Be sure to list each exported functions in the FunctionsToExport field of the module manifest file.
# This improves performance of command discovery in PowerShell.
Export-ModuleMember -Function *-*
