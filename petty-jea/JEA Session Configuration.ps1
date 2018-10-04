New-PSSessionConfigurationFile -path "env:ProgramData\JEAConfiguration\demo.pssc"



$ConfFileData = @{
    SessionType = "RestrictedRemoteServer"
    TranscriptDirectory = "C:\ProgramData\JEATranscripts"
    RunAsVirtualAccount = $true
    Path = "$env:ProgramData\JEAConfiguration\Demo.pssc"
}
New-PSSessionConfigurationFile @ConfFileData