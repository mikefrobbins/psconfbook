# -----
#region Public New-SinkProfileFixture
Function New-SinkProfileFixture {
<#
.SYNOPSIS
    The New-SinkProfileFixture function builds out the fixture code for the CurrentUserAllHosts proifle script.
.DESCRIPTION
    The CurrentUserAllHosts profile script for Windows PowerShell is located at C:\Users\<username>\Documents\WindowsPowerShell\profile.ps1. If this file already exists in this location, it will be backed up into the same directory location as profile.ps1.<Date>.bak. This function will use three default computer names to create the new profile.ps1 file. These computer names (computer1, computer2, and computer3) will likely not be the computers on which you inteded to use the synced profile. Therefore, be certain to include all the computer names when this function in invoked.
.PARAMETER ComputerName
    The ComputerName parameter accepts one, or more, comma-seperated computers name on which the resulting profile.ps1 profile script is intended to be used. Using this function against one computer defeats the purpose, as the idea behind the SinkProfile is to sync a CurrentUserAllHosts profile between multiple computers using a service such as Dropbox, Box, etc.
.EXAMPLE
    New-SinkProfileFixture -ComputerName WorkDesktop,HomeDesktop,HomeLaptop
        #region Code for all computers. 
        Switch ($env:COMPUTERNAME) {
            {$_ -eq 'WorkDesktop'} {
                # Enter code here for the "WorkDesktop" computer.
            }

            {$_ -eq 'HomeDesktop'} {
                # Enter code here for the "HomeDesktop" computer.
            }

            {$_ -eq 'HomeLaptop'} {
                # Enter code here for the "HomeLaptop" computer.
            }

            {$_ -eq 'WorkDesktop' -or $_ -eq 'HomeDesktop' -or $_ -eq 'HomeLaptop'} {
                # Enter code here for all 3 computers.
                $SinkProfile = $true
            }

            default {}
        } # End Switch.
        #endregion.

        #region Invoke Invoke-SinkProfileSync function.
        Invoke-SinkProfileSync
        #endregion.

        This example will create a Sink Profile CurrentUserAllHosts profile.ps1 profile script to be used on the above, included computers.
.NOTES
    Name: New-SinkProfileFixture
    Author: Tommy Maynard
#>
    [CmdletBinding()]
    Param (
        [Parameter()]
        [string[]]$ComputerName = ('computer1','computer2','computer3')
    )

    Begin {
        Write-Verbose -Message 'Determining the existence of the $PROFILE variable.'
        If (GetSPProfileVariable) {

            Write-Verbose -Message 'Determining the existence of the $PROFILE CurrentUserAllHosts property.'
            If (GetSPProfileVariableProperty) {
                Write-Verbose -Message 'Determining if a current CurrentUserAllHosts profile script needs backup.'
                $ProfileNeeds = GetSPProfileNeed

            } Else {
                'A $PROFILE variable CurrentUserAllHosts property does not exist.' | ForEach-Object {
                    Write-Warning -Message $_; Write-Verbose -Message $_
                }
                break
            } # End If-Else.
        } Else {
            'A $PROFILE variable does not exist.' | ForEach-Object {
                Write-Warning -Message $_; Write-Verbose -Message $_
            }
            break
        } # End If-Else.
    } # End Begin.

    Process {
        If ($ProfileNeeds -contains 'backup') {
            Write-Verbose -Message 'Backing up existing CurrentUserAllHosts profile script.'
        }
        Write-Verbose -Message 'Creating a new CurrentUserAllHosts profile script.'
        StartSPBackupAndCreate -ProfileNeeds $ProfileNeeds
    } # End Process.

    End {
        Write-Verbose -Message 'Adding the fixture code to the new CurrentUserAllHosts profile script.'
        NewSPProfileScript -ComputerName $ComputerName
    } # End End.
} # End Function: New-SinkProfileFixture.
#endregion.

#region Private GetSPProfileVariable.
Function GetSPProfileVariable {
<#
Called by:  New-SinkProfileFixture.
Purpose:    The purpose of this helper function is to 
#>
    If ($PROFILE) {
        $true
    } Else {
        $false
    } # End If-Else.
} # End Function: GetSPProfileVariable.
#endregion.

