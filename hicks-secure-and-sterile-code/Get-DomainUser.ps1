#requires -module ActiveDirectory

Function Get-DomainUser {
    [cmdletbinding()]
    Param(
        [Parameter(ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [string]$OU = "OU=Employees,DC=Company,DC=pri",
        [string]$Department
    )
    Begin {
        Write-Verbose "[$((Get-Date).TimeofDay) BEGIN  ] Starting $($myinvocation.mycommand)"
        
        $domain = "company.pri"   # <--- hard coded values
        $dc = "dom1"              # <--- hard coded values

        $properties = "Name","SamAccountName","UserPrincipalName","Description","Enabled"
        
        if ($Department) {
            $filter = "Department -eq '$Department'"
            $properties += "Title","Department"
        }
        else {
            $Filter = "*"
        }
        $paramhash = @{
            SearchBase = ""
            Server = "$dc.$domain"
            Filter = $filter
        }
    } #begin

    Process {
        Write-Verbose "[$((Get-Date).TimeofDay) PROCESS] Getting user accounts from $OU"
        $paramhash.SearchBase = $OU

        Write-Verbose "[$((Get-Date).TimeofDay) PROCESS] Connecting to domain controller $($dc.toupper())"
        $paramhash | out-string | Write-Verbose
        Get-ADUser @paramhash
        
    } #process

    End {
        Write-Verbose "[$((Get-Date).TimeofDay) END    ] Ending $($myinvocation.mycommand)"

    } #end 

} #close Get-DomainUser