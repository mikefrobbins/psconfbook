$Telnet = @{
    TypeName   = "System.Management.Automation.ScriptBlock"
    MemberType = "ScriptMethod"
    MemberName = "TestPortConnection"
    Value      = {
        param ([int] $port)
        try {
            $return = [System.Net.Sockets.TcpClient]::new($this, $port)
            [PSCustomObject]@{
                Host      = $this
                Port      = $port
                Connected = $return.Connected
            }
        } catch {
            Throw "Error: No connection to $this on Port $port"
        }
    }
    Force      = $true
}

Update-TypeData @Telnet