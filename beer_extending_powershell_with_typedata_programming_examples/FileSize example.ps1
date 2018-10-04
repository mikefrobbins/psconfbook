Get-ChildItem -Path $env:USERPROFILE\Downloads -File |
    Select-Object -Property Name, FileSize