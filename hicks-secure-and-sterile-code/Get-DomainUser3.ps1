#requires -module ActiveDirectory

#Using configuration data

Function Get-DomainUser {
    [cmdletbinding()]
    Param(
        [Parameter(Mandatory)]
        [ValidateScript({Test-Path $_})]
        [string]$ConfigurationData,
        [string]$Department
    )
    Begin {
        Write-Verbose "[$((Get-Date).TimeofDay) BEGIN  ] Starting $($myinvocation.mycommand)"

        #import the configuration data into the function
        $config = Import-PowerShellDataFile -Path $ConfigurationData
       
        $properties = "Name","SamAccountName","UserPrincipalName","Description","Enabled"
        if ($Department) {
            $filter = "Department -eq '$Department'"
            $properties += "Title","Department"
        }
        else {
            $Filter = "*"
        }

        #use the configuration data values
        $paramhash = @{
            SearchBase = $config.ou
            Server = "$($config.dc).$($config.domain)"
            Filter = $filter
        }
    } #begin

    Process {
        Write-Verbose "[$((Get-Date).TimeofDay) PROCESS] Getting user accounts from $($config.ou)"
        Write-Verbose "[$((Get-Date).TimeofDay) PROCESS] Connecting to domain controller $(($config.dc).toupper())"
    
        Get-ADUser @paramhash
    
    } #process

    End {
        Write-Verbose "[$((Get-Date).TimeofDay) END    ] Ending $($myinvocation.mycommand)"

    } #end 

} #close Get-DomainUser

