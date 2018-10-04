$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"

Describe 'Remove-ADDisabledUser tests' {   
    Mock Get-ADUser {
        New-Object Microsoft.ActiveDirectory.Management.ADUser Identity -Property @{
            SamAccountName = 'Tony.Stark'
            LastLogonDate = (Get-Date).AddDays(-35)
            Enabled = $False
        }
    }

    Mock Remove-ADUser { }
     
    It 'Should return nothing' {
        Remove-ADDisabledUser | Should -Be $null
    }
    It 'Should invoke Get-ADUser 1 time' {
        Assert-MockCalled Get-ADUser -Times 1 -Exactly
    }
    It 'Should invoke Remove-ADUser 1 time' {
        Assert-MockCalled Remove-ADUser -Times 1 -Exactly
    }

    Context 'Testing -OutputUsers switch' {
        $TestResult = Remove-ADDisabledUser -OutputUsers
        
        It 'Should return a single user' {
            @($TestResult).count | Should -Be 1
        }
        It 'Should return an ADUser object' {
            $TestResult | Should -BeOfType Microsoft.ActiveDirectory.Management.ADUser
        }
    }

    Context 'Testing -Verbose output' {
        Mock Get-ADUser { }    
        Mock Write-Verbose { }

        $TestResult = Remove-ADDisabledUser -Verbose -OutputUsers
 
        It 'Should return nothing' {
            $TestResult | Should -Be $null
        }               
        It 'Should invoke Get-ADUser 1 time' {
            Assert-MockCalled Get-ADUser -Times 1 -Exactly
        }
        It 'Should invoke Write-Verbose 1 time' {
            Assert-MockCalled Write-Verbose -Times 1 -Exactly
        }
    }
}

