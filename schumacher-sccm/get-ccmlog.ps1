##############################
#.SYNOPSIS
# parses SCCM logs from a machine into an object
#
#.DESCRIPTION
# Creates a parsed object for the log passed via the computername and path Parameters.
#
#.Parameter ComputerName
#Computer name to retrieve the logs from
#
#.Parameter path
#Path on the computer where the logs reside.. Normally found in C:\windows\ccm\logs
#
#.Parameter log
#Dynamic Parameter that contains the logs found in the \\computername\path. 
# this dynamic Parameter is the name of all the files with the Extension of .log
#.EXAMPLE
#get-ccmlog -computername localhost -path c:\windows\ccm\logs -log [dynamic list of available logs]
#
#.NOTES
#This function is best used when running from the command line for troubleshooting reasons. If you include in, inline code you may get un-expected errors because of the way variables are parsed.  If you wish to use this in in line code than use the function called get-ccmspecificlog
#This function depends on Get-cmlog function.
#The return results for this function is an object with a prepended value of Log
#C:\>.\get-ccmlog -ComputerName localhost -path c:\ccm\logs -Log AlternateHandler
#
#    AlternateHandlerLog
#    {@{UTCTime=4/16/2018 8:01:35 AM; LocalTime=4/16/2018 1:01:35 PM; FileName=AlternateHandler.log; Component=AlternateHandler; Context=; Type=1; TID=; Reference=calternatehandler.cpp:470; Messag...
#
#
##############################
function Get-CCMLog
{
    Param([Parameter(Mandatory=$true,Position=0)]$ComputerName = $env:computername, [Parameter(Mandatory=$true,Position=1)]$path = 'c:\windows\ccm\logs')
    DynamicParam
    {
        $ParameterName = 'Log'
        if([system.string]::IsNullOrEmpty($ComputerName))
        {
            $ComputerName = $env:c
            $path = $env:p
        }
        if($path.ToCharArray() -contains ':')
        {

            $FilePath = "\\$($ComputerName)\$($path -replace ':','$')"
        }
        else
        {
            $FilePath = "\\$($ComputerName)\$((get-item $path).FullName -replace ':','$')"
        }
        
        $logs = Get-ChildItem "$FilePath\*.log"
        $LogNames = $logs.basename

        $logAttribute = New-Object System.Management.Automation.ParameterAttribute
        $logAttribute.Position = 2
        $logAttribute.Mandatory = $true
        $logAttribute.HelpMessage = 'Pick A log to parse'                

        $logCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
        $logCollection.add($logAttribute)

        $logValidateSet = New-Object System.Management.Automation.ValidateSetAttribute($LogNames)
        $logCollection.add($logValidateSet)

        $logParameter = New-Object System.Management.Automation.RuntimeDefinedParameter($ParameterName,[string],$logCollection)

        $logDictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
        $logDictionary.Add($ParameterName,$logParameter)
        return $logDictionary
           
        
    }
    begin {
        # Bind the Parameter to a friendly variable
        $Log = $PsBoundParameters[$ParameterName]
    }

    process {
        $i = [system.net.dns]::GetHostAddresses('localhost').ipaddresstostring
        $I+=[system.net.dns]::GetHostAddresses($env:COMPUTERNAME).ipaddresstostring
        if( ([system.net.dns]::GetHostAddresses($ComputerName).ipaddresstostring | Where-object{$i -contains $_}) -gt 0)
        {
            $results = get-cmlog -Path  "$path\$log.log"
        }
        else
        {
            $sb2 = "$((Get-ChildItem function:get-cmlog).scriptblock)`r`n"
            $sb1 = [scriptblock]::Create($sb2)
            $results = Invoke-Command -ComputerName $ComputerName -ScriptBlock $sb1 -ArgumentList "$path\$log.log"   
        }
        [PSCustomObject]@{"$($log)Log"=$results}
    }

}