#region Private GetSPProfileVariableProperty.
Function GetSPProfileVariableProperty {
<#
Called by:  New-SinkProfileFixture.
Purpose:    The purpose of this helper function is to 
#>
    If (Get-Member -InputObject $PROFILE -Name CurrentUserAllHosts -MemberType NoteProperty) {
        $true
    } Else {
        $false
    } # End If-Else.
} # End Function: GetSPProfileVariableProperty.
#endregion.

#region Private GetSPProfileNeed.
Function GetSPProfileNeed {
<#
Called by:  New-SinkProfileFixture.
Purpose:    The purpose of this helper function is to 
#>
    If (Test-Path -Path $PROFILE.CurrentUserAllHosts) {
        'backup','create'
    } Else {
        'create'
    } # End If-Else.
} # End Function: GetSPProfileNeed.
#endregion.

#region Private StartSPBackupAndCreate.
Function StartSPBackupAndCreate {
<#
Called by:  New-SinkProfileFixture.
Purpose:    The purpose of this helper function is to 
#>
    Param (
        [Parameter()]
        [string[]]$ProfileNeeds
    )

    $ProfilePath = $PROFILE.CurrentUserAllHosts
    Switch ($ProfileNeeds) {
        'backup' {
            Get-Item -Path $ProfilePath | Copy-Item -Destination "$ProfilePath.$(Get-Date -Format 'DyyMMddTHHmmss.fff').bak"
        }
        'create' {
            New-Item -Path $ProfilePath -Force | Out-Null
        }
    } # End Switch.
} # End Function: StartSPBackupAndCreate.
#endregion.

#region Private NewSPProfileScript.
Function NewSPProfileScript {
<#
Called by:  New-SinkProfileFixture.
Purpose:    The purpose of this helper function is to 
#>
    Param (
        [Parameter()]
        [string[]]$ComputerName
    )

    $FixtureContent = @"
#region Code for all computers. 
Switch (`$env:COMPUTERNAME) {
"@
    Foreach ($Computer in $ComputerName) {
$FixtureContent += @"

    {`$_ -eq '$Computer'} {
        # Enter code here for the "$Computer" computer.
    }

"@
    } # End ForEach-Object.
$FixtureContent += @"

    {`$_ -eq $("'" + ($ComputerName -join "' -or `$_ -eq '") + "'")} {
        # Enter code here for all $($ComputerName.Count) computers.
        `$SinkProfile = `$true
    }

    default {}
} # End Switch.
#endregion.

