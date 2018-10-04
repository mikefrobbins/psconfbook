#Function to convert legacy console application switches/parameters into a Key/Value pair
function Convert-ConsoleApplicationHelp {
    <#
    .SYNOPSIS
    Converts the help documentation from a legacy console application to PowerShell
    
    .DESCRIPTION
    Converts the help documentation from a legacy console application to PowerShell, it does this by parsing through the section headers if any exist.
    If none exist then it makes one one up, and continues processing the original help output.
    It then takes each switch and takes all the help information associated with each switch and transforms it into an object for later usage.
    
    .PARAMETER BinaryPath
    The filesystem path to where the binary is located, path only and not executable
    
    .PARAMETER BinaryExecutable
    The executable name in the BinaryPath with .exe or etc.
    
    .PARAMETER HelpArgument
    Us an additional help arguement other than the standard /?
    
    .EXAMPLE
    Convert-ConsoleApplicationHelp -BinaryExecutable xcopy.exe
    
    .EXAMPLE
    Convert-ConsoleApplicationHelp -BinaryExecutable xcopy.exe -HelpArgument /?

    .EXAMPLE
    Convert-ConsoleApplicationHelp -BinaryPath "C:\Program Files (x86)\Microsoft SDKs\Azure\AzCopy" -BinaryExecutable AzCopy.exe -HelpArgument /?
    
    .NOTES
    General notes
    #>
    [CmdletBinding()]
    Param
    (
        [Parameter(
            Mandatory = $false,
            Position = 0,
            HelpMessage = 'The path to the binary, the full path is highly suggested'
        )]
        [string]$BinaryPath = 'C:\Windows\System32',

        [Parameter(
            Mandatory = $true,
            Position = 1,
            HelpMessage = 'The binary name, i.e. binary.exe'
        )]
        [string]$BinaryExecutable,
        
        [Parameter(
            Mandatory = $false,
            Position = 2,
            HelpMessage = 'The switch used to access the built in help, typically /?'
        )]
        [string]$HelpArgument = '/?' 
    )

    Begin{}

    Process {
        #Global Variables
        $SectionPatterns = "^::.*|^##.*" #This pattern matches on section header starts
        $SectionPatternCharactersToReplace = "[:|#]" #This pattern matches on characters to replace when sanatizing the section header
        [System.Collections.ArrayList]$SectionHeaderVariables = @() #ArrayList to store Variables of Parameter Sections
        [System.Collections.ArrayList]$ParametersInformation = @() #ArrayList to store Parameter Names and help information
        $LinePatterns = "^/.*" #Regex to designate the start of a parameter
        $BannedParameters = "^/@.*"#Parameters that are not PS Compliant


        #Functions
        #Function to add Paramter Help Information
        function Add-ParameterHelpInformation ($Lines, $i, $ParameterHelpInfo) {
            Write-Verbose "Line $i is a continuation of the help file for Parameter $ParameterName in Section $($Section.SectionVariable)"
            #The split is to remove excessive spaces, and then we rejoin it into a real string
            $ParameterHelpString = $Lines[$i].Trim() -split ' {2,}' -join ' ' #Remove Excess Spaces
            $ParameterHelpString = $ParameterHelpString.Replace('[','<').Replace(']','>') #Replace brackets with <,>, this is for PS Parameter compliance
            $ParameterHelpString = $ParameterHelpString.Replace('(','').Replace(')','') #Replace parentheses with nothing, this is for PS Parameter compliance
            [void]$ParameterHelpInfo.Add($ParameterHelpString)
        
        }

        Write-Verbose 'CD''ing to the directory, because lord forbid we test paths in Program Files (x86)'
        #This is why, dear Microsoft you suck for this - https://stackoverflow.com/questions/4429112/powershell-combining-path-using-a-variable
        $CurrentDirectory = $pwd.Path
        Set-Location $BinaryPath

        Write-Verbose 'Testing the full path to the binary'
        if (!(Test-Path $BinaryExecutable)) {
            Write-Error -Message "Failed to find $BinaryPath, terminating now"
            exit
        }

        #Binary we want to convert, you know I'm really developing a hatred for legacy console applications
        $BinaryHelpInfo = Invoke-Expression "./$($BinaryExecutable) $($HelpArgument)"

        #Go back to the original directory as a precaution
        Write-Verbose 'Going back to the existing directory we started in'
        Set-Location $CurrentDirectory

        #Basic sanitization of the help data, removes excess lines and leading/trailing spaces
        $BinaryHelpInfo = $BinaryHelpInfo | Where-Object {$_}

        #Lets first scan for any possible section header match, if there are none were going to define a single section
        $NoSectionHeadersFound = (!($BinaryHelpInfo -match $SectionPatterns))

        #Loop through the file and find the major sections of data
        for ($i = 0; $i -lt $BinaryHelpInfo.Count; $i++) {
            #Regular section header scan
            if (($NoSectionHeadersFound) -and (!($NoSectionHeadersFoundOneTimeScan))) {
                Write-Verbose 'No Section Header was found so were going to say we found one'
                $BinaryHelpInfoHeaderMatch = $true
                $NoSectionHeadersFoundOneTimeScan = $true
            } else {
                $BinaryHelpInfoHeaderMatch = $BinaryHelpInfo[$i] -match $SectionPatterns
            }

            if ($BinaryHelpInfoHeaderMatch) {
                if (!($NoSectionHeadersFound)) {
                    Write-Verbose "We matched a section header on line ""$($BinaryHelpInfo[$i])""" #Quotes for character escaping
                }

                #Set a temp variable as a indicator that we hit a section header
                $SectionHeaderLine = $true

                if ($NoSectionHeadersFound) {
                    $HeaderNameReplaced = 'Options'
                } else {
                    $HeaderNameReplaced = ($BinaryHelpInfo[$i] -replace $SectionPatternCharactersToReplace, '').Trim()
                }

                #We have to check for replacement so we get the real header
                if ($HeaderNameReplaced) {
                    Write-Verbose "Section Header Name is $HeaderNameReplaced"
                    $Script:SectionHeaderName = $HeaderNameReplaced
                }

                #Attempt to strip out the header name so we can use it later, or make one up        
                Write-Verbose "Section Header Name is ""$Script:SectionHeaderName"""
            } elseif (
                    ($SectionHeaderLine) -and
                    (!($BinaryHelpInfoHeaderMatch))
                ) {
                if ($SectionHeaderLine) {
                    Write-Verbose "Line $i is the first line after the Section Header, were going to make a new storage var and flip a switch"
                    $SectionVariableCountInt = 1
                    do {
                        $SectionVariableName = "Section$($SectionVariableCountInt)"
                        if (!(Get-Variable $SectionVariableName -ErrorAction SilentlyContinue)) {
                            Write-Verbose "$SectionVariableCountInt is free, using that value for SectionVariableName"
                            New-Variable $SectionVariableName
                            $SectionVariableCreated = $true
                            Try {
                                $SectionHeaderNameObject = [pscustomobject]@{
                                    SectionVariable = $SectionVariableName
                                    HeaderName = $Script:SectionHeaderName
                                }

                                [void]$SectionHeaderVariables.Add($SectionHeaderNameObject)
                            } Catch {}
                            $i-- #Step the loop back int 1 so we don't miss the line
                        } else {
                            $SectionVariableCreated = $false
                            Write-Verbose "$SectionVariableName was taken, incrementing +1 and looping"
                            $SectionVariableCountInt++
                        }
                    } until ($SectionVariableCreated)

                    #Let PowerShell know to start storing data to the new variable
                    $SectionHeaderLine = $false
                }
                Write-Verbose "Line $i is after the section header ending, we will start processing it"
            } elseif (
                    (!($SectionHeaderLine)) -and
                    (!($BinaryHelpInfoHeaderMatch)) -and
                    ($SectionHeaderVariables) #So we don't run this block on the first few lines
                ) {

                #Populate the Section variable with content
                Set-Variable -Name $SectionVariableName -Value @(
                    (Get-Variable -Name $SectionVariableName).Value #Add the existing value so we don't lose it
                    $BinaryHelpInfo[$i] #Add new line info
                )
            } #end Normal Line elseif
        } #End for loop

        #Find all sections that have actual options available and process them
        foreach ($Section in ($SectionHeaderVariables | Where-Object {($PSItem.HeaderName -like "*Options*")})) {
            $Lines = (Get-Variable -Name $Section.SectionVariable).Value | Where-Object {$PSItem} #Get the value and remove blank lines

            for ($i = 0; $i -lt $Lines.Count; $i++) {
                #Check if we are going to start definining a new parameter and store it as a boolean
                $NewParameter = if ($Lines[$i].Trim() -match $LinePatterns) {
                    $true
                } else {
                    $false
                }

                if (
                    ($NewParameter) -and
                    ($Lines[$i] -notmatch $BannedParameters)
                ) {
                    #Split the line so we can get its help information, we do two split because console apps split different
                    $LineSplit = ($Lines[$i].Split(':') -replace '/','').Trim() -split ' {2,}'
                    Write-Verbose "Starting to work on a new parameter $($LineSplit[0]) on line $i" #While this should go above, we're leaving it here for debugging

                    #If a new parameter commit the previous information
                    if (
                        $ParameterName -and
                        $ParameterHelpInfo -and
                        $NewParameter -and
                        $LineSplit[0].Split().Count -eq 1
                    ) {
                        Write-Verbose "We found an existing parameter $ParameterName so we will add it to the ArrayList"
                        
                        $ParameterToAdd = [pscustomobject]@{
                            ParameterName = $ParameterName
                            ParameterHelp = $ParameterHelpInfo
                        }

                        [void]$ParametersInformation.Add($ParameterToAdd)
                        
                        Write-Verbose 'Remove the previous parameter information'
                        Remove-Variable ParameterName,ParameterHelpInfo,ParameterHelpString
                    }

                    if ($LineSplit.Count -gt 1) { 
                        if ($LineSplit[0].Split().Count -eq 1) {
                            Write-Verbose 'The line count is multiline'
                            $ParameterName = $LineSplit[0].Replace('[','').Replace(']','').Replace('+',"PLUS").Replace('-',"MINUS") #Replace illegal characters from parameters like this /MT[:n]
                            $ParameterHelpString = (($Lines[$i].Split(':') -split ' {2,}' -replace '/','').Where{$PSItem}[-1].Trim() -replace '<*.*>','').Trim() #Yes the second split must be that way, don't use the method

                            #Establish a variable to hold the help information in
                            [System.Collections.ArrayList]$ParameterHelpInfo = @()

                            #Add the help information to the HelpInfo Property
                            [void]$ParameterHelpInfo.Add($ParameterHelpString)
                        } else {
                            Write-Verbose "Line $i is a continuation of the help file for Parameter $ParameterName in Section $($Section.SectionVariable)"
                            if ($Lines[$i] -like "*") {
                                Add-ParameterHelpInformation -Lines $Lines -i $i -ParameterHelpInfo $ParameterHelpInfo
                            }
                        }
                    }
                } elseif ($ParameterName) { #Make sure there is an actual parameter were adding to
                    Write-Verbose "Line $i is a continuation of the help file for Parameter $ParameterName in Section $($Section.SectionVariable)"
                    if ($Lines[$i] -like "*") {
                        Add-ParameterHelpInformation -Lines $Lines -i $i -ParameterHelpInfo $ParameterHelpInfo
                    }
                } #elseif ParameterName
            } #End for
        } #End foreach

        #Reformat and join together ParametersInformation, and remove possible duplicates
        $ParametersInformation = $ParametersInformation |
            Select-Object ParameterName,@{Name='ParameterHelp';Expression={($Psitem.ParameterHelp -join ' ').Trim('.')}} |
            Group-Object ParameterName |
            ForEach-Object {
                $PSItem.Group | Select-Object -First 1
            }

        #Return the new parameters
        $ParametersInformation
    }

    End {}
}