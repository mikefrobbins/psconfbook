<#
.SYNOPSIS
Parses logs for System Center Configuration Manager.
.DESCRIPTION
Accepts a single log file or array of log files and parses them into objects.  Shows both UTC and local time for troubleshooting across time zones.
.ParameterETER Path
Specifies the path to a log file or files.
.INPUTS
Path/FullName.  
.OUTPUTS
PSCustomObject.  
.EXAMPLE
C:\PS> Get-CMLog -Path Sample.log
Converts each log line in Sample.log into objects
UTCTime   : 7/15/2013 3:28:08 PM
LocalTime : 7/15/2013 2:28:08 PM
FileName  : sample.log
Component : TSPxe
Context   : 
Type      : 3
TID       : 1040
Reference : libsmsmessaging.cpp:9281
Message   : content location request failed
.EXAMPLE
C:\PS> Get-ChildItem -Path C:\Windows\CCM\Logs | Select-String -Pattern 'failed' | Select -Unique Path | Get-CMLog
Find all log files in folder, create a unique list of files containing the phrase 'failed, and convert the logs into objects
UTCTime   : 7/15/2013 3:28:08 PM
LocalTime : 7/15/2013 2:28:08 PM
FileName  : sample.log
Component : TSPxe
Context   : 
Type      : 3
TID       : 1040
Reference : libsmsmessaging.cpp:9281
Message   : content location request failed
.LINK
http://blog.richprescott.com
#>
function Get-CMLog
{

    Param(
    [Parameter(Mandatory=$true,
               Position=0,
               ValueFromPipelineByPropertyName=$true)]
    [Alias("FullName")]
    $Path,
    $tail =10
    )
    PROCESS
    {

        if(($Path -isnot [array]) -and (test-path $Path -PathType Container) )
        {
            $Path = Get-ChildItem "$path\*.log"
        }
        
        foreach ($File in $Path)
        {
            if(!( test-path $file))
            {
                $Path +=(Get-ChildItem "$file*.log").fullname
            }
            $FileName = Split-Path -Path $File -Leaf
            if($tail)
            {
                $lines = Get-Content -Path $File -tail $tail 
            }
            else {
                $lines = get-cotnet -path $file
            }
            ForEach($l in $lines ){
                $l -match '\<\!\[LOG\[(?<Message>.*)?\]LOG\]\!\>\<time=\"(?<Time>.+)(?<TZAdjust>[+|-])(?<TZOffset>\d{2,3})\"\s+date=\"(?<Date>.+)?\"\s+component=\"(?<Component>.+)?\"\s+context="(?<Context>.*)?\"\s+type=\"(?<Type>\d)?\"\s+thread=\"(?<TID>\d+)?\"\s+file=\"(?<Reference>.+)?\"\>' | Out-Null
                    if($matches)
                    {
                        $UTCTime = [datetime]::ParseExact($("$($matches.date) $($matches.time)$($matches.TZAdjust)$($matches.TZOffset/60)"),"MM-dd-yyyy HH:mm:ss.fffz", $null, "AdjustToUniversal")
                        $LocalTime = [datetime]::ParseExact($("$($matches.date) $($matches.time)"),"MM-dd-yyyy HH:mm:ss.fff", $null)
                    }
                    [pscustomobject]@{
                        UTCTime = $UTCTime
                        LocalTime = $LocalTime
                        FileName = $FileName
                        Component = $matches.component
                        Context = $matches.context
                        Type = $matches.type
                        TID = $matches.TI
                        Reference = $matches.reference
                        Message = $matches.message
                }
            }
        }
    }
}