#region Functions
#Function to open up MSSQL Connection
function New-MSSQLConnection {
    #Params
    [CmdletBinding()]
    Param(
    [parameter(Position=0,Mandatory=$true)]
        $ServerInstance,
    [parameter(Position=1,Mandatory=$true)]
        $Database,
    [parameter()]
        [System.Management.Automation.PSCredential]$Cred,
    [parameter()]
        [switch]$NoSSPI = $false
    )

    Begin {
        Write-Verbose 'Building the SQLConnection Object'
        $SQLConnection = New-Object System.Data.SqlClient.SqlConnection

        if ($NoSSPI) {
            Write-Verbose 'Setting SQL to use local credentials'

            if ($NoSSPI -and (!($Cred))) {
                $Cred = Get-Credential
            }

            $SQLConnection.ConnectionString = "Server = $ServerInstance;Database=$Database;User ID=$($cred.UserName);Password=$($cred.GetNetworkCredential().password);"   
        } else {
            Write-Verbose 'Setting SQL to use SSPI'
            $SQLConnection.ConnectionString = "Server=$ServerInstance;Database=$Database;Integrated Security=True"
        }

        Write-Verbose 'Open the SQLConnection'
        Try {
            $SQLConnection.Open()
        } Catch {
            Write-Warning "Unable to open the SQL Connection to $($ServerInstance)\$($Database)"
        }
    }

    Process {
        Write-Verbose 'Returning the SQL connection back to the console'
        return $SQLConnection
    }
}

#Function to run SQL Queries
function Invoke-MSSQLQuery {
    #Params
    [CmdletBinding()]
    Param(
    [parameter(Position=0,Mandatory=$true)]
        $SQLConnection,
    [parameter(Position=1,Mandatory=$true)]
        $Query
    )

    Process {
        if ($SQLConnection.State -ne [Data.ConnectionState]::Open) {
            Write-Output "Connection to SQL DB not open"
        } else {
            $SqlCmd = New-Object System.Data.SqlClient.SqlCommand 
            $SqlCmd.Connection = $SqlConnection 
            $SqlCmd.CommandText = $Query 
            $SqlAdapter = New-Object System.Data.SqlClient.SqlDataAdapter 
            $SqlAdapter.SelectCommand = $SqlCmd 
            $DataSet = New-Object System.Data.DataSet 
            $a=$SqlAdapter.Fill($DataSet) 
            $DataSet.Tables[0]
        }
    }
}

#Function to close up MSSQL Connection
function Close-MSSQLConnection {
    #Params
    [CmdletBinding()]
    Param(
    [parameter(Position=0,Mandatory=$true)]
        $SQLConnection
    )

    Process {
        Try {
            $SQLConnection.Close()
            $SQLConnection.Dispose()
        } Catch {
            Write-Warning 'Unable to close SQLConnection'
        }
    }
}
#endregion

#Clear-Host

#Base Work
[System.Collections.ArrayList]$Colors = (Get-Help -Name Write-Host -Parameter ForegroundColor | Out-String -Stream | Select-String -Pattern '- ' | Out-String).Split('-').Split().Where{$PSItem -notlike $null}
[System.Collections.ArrayList]$Results = @()
$SQLConnection = New-MSSQLConnection -ServerInstance SQLPDB01.lan.local -Database meta_programming

