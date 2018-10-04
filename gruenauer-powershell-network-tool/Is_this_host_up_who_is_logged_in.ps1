$cname=Read-Host -Prompt 'Enter Computername'
$test=Test-Connection -Destination $cname -Count 1 `
-ErrorAction SilentlyContinue
$result=@()
If ($test) {
     $message=Read-Host -Prompt 'Enter message'
     Invoke-Command -ComputerName $cname `
     -ScriptBlock {quser.exe} | Select-Object -Skip 1 |
     ForEach-Object {
     $b=$_.trim() -replace '\s+',' ' -replace '>','' -split '\s'
     $result+= New-Object -TypeName PSObject -Property ([ordered]@{
                'User' = $b[0]
                'Computer' = $cname
                'Session' = $b[1]
                'Date' = $b[5]
                'Time' = $b[6..7] -join ' '
                })      
                }
      $result | Format-Table
      Invoke-Command -ComputerName $cname `
      -ScriptBlock {msg.exe * /V $using:message} `
      -ErrorAction SilentlyContinue
           }
else {
        Write-Host "Failed to connect to $cname"
        throw 'Error'
     }