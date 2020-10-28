BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1','.ps1')
}

Describe 'Get-TerraformVersions' {

    BeforeAll {
        $availableVersions = Get-TerraformVersions
    }

    It 'It should return 100+ available versions' {
        $availableVersions.Count | Should -BeGreaterThan 100
    }

    It 'It should return valid version numbers' {
        [version[]]$availableVersions | Should -BeOfType [version]
    }

}