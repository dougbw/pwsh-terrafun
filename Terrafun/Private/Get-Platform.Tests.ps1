BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1','.ps1')
}

Describe 'Get-Platform' {

    It 'Should return a valid platform' {
        Get-Platform | Should -BeIn @('windows','darwin','linux')
    }

}