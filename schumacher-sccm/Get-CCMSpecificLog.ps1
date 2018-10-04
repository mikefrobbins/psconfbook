function Get-CCMSpecificLog
    {
        param([Parameter(Mandatory=$true,Position=0)]$ComputerName = $env:computername, 
        [Parameter(Mandatory=$true,Position=1)]$path = 'c:\windows\ccm\logs',
        [Parameter(Mandatory=$true,Position=1)]$log = 'smsts' )
        
        begin {
            
        }
    
        process 
        {
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
