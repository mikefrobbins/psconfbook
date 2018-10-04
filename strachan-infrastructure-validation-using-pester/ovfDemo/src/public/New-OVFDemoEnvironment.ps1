
Function New-OVFDemoEnvironment {
    [CmdletBinding(SupportsShouldProcess = $True)]
    param()

    #region Create Default OUs
    $OUs = @(
        'Customers'
        'Management'
    )

    $domainDN = (Get-ADDomain).DistinguishedName
    $OUs |
        ForEach-Object {
        $ou = $_
        $ouDN = 'OU={0},{1}' -f $_ , $domainDN
        $ouExists = Get-ADOrganizationalUnit -Filter { DistinguishedName -like $ouDN}

        If ($ouExists) {
            Write-verbose $('{0} exists' -f $ouDN)
        }
        else {
            Write-verbose $("{0} doesn`'t exists. Creating OU" -f $ouDN)
            $paramOU = @{
                Name                            = $ou
                Path                            = $domainDN
                ProtectedFromAccidentalDeletion = $true
            }

            New-ADOrganizationalUnit @paramOU
        }
    }

    #endregion

    #region Create Default Security groups
    @"
Name;GroupCategory;GroupScope;Path
PROXY ADMINS;Security;Global;OU=Management,DC=pshirwin,DC=local
PROXY NONE;Security;Global;OU=Management,DC=pshirwin,DC=local
PROXY PARTIAL;Security;Global;OU=Management,DC=pshirwin,DC=local
SERVICEADMINS Proxy;Security;Global;OU=Management,DC=pshirwin,DC=local
FS FULL;Security;Global;OU=Management,DC=pshirwin,DC=local
FS READ;Security;Global;OU=Management,DC=pshirwin,DC=local
FS NONE;Security;Global;OU=Management,DC=pshirwin,DC=local
FS LIST;Security;Global;OU=Management,DC=pshirwin,DC=local
PROXY Users;Security;DomainLocal;OU=Management,DC=pshirwin,DC=local
"@ |
        ConvertFrom-Csv -Delimiter ';' |
        ForEach-Object {

        $distinguishedNameGroup = 'CN={0},{1}' -f $_.Name, $_.Path

        $groupExists = Get-ADGroup -f {DistinguishedName -like $distinguishedNameGroup}

        If ($groupExists) {
            Write-Verbose $('{0} exists' -f $distinguishedNameGroup)
        }
        else {
            Write-Verbose $("{0} doesn`'t exists. Creating group" -f $distinguishedNameGroup)
            $paramADGroup = @{
                Name          = $_.Name
                Path          = $_.Path
                Description   = $_.Name
                GroupScope    = $_.GroupScope
                GroupCategory = $_.GroupCategory
            }

            New-ADGroup @paramADGroup
        }
    }
    #endregion

    #region Create Default Share
    $paramSMBShare = @{
        Path       = 'c:\Data01'
        Name       = 'Data01$'
        FullAccess = 'Everyone'
    }

    $GetSMBShares = Get-SMBShare

    If (!($GetSMBShares.Name.Contains($paramSMBShare.Name))) {
        Write-Verbose "SMBShare doesn't exist"
        if (!(Test-Path $paramSMBShare.Path)) {
            Write-Verbose "Creating Path $($paramShare.Path)"
            New-Item -Path $paramSMBShare.Path -ItemType Directory

            Write-Verbose "Creating Share $($paramSMBShare.Name)"
            New-SmbShare @paramSMBShare
        }
        else {
            Write-Verbose "Path $($paramSMBShare.Path) exists. Creating Share $($paramSMBShare.Name)"
            New-SmbShare @paramSMBShare
        }
    }
    else {
        Write-Verbose "SMBShare $($paramSMBShare.Name) exist"
    }

    #endregion

    #region Create Default DFSNamespace

    #region Create Default DFSNRoot Share
    $paramSMBShare = @{
        Path       = 'c:\DFSRoots\Data'
        Name       = 'Data'
        FullAccess = 'Everyone'
    }

    $GetSMBShares = Get-SMBShare

    If (!($GetSMBShares.Name.Contains($paramSMBShare.Name))) {
        Write-Verbose "SMBShare doesn't exist"
        if (!(Test-Path $paramSMBShare.Path)) {
            Write-Verbose "Creating Path $($paramShare.Path)"
            New-Item -Path $paramSMBShare.Path -ItemType Directory

            Write-Verbose "Creating Share $($paramSMBShare.Name)"
            New-SmbShare @paramSMBShare
        }
        else {
            Write-Verbose "Path $($paramSMBShare.Path) exists. Creating Share $($paramSMBShare.Name)"
            New-SmbShare @paramSMBShare
        }
    }
    else {
        Write-Verbose "SMBShare $($paramSMBShare.Name) exist"
    }
    #endregion

    #region Creating DFSnRoot
    $paramDFSRoot = @{
        TargetPath = '\\EC2AMAZ-A3PBTBU.pshirwin.local\Data'
        Type       = 'DomainV2'
        Path       = '\\pshirwin.local\Data'
    }
    $GetDFSnRoots = Get-DFSnRoot

    if (!($GetDFSnRoots.Path -Contains $paramDFSRoot.Path )) {
        Write-Verbose "DFSn Root $($paramDFSRoot.Path) doesn't exists."
        if (Test-Path $paramDFSRoot.TargetPath) {
            Write-Verbose "Creating DFSn Root $($paramDFSRoot.Path)."
            New-DfsnRoot @paramDFSRoot
        }
    }
    else {
        Write-Verbose "DFSN Root $($paramDFSRoot.Path) exists"
    }
    #endregion

    #endregion
}