#region Invoke Invoke-SinkProfileSync function.
Invoke-SinkProfileSync
#endregion.
"@

    Set-Content -Path $Profile.CurrentUserAllHosts -Value $FixtureContent
} # End Function: NewSPProfileScript.
#endregion.
# -----
#region Public Add-SinkProfilePartner.
Function Add-SinkProfilePartner {
<#
.SYNOPSIS
    The Add-SinkProfilePartner function creates a partnership with a service that allows syncing of files between multiple computers.
.DESCRIPTION 
    The function uses helper functions in order to create a directory called SinkProfile inside the current user's Documents folder, such as "C:\Users\tommymaynard\Documents\SinkProfile\", 
    create a directory called SinkProfile inside the current user's sync partner (ie Dropbox), such as "C:\Users\tommymaynard\Dropbox\SinkProfile\", and 
.PARAMETER PartnerName
    The PartnerName parameter is the name of the selective service, such as Dropbox, that will be used with the SinkProfile PowerShell module.
.PARAMETER PartnerPath
    The PartnerPath parameter requires a path value to the folder that syncs with the chosen syncing service, such as Dropbox. If the "C:\Users\tommymaynard\Dropbox" folder syncs with Dropbox, this value would be entered as the value for the PartnerPath parameter.
.EXAMPLE
    Add-SinkProfilePartner -PartnerName Dropbox -PartnerPath 'C:\Users\tommymaynard\Dropbox'
    This example creates a SinkProfile partner file for Dropbox using the partner name of "Dropbox." This same file will also be stored in C:\Users\tommymaynard\Documents\SinkProfile.
.EXAMPLE
    Add-SinkProfilePartner -PartnerName Box -PartnerPath 'C:\Users\tommymaynard\Box Sync\'
    This example create a SinkProfile partner file for Box using the partner name of "Box." Notice the difference in this example, in that PartnerName value differs from the final directory of the PartnerPath value (Box Sync).
    This same file will also be stored in C:\Users\tommymaynard\Documents\SinkProfile.
.NOTES
    Name: Add-SinkProfilePartner
    Author: Tommy Maynard
#>
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory)]
        [string]$PartnerName,

        [Parameter(Mandatory)]
        [string]$PartnerPath,

        [Parameter()]
        [switch]$Force
    )

    Begin {
        $DocumentsPath = "$env:USERPROFILE\Documents\SinkProfile"
        $PartnerPath = "$($PartnerPath.TrimEnd('\'))\SinkProfile"
    } # End Begin.

    Process {
        If (NewSPDocumentsDirectory -DocumentsPath $DocumentsPath) {
            Write-Verbose -Message "Creating local storage location in ""$DocumentsPath."""

            If (NewSPPartnerDirectory -PartnerPath $PartnerPath) {
                Write-Verbose -Message "Creating partner storage location in ""$PartnerPath."""
                
                $Params = @{
                    PartnerName = $PartnerName
                    PartnerPath = $PartnerPath
                    DocumentsPath = $DocumentsPath
                }

                If (-Not(Test-Path -Path "$(Join-Path -Path $PartnerPath -ChildPath '\profile.ps1')")) {
                    Write-Verbose -Message "Creating a partner configuration file."
                    NewSPDocumentsAndPartnerFile @Params
                }
            }

        } Else {
            "Unable to create or verify directory." | ForEach-Object {
                Write-Warning -Message $_; Write-Verbose -Message $_
            } # End ForEach-Object.
        } # End If-Else.
    } # End Process.

    End {} # End End.
} # End Function: Add-SinkProfilePartner.
#endregion.

#region Private NewSPDocumentsDirectory.
Function NewSPDocumentsDirectory {
<#
Called by:  Add-SinkProfilePartner.
Purpose:    The purpose of this helper function is to create a directory called
            SinkProfile inside the current user's Documents folder, such as 
            "C:\Users\tommymaynard\Documents\SinkProfile\".
#>
    Param (
        [Parameter()]
        [string]$DocumentsPath
    )

    If (-Not(Test-Path -Path $DocumentsPath)) {
        New-Item -Path $DocumentsPath -ItemType Directory | Out-Null
        Start-Sleep -Milliseconds 500

        If ((Get-Item -Path $DocumentsPath).Exists) {
            $true
        } Else {
            $false
        } # End If-Else.

    } Else {
        $true
    } # End If-Else.
} # End Function: NewSPDocumentsDirectory.
#endregion.

#region Private NewSPPartnerDirectory.
Function NewSPPartnerDirectory {
<#
Called by:  Add-SinkProfilePartner.
Purpose:    The purpose of this helper function is to create a directory called
            SinkProfile inside the current user's sync partner (ie Dropbox), 
            such as "C:\Users\tommymaynard\Dropbox\SinkProfile\".
#>
    Param (
        [Parameter()]
        [string]$PartnerPath
    )

    If (-Not(Test-Path -Path $PartnerPath)) {
        New-Item -Path $PartnerPath -ItemType Directory | Out-Null
        Start-Sleep -Milliseconds 500

        If ((Get-Item -Path $PartnerPath).Exists) {
            $true
        } Else {
            $false
        } # End If-Else.

    } Else {
        $true
    } # End If-Else.
} # End Function: NewSPPartnerDirectory.
#endregion.

