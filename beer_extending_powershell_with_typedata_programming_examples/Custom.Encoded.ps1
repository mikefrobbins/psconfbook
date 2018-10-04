$CustomType = @{
    TypeName   = "Custom.Encoded"
    MemberType = "ScriptProperty"
    MemberName = "EncodedCommand"
    Value      = {
        [convert]::ToBase64String(
            [System.Text.Encoding]::Unicode.GetBytes($this.String)
        )
    }
    Force      = $true
}

Update-TypeData @CustomType