do {
    #Array
    $ArrayMeasure = Measure-Command {
        $array = @()
        $array += "Write-Output 'Let the puppy killing commence'"
        $array += "Write-Output 'pause'"

        foreach ($Num in 1..5000) {
            $array += 'Write-Host -ForegroundColor {0} -BackgroundColor {1} {2}' -f ($Colors | Get-Random),($Colors | Get-Random),$Num
        }
    }
    [void]$Results.Add(($ArrayMeasure | Select-Object @{Name='Type';Expression={'Array'}},Minutes,Seconds,Milliseconds))

    #ArrayList Legacy Redirection
    $ArrayListMeasureLegacy = Measure-Command {
        [System.Collections.ArrayList]$ArrayList = @()
        $ArrayList.Add("Write-Output 'Let the puppy killing commence'") > ''
        $ArrayList.Add("Write-Output 'pause'") > ''

        foreach ($Num in 1..5000) {
            $string = 'Write-Host -ForegroundColor {0} -BackgroundColor {1} {2}' -f ($Colors | Get-Random),($Colors | Get-Random),$Num
            $ArrayList.Add($string) > ''
        }
    }
    [void]$Results.Add(($ArrayListMeasureLegacy | Select-Object @{Name='Type';Expression={'ArrayList_Legacy'}},Minutes,Seconds,Milliseconds))


    #ArrayList Out-Null
    $ArrayListMeasureOutNull = Measure-Command {
        [System.Collections.ArrayList]$ArrayList = @()
        $ArrayList.Add("Write-Output 'Let the puppy killing commence'") | Out-Null
        $ArrayList.Add("Write-Output 'pause'") | Out-Null

        foreach ($Num in 1..5000) {
            $string = 'Write-Host -ForegroundColor {0} -BackgroundColor {1} {2}' -f ($Colors | Get-Random),($Colors | Get-Random),$Num
            $ArrayList.Add($string) | Out-Null
        }
    }
    [void]$Results.Add(($ArrayListMeasureOutNull | Select-Object @{Name='Type';Expression={'ArrayList_OutNull'}},Minutes,Seconds,Milliseconds))

    #ArrayList
    $ArrayListMeasure = Measure-Command {
        [System.Collections.ArrayList]$ArrayList = @()
        [void]$ArrayList.Add("Write-Output 'Let the puppy killing commence'")
        [void]$ArrayList.Add("Write-Output 'pause'")

        foreach ($Num in 1..5000) {
            $string = 'Write-Host -ForegroundColor {0} -BackgroundColor {1} {2}' -f ($Colors | Get-Random),($Colors | Get-Random),$Num
            [void]$ArrayList.Add($string)
        }
    }
    [void]$Results.Add(($ArrayListMeasure | Select-Object @{Name='Type';Expression={'ArrayList_Void'}},Minutes,Seconds,Milliseconds))


    #File System
    $FileMeasure = Measure-Command {
        $File = 'C:\temp\meta\output\6_Output_Methods.ps1'
        Remove-Item $File
        Write-Output "Write-Output 'Let the puppy killing commence'" | Add-Content -Path $File
        Write-Output 'pause' | Add-Content -Path $File

        foreach ($Num in 1..5000) {
            $string = 'Write-Host -ForegroundColor {0} -BackgroundColor {1} {2}' -f ($Colors | Get-Random),($Colors | Get-Random),$Num
            $string | Add-Content -Path $File
        }
    }
    [void]$Results.Add(($FileMeasure | Select-Object @{Name='Type';Expression={'File'}},Minutes,Seconds,Milliseconds))

    #DB
    $DBMeasure = Measure-Command {
        $Header = Write-Output "Write-Output 'Let the puppy killing commence'"
        Invoke-MSSQLQuery -SQLConnection $SQLConnection -Query "INSERT INTO dbo.example (Project,Code) VALUES ('Puppy Killer','$($Header.replace("'","''"))')" 

        foreach ($Num in 1..5000) {
            $string = 'Write-Host -ForegroundColor {0} -BackgroundColor {1} {2}' -f ($Colors | Get-Random),($Colors | Get-Random),$Num
            Invoke-MSSQLQuery -SQLConnection $SQLConnection -Query "INSERT INTO dbo.example (Project,Code) VALUES ('Puppy Killer','$string')" 
        }
    }

    [void]$Results.Add(($DBMeasure | Select-Object @{Name='Type';Expression={'DB'}},Minutes,Seconds,Milliseconds))

    $i++
} until ($i -eq 10)

$Results