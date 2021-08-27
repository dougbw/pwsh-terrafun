BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1','.ps1')
}

Describe 'Get-Platform.Unit' -Tag "Unit" {

    It 'Should return a valid platform' {
        Get-Platform | Should -BeIn @('windows','darwin','linux')
    }

}