#requires -module ActiveDirectory

#better approaches instead of relying on hard coded values
# set as parameter values

Function Get-DomainUser {
    [cmdletbinding()]
    Param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string]$OU,
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string]$Domain,
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string]$DC,
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$Department
    )
    Begin {
        Write-Verbose "[$((Get-Date).TimeofDay) BEGIN  ] Starting $($myinvocation.mycommand)"
        $properties = "Name", "SamAccountName", "UserPrincipalName", "Description", "Enabled"
        if ($Department) {
            $filter = "Department -eq '$Department'"
            $properties += "Title", "Department"
        }
        else {
            $Filter = "*"
        }
       
    } #begin

    Process {
        #moved to process block
        $paramhash = @{
            SearchBase = ""
            Server     = "$($dc).$($domain)"
            Filter     = $filter
        }
        Write-Verbose "[$((Get-Date).TimeofDay) PROCESS] Getting user accounts from $OU"
        $paramhash.SearchBase = $OU

        Write-Verbose "[$((Get-Date).TimeofDay) PROCESS] Connecting to domain controller $($dc.toupper())"
        Get-ADUser @paramhash
    } #process

    End {
        Write-Verbose "[$((Get-Date).TimeofDay) END    ] Ending $($myinvocation.mycommand)"

    } #end 

} #close Get-DomainUser

#RUN THE CODE
$data = @"
"OU","Domain","DC"
"OU=Employees,DC=company,DC=pri","company.pri","dom1"
"@

$data | ConvertFrom-Csv | get-domainuser -Verbose -Department sales