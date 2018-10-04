function Remove-ADDisabledUser {
    [cmdletbinding()]
    Param(
        [int]
        $Days = 30,
        
        [switch]
        $OutputUsers
    )

    $Users = Get-ADUser -Filter 'Enabled -eq $false' -Properties LastLogonDate
     
    $Users = $Users | Where-Object { $_.LastLogonDate -lt (Get-Date).AddDays(-$Days) }

    if (-not $Users) {
        Write-Verbose "No disabled users found older than $Days days"
    }
    else {
        $Users | Remove-ADUser
        Write-Verbose "$(@($Users).count) users removed."
    }

    if ($OutputUsers) {
        $Users
    }
}