#region Private NewSPDocumentsAndPartnerFile.
Function NewSPDocumentsAndPartnerFile {
<#
Called by:  Add-SinkProfilePartner.
Purpose:    The purpose of this helper function is to create a sync partner file in both 
            the Documents and Partner directories, such as "C:\Users\tommymaynard\Documents\SinkProfile\" 
            and "C:\Users\tommymaynard\Dropbox\SinkProfile\".
#>
    Param (
        [Parameter()]
        [string]$PartnerName,

        [Parameter()]
        [string]$PartnerPath,

        [Parameter()]
        [string]$DocumentsPath
    )

    $Object = [pscustomobject]@{
        PartnerName = $PartnerName
        PartnerPath = $PartnerPath
        PartnerPathProfile = "$($PartnerPath)\profile.ps1"
        PartnerPathXml = "$(Join-Path -Path $PartnerPath -ChildPath $PartnerName).xml"
        DocumentsPath = $DocumentsPath
        DocumentsPathXml = "$(Join-Path -Path $DocumentsPath -ChildPath $PartnerName).xml"
    }

    try {
        $Object | Export-Clixml -Path $Object.PartnerPathXml
        $Object | Export-Clixml -Path $Object.DocumentsPathXml
    } catch {
        Write-Warning -Message 'An exception or error occurred.'
    } # End try-catch.
} # End Function: NewSPDocumentsAndPartnerFile.
#endregion.
# -----
#region Public Get-SinkProfilePartner.
Function Get-SinkProfilePartner {
<#
.SYNOPSIS
    The Get-SinkProfilePartner function returns Sink Profile partners registered on the local computer.
.DESCRIPTION
    A Sink Profile partner is considered to be registered when a specific XML file has been created and is located in the following directory: "C:\Users\<username>\Documents\SinkProfile\." This function relies on at least one helper function in order to create a Sink Profile partner object that is then displayed by this function.
.EXAMPLE  
    Get-SinkProfilePartner
    PartnerName        : Box
        PartnerPath        : C:\users\tommymaynard\Box Sync\SinkProfile
        PartnerPathProfile : C:\users\tommymaynard\Box Sync\SinkProfile\profile.ps1
        PartnerPathXml     : C:\users\tommymaynard\Box Sync\SinkProfile\Box.xml
        DocumentsPath      : C:\Users\tommymaynard\Documents\SinkProfile
        DocumentsPathXml   : C:\Users\tommymaynard\Documents\SinkProfile\Box.xml

        In this example, the contents of all Sink Profile partner files are read in, and an object is created for each file.
.NOTES
    Name: Get-SinkProfilePartner
    Author: Tommy Maynard
#>
    [CmdletBinding()]
    Param ()

    Begin {
        $DocumentsPath = "$env:USERPROFILE\Documents\SinkProfile\"
    } # End Begin.

    Process {
        If (Test-Path -Path $DocumentsPath) {
            NewSPPartnerObject -DocumentsPath $DocumentsPath
        } Else {
            "Unable to locate the Sink Profile Documents directory: ""$DocumentsPath.""" | ForEach-Object {
                Write-Warning -Message $_; Write-Verbose -Message $_
            }
            break
        } # End If-Else.
    } # End Process.

    End {} # End End.
} # End Function: Get-SinkProfilePartner.
#endregion.

