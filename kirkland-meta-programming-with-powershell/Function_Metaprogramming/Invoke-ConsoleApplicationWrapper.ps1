#Function to interact with Convert-ConsoleApplicationHelp
function Invoke-ConsoleApplicationWrapper {
    <#
    .SYNOPSIS
    Main function to Convert-ConsoleApplicationHelp which converts legacy console arguments to PS Parameters
    
    .DESCRIPTION
    Uses Convert-ConsoleApplicationHelp to convert the legacy console applications arguments and help documentation to PS Parameters by using dynamic parameters
    
    .PARAMETER BinaryPath
    The full file system path to the binary folder
    
    .PARAMETER BinaryExecutable
    The binary name
    
    .PARAMETER HelpArgument
    What you would use on the legacy console application binary to show the help file, typically /?

    .PARAMETER ParameterSpacing
    Special parameter spacing for non standard parameter style of /Param Arg, AZCopy uses /Param:Arg

    .PARAMETER SeparateWindow
    Switch to spawn the process in a new window with Start-Process without waiting, useful for keeping processes separate or multitasking

    .PARAMETER OptionalParameter1
    Type in any optional parameters that were not detected from the conversion of help, this is inputed a string during execution

    .PARAMETER OptionalParameter2
    Type in any optional parameters that were not detected from the conversion of help, this is inputed a string during execution

    .EXAMPLE
    Invoke-ConsoleApplicationWrapper -BinaryPath C:\Windows\System32 -BinaryExecutable xcopy.exe -HelpArgument '/?'

    .EXAMPLE
    Invoke-ConsoleApplicationWrapper -BinaryPath C:\temp\AZCopy -BinaryExecutable AZCopy.exe -HelpArgument '/?'

    .EXAMPLE
    Invoke-ConsoleApplicationWrapper -BinaryPath C:\Windows\System32 -BinaryExecutable Robocopy.exe -HelpArgument '/?'
    
    .NOTES
    This was originally built for AZCopy but due to PS limitations with Program Files (x86, copy AZCopy somewhere out of Program Files (x86))
    If a parameter from the legacy console application was a switch, this wrapper will assume its a string. Instead to use it as a switch during invokecation use $null for the string. e.g. "-MIR $null" for robocopy
    #>
    [CmdletBinding()]
    Param
    (
        [Parameter(
            Mandatory = $true,
            Position = 0,
            HelpMessage = 'The path to the binary, the full path is highly suggested'
        )]
        [string]$BinaryPath,

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
        [string]$HelpArgument,

        [Parameter(
            Mandatory = $false,
            Position = 3,
            HelpMessage = 'The parameter specific spacing, most of the time a single space between the parameter and the arguement, though things like AZCopy are stupid and do /Param:Arg'
        )]
        [string]$ParameterSpacing = ' ',

        [Parameter(
            Mandatory = $false,
            Position = 4,
            HelpMessage = 'Use this switch if you want to use Start-Process in a new window for invocation'
        )]
        [switch]$SeparateWindow,

        [Parameter(
            Mandatory = $false,
            Position = 5,
            HelpMessage = 'This is an optional parameter for things like Robocopy source'
        )]
        [string]$OptionalParameter1,

        [Parameter(
            Mandatory = $false,
            Position = 6,
            HelpMessage = 'This is an optional parameter for things like Robocopy destination'
        )]
        [string]$OptionalParameter2
    )

    DynamicParam {
        if ($true) {
            do {
                Write-Verbose 'Running Convert-ConsoleApplicationHelp function'
                $ParametersInformation = Convert-ConsoleApplicationHelp -BinaryPath $PSBoundParameters.BinaryPath -BinaryExecutable $PSBoundParameters.BinaryExecutable -HelpArgument $PSBoundParameters.HelpArgument
                
                #Build the Parameter Dictionary
                $paramDictionary = New-Object -Type System.Management.Automation.RuntimeDefinedParameterDictionary
                
                #Meta Program all the things!
                for ($i = 0; $i -lt $ParametersInformation.Count; $i++) {
                    #Define the basic parameter information
                    $attributes = New-Object System.Management.Automation.ParameterAttribute
                    $attributes.ParameterSetName = "__AllParameterSets"
                    $attributes.Mandatory = $false
                    $attributes.HelpMessage = $ParametersInformation[$i].ParameterHelp
                    
                    $attributeCollection = New-Object -Type System.Collections.ObjectModel.Collection[System.Attribute]
                    $attributeCollection.Add($attributes)
                    
                    $dynParam = New-Object -Type System.Management.Automation.RuntimeDefinedParameter(
                        $ParametersInformation[$i].ParameterName,
                        [String],
                        $attributeCollection
                    )

                    $paramDictionary.Add($ParametersInformation[$i].ParameterName, $dynParam)
                }

                #Return the object for consumption
                return $paramDictionary
            }  until ($paramDictionary)
        } #End If
    }

    Begin {}
    Process {
        [System.Collections.ArrayList]$Arguments = @()

        #To Do, loop through all the optional parameters and maybe even make them dynamic for an unlimited number
        if ($OptionalParameter1) {
            [void]$Arguments.Add("$($OptionalParameter1)")
        }

        if ($OptionalParameter2) {
            [void]$Arguments.Add("$($OptionalParameter2)")
        }

        foreach ($Parameter in ($PSBoundParameters.GetEnumerator() | Where-Object {($PSItem.Key -notmatch "BinaryPath|BinaryExecutable|HelpArgument|ParameterSpacing|OptionalParameter|SeparateWindow")})) {
            if ($Parameter.Value) {
                Write-Verbose "Parameter $($Parameter.Key) has a value, we will use it"
                [void]$Arguments.Add("/$($Parameter.Key)$($ParameterSpacing)$($Parameter.Value)")
            } else {
                Write-Verbose "Parameter $($Parameter.Key) has no value, we will make it look like a switch below"
                [void]$Arguments.Add("/$($Parameter.Key)")
            }
        }
        
        Write-Verbose "$(Join-Path -Path $BinaryPath -ChildPath $BinaryExecutable)"
        Write-Verbose "$($Arguments.Trim() -join ' ')"

        #Invoke the legacy app
        if ($SeparateWindow) {
            Write-Verbose 'SeparateWindow was invoked, using Start-Process Invocation method'
            Start-Process -FilePath (Join-Path -Path $BinaryPath -ChildPath $BinaryExecutable) -ArgumentList ($Arguments -join ' ')
        } else {
            Write-Verbose 'Using legacy console invocation method'
            & "$(Join-Path -Path $BinaryPath -ChildPath $BinaryExecutable)" $Arguments
        }
    }
    End {}
}