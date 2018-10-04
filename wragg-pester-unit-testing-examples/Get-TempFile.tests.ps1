$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"

Describe 'Get-TempFile tests' {
    Mock Get-ChildItem {
        New-Object System.IO.FileInfo 'test.tmp'
    }

    It 'Should return only .tmp files' {
        (Get-TempFile -Path TestDrive:\).Extension | Should -Be '.tmp'
    }
}