#region Private NewSPPartnerObject.
Function NewSPPartnerObject {
<#
Called by:  Get-SinkProfilePartner.
Purpose:    The purpose of this helper function is to return the SinkProfile partners on the local computer 
            from "C:\Users\<username>\Documents\SinkProfile\". Each XML file in this directory represents 
            a seperate SinkProfile partner.
#>
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory)]
        [string]$DocumentsPath
    )
    #region Create SinkProfile partner object.
    Get-ChildItem -Path $DocumentsPath -Filter '*.xml' | ForEach-Object {
        Import-Clixml -Path $_.FullName
    } # End ForEach-Object.
    #endregion.
} # End Function: NewSPPartnerObject.
#endregion.
# -----
#region Public Invoke-SinkProfileSync.
Function Invoke-SinkProfileSync {
<#
.SYNOPSIS
    The Invoke-SinkProfileSync function ensures the newest version of the CurrentUserAllHosts profile script is useable in the local file system.
.DESCRIPTION
    If the newest version of the CurrentUserAllHosts profile script is newer on the computer vs. in the partner folder, it will copy it from the its place in the WindowsPowerShell folder (C:\Users\<username>\Documents\WindowsPowerShell\), to its place in the partner folder, such as C:\Users\<username>\Dropbox\SinkProfile\profile.ps1. This function makes use of the Get-SinkProfilePartner public function.
.EXAMPLE
    Invoke-SinkProfileSync
    This example copies the newest CurrentUserAllHosts profile script from the location with the newest version to the location of the oldest version.
.NOTES
    Name: Invoke-SinkProfileSync
    Author: Tommy Maynard
#>
    [CmdletBinding()]
    Param ()

    Begin {} # End Begin.

    Process {
        #region Sync of all Sink Profile partners.
        Get-SinkProfilePartner | ForEach-Object {
            $Params = @{
                PartnerPathProfile = $_.PartnerPathProfile
                ProfileScriptLastWrite = (Get-Item -Path $PROFILE.CurrentUserAllHosts).LastWriteTime
                PartnerProfileScriptLastWrite = If ((Get-Item $_.PartnerPathProfile -OutVariable LWT -ErrorAction SilentlyContinue).LastWriteTime) {
                    $LWT.LastWriteTime
                } Else {
                    Get-Date -Date '01/01/1600'
                }
            }
            $Params += @{
                LocalProfileScriptNewest = $Params.ProfileScriptLastWrite -gt $Params.PartnerProfileScriptLastWrite
                MatchingProfileScripts = $Params.PartnerProfileScriptLastWrite -eq $Params.ProfileScriptLastWrite
            }

            If ($Params.MatchingProfileScripts -eq $true) {
                $Sync = $false
                Write-Verbose -Message 'Copying profile script is not necessary in either direction.'
            } Else {

                $Sync = $true
                If ($Params.LocalProfileScriptNewest -eq $false) {
                    Write-Verbose -Message 'Copying profile script from partner to local system.'

                } ElseIf ($Params.LocalProfileScriptNewest -eq $true) {
                    Write-Verbose -Message 'Copying profile script from local system to partner.'
                } # End If-ElseIf.
            } # End If-Else.
        } # End ForEach-Object.
        #endregion.
    } # End Process.

    End {
        If ($Sync) {
            $Params = @{
                PartnerPathProfile = $Params.PartnerPathProfile
                LocalProfileScriptNewest = $Params.LocalProfileScriptNewest
            }
            SyncSPProfileScript @Params
        }
    } # End End.
} # End Function: Invoke-SinkProfileSync.
#endregion.

