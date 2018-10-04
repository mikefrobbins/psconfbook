Function New-CustomerOU {
    [CmdletBinding(SupportsShouldProcess = $True)]
    param(
        $CustomerName,
        $CustomerCode
    )

    $domainDN = (Get-ADDomain).DistinguishedName
    $ouCustomerName = 'OU={0} ({1}),OU=Customers,{2}' -f $CustomerName, $CustomerCode, $domainDN
    $ouExists = Get-ADOrganizationalUnit -Filter { DistinguishedName -like $ouCustomerName}

    If ($ouExists) {
        Write-verbose $('{0} exists' -f $ouCustomerName)
    }
    else {
        Write-verbose $("{0} doesn`'t exists. Creating OU" -f $ouCustomerName)
        $paramOU = @{
            Name                            = "{0} ({1})" -f $CustomerName, $CustomerCode
            Path                            = 'OU=Customers,{0}' -f $domainDN
            Description                     = 'Resources for {0}' -f $CustomerName
            ProtectedFromAccidentalDeletion = $false
        }

        New-ADOrganizationalUnit @paramOU
    }

    #Remove ACE from Customer OU
    $null = dsacls $($ouCustomerName) /R Everyone 'NT AUTHORITY\Authenticated Users' S-1-5-32-554
}
