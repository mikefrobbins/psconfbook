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