#region Private SyncSPProfileScript.
Function SyncSPProfileScript {
<#
Called by:  Invoke-SinkProfileSync.
Purpose:    The purpose of this helper function is to sync the profile.ps1 file 
            from the location that holds the newest version of the profile script
            to the location that hold the oldest version.
#>
    [CmdletBinding()]
    Param (
        [Parameter()]
        [string]$PartnerPathProfile,

        [Parameter()]
        [string]$LocalProfileScriptNewest
    )

    Begin {} # End Begin.

    Process {
        If ($LocalProfileScriptNewest -eq $false) {
            #$ProfileScriptLastWrite -lt $PartnerProfileScriptLastWrite
            Copy-Item -Path $PartnerPathProfile -Destination $PROFILE.CurrentUserAllHosts

            Write-Output -InputObject 'The SinkProfile profile script has been updated.'
            Do {
                $Prompt = Read-Host -Prompt 'Enter r to Restart or c to Cancel'
            } Until ($Prompt -eq 'r' -or $Prompt -eq 'c')

            If ($Prompt -eq 'r') {
                Start-Process -FilePath (Get-Process -Id $PID).ProcessName
                Stop-Process -Id $PID
            } # End If.

        } ElseIf ($LocalProfileScriptNewest -eq $true) {
            #$ProfileScriptLastWrite -gt $PartnerProfileScriptLastWrite
            Copy-Item -Path $PROFILE.CurrentUserAllHosts -Destination $PartnerPathProfile
        } # End If-ElseIf.
    } # End Process.

    End {} # End End.
} # End Function: SyncSPProfileScript.
#endregion.
# -----
#region Public Complete-SinkProfilePartner.s
Function Complete-SinkProfilePartner {
<#
.SYNOPSIS
    The Complete-SinkProfilePartner function completes a partnership with a service that allows syncing of files between multiple computers.
.DESCRIPTION
    This function is to be used on computers that are a part of a sync group; however, it should only be invoked on computers after the initial work is completed on the first computer in the sync group. The second (third, fourth, etc.) computer's name should have been a parameter value provided the ComputerName parameter on the New-SinkProfileFixture function ran on the initial computer in the sync group. This is what ensures the profile script will apply to all the computers in the sync group.
.PARAMETER PartnerPath
    The PartnerPath parameter requires a path value to the folder that syncs with the chosen syncing service, such as Dropbox. If the "C:\Users\tommymaynard\Dropbox" folder syncs with Dropbox, this value would be entered as the value for the PartnerPath parameter.
.EXAMPLE
    Complete-SinkProfilePartner -
.NOTES
    Name: Complete-SinkProfilePartner
    Author: Tommy Maynard
#>
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory)]
        [string]$PartnerName,

        [Parameter(Mandatory)]
        [string]$PartnerPath
    )

    Begin {
        $DocumentsPath = "$env:USERPROFILE\Documents\SinkProfile"
        $PartnerFilePath = "$PartnerPath\SinkProfile\$PartnerName.xml"

    } # End Begin.

    Process {
        If (Test-Path -Path $PartnerFilePath) {
            $PartnerPathsFromFile = Import-Clixml -Path $PartnerFilePath

            Write-Verbose -Message 'Attempting to back up existing CurrentUserAllHosts profile script.'
            StartSPBackup

            Write-Verbose -Message 'Attempting to copy CurrentUserAllHosts profile script to the local system.'
            CopySPProfileScript -PartnerPathProfile $PartnerPathsFromFile.PartnerPathProfile

            Write-Verbose -Message "Attempting to create a local storage location in ""$DocumentsPath."""
            NewSPDocumentsDirectory -DocumentsPath $DocumentsPath | Out-Null # Also used by Add-SinkProfilePartner.

            Write-Verbose -Message 'Attempting to copy partner file to local system.'
            CopySPPartnerFile -PartnerPathXml $PartnerPathsFromFile.PartnerPathXml -DocumentsPath $DocumentsPath
        } Else {
            Write-Warning -Message 'Unable to locate partner file in partner path.'
        }
    } # End Process.

    End {} # End End.
} #End Function: Complete-SinkProfilePartner.
#endregion.

#region Private StartSPBackup.
Function StartSPBackup {
<#
Called by:  Complete-SinkProfilePartner.
Purpose:    The purpose of this helper function is to backup the CurrentUserAllHosts
            (profile.ps1) profile script, if it already exists. The "2" in the 
            filename indicates it was the second (or third, fourth, etc.) computer 
            in the SinkProfile sync group.
#>
    $ProfilePath = $PROFILE.CurrentUserAllHosts
    If (Test-Path -Path $ProfilePath) {
        Get-Item -Path $ProfilePath |
            Copy-Item -Destination "$ProfilePath.$(Get-Date -Format 'DyyMMddTHHmmss.fff').2.bak"
    }
} # End Function: StartSPBackup.
#endregion.

#region Private CopySPProfileScript.
Function CopySPProfileScript {
<#
Called by:  Complete-SinkProfilePartner.
Purpose:    The purpose of this helper function is to copy the CurrentUserAllHosts
            profile script from the partner folder (Dropbox, etc.) to the local
            system.
#>
    Param (
        [Parameter(Mandatory)]
        [string]$PartnerPathProfile
    )
    Copy-Item -Path $PartnerPathProfile -Destination (Split-Path -Path $PROFILE.CurrentUserAllHosts)
} # End Function: CopySPProfileScript.
#endregion.

#region Private NewSPDocumentsDirectory.
#--> Already included above.
#endregion.

#region Private CopySPPartnerFile.
Function CopySPPartnerFile {
<#
Called by:  Complete-SinkProfilePartner.
Purpose:    The purpose of this helper function is to copy the partner file from 
            the partner folder (Dropbox, etc.) to the local system.
#>
    Param (
        [Parameter(Mandatory)]
        [string]$PartnerPathXml,

        [Parameter()]
        [string]$DocumentsPath
    )
    Copy-Item -Path $PartnerPathXml -Destination $DocumentsPath
} # End Function: CopySPPartnerFile.
#endregion