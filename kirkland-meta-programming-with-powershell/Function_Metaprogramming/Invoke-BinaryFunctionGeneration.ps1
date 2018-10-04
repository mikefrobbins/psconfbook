#This function generates the base code to generate a new sub function
function Invoke-BinaryFunctionGeneration {
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

    Begin {}

    Process {
        Write-Verbose 'Build the Parameter Dictionary'
        [System.Collections.ArrayList]$Parameters = @()

        Write-Verbose 'Adding in extra parameters that are in the dynamic function'
        $AdditionalParameters = @{
            'BinaryPath' = 'The path to the binary, the full path is highly suggested';
            'BinaryExecutable' = 'The binary name, i.e. binary.exe';
            'ParameterSpacing' = 'The parameter specific spacing, most of the time a single space between the parameter and the arguement, though things like AZCopy are stupid and do /Param:Arg';
            'SeparateWindow' = 'Use this switch if you want to use Start-Process in a new window for invocation';
            'OptionalParameter1' = 'This is an optional parameter for things like Robocopy source';
            'OptionalParameter2' = 'This is an optional parameter for things like Robocopy destination'
        }

        #Loop through the above optional parameters hashtable
        foreach ($Parameter in ($AdditionalParameters.GetEnumerator() | Sort-Object Name -Descending)) {
            $obj = [pscustomobject]@{
                ParameterName = $Parameter.Name
                ParameterHelp = $Parameter.Value
            }
            [void]$Parameters.Add($obj)
        }

        Write-Verbose 'Run Convert-ConsoleApplicationHelp to get legacy parameters'
        $BinaryParameters = Convert-ConsoleApplicationHelp -BinaryPath $PSBoundParameters.BinaryPath -BinaryExecutable $PSBoundParameters.BinaryExecutable -HelpArgument $PSBoundParameters.HelpArgument

        Write-Verbose 'Adding in the original extracted parameters to Parameters'
        foreach ($Parameter in $BinaryParameters) {
            $obj = [pscustomobject]@{
                ParameterName = $Parameter.ParameterName
                ParameterHelp = $Parameter.ParameterHelp
            }
            [void]$Parameters.Add($obj)
        }

        Write-Verbose 'Generating the real function code'
        [System.Collections.ArrayList]$FunctionCode = @() #Use an arraylist for efficiency/performance of the code generation

        Write-Verbose 'Generate the base function code and make it an advanced function'
        [void]$FunctionCode.Add("function Invoke-$($BinaryExecutable.Split('.')[0].ToUpper())Binary {
        #Make the function an advanced function, I mean really this is freaking metaprogramming all!
        [CmdletBinding()]
        Param
        (")

        Write-Verbose 'Loop through Parameters with a for loop and build the static code'
        for ($i = 0; $i -lt $Parameters.Count; $i++) {
            #Build the actual string, the first line is far out for indentation
            $String = "
        [Parameter(
            Mandatory = {0},
            HelpMessage = '{1}'
        )]
            {2}{3}{4}" -f '$false',$Parameters[$i].ParameterHelp.replace("'","''"),'$',$Parameters[$i].ParameterName,$(if ($i -ne ($Parameters.Count - 1)) {','}) #Don't add a , if it's the last parameter
            
            Write-Verbose 'Adding the new function to our ArrayList'
            [void]$FunctionCode.Add($String)
        }

        #Add the finishing touch to the parameter block
        [void]$FunctionCode.Add('    )')

        #Generate more base base, again more indentation
        [void]$FunctionCode.Add("    Begin {}
        Process {")

        #Generate the code for the process block
        $String = '        [System.Collections.ArrayList]$Arguments = @()
        
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
            Write-Verbose "$($Arguments.Trim() -join '' '')"

            #Invoke the legacy app
            if ($SeparateWindow) {
                Write-Verbose "SeparateWindow was invoked, using Start-Process Invocation method"
                Start-Process -FilePath (Join-Path -Path $BinaryPath -ChildPath $BinaryExecutable) -ArgumentList ($Arguments -join '' '')
            } else {
                Write-Verbose "Using legacy console invocation method"
                & "$(Join-Path -Path $BinaryPath -ChildPath $BinaryExecutable)" $Arguments
            }'
            
        Write-Verbose 'Generate the process block'
        [void]$FunctionCode.Add($String)

        Write-Verbose 'Generate the End Block'
        [void]$FunctionCode.Add("    }
        End {}")

        Write-Verbose 'Adding the last } to close out the function'
        [void]$FunctionCode.Add('}')

        Write-Verbose 'Writing the static function to the console'
        $FunctionCode
    }

    End {}
}

Invoke-BinaryFunctionGeneration -BinaryPath C:\Windows\System32 -BinaryExecutable Robocopy.exe -HelpArgument /? | clip.exe