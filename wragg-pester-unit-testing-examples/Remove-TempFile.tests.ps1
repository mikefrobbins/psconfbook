$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"

Describe 'Remove-TempFile tests' {
    Mock Remove-Item { }

    New-Item TestDrive:\test.tmp
    New-Item TestDrive:\tmp.doc

    $TestResult = Remove-TempFile -Path TestDrive:\
    
    It 'Should return nothing' {     
        $TestResult | Should -Be $null
    }
    It 'Should call Remove-Item' {     
        Assert-MockCalled Remove-Item -Times 1
    }
}
