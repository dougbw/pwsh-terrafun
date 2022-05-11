BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1','.ps1')
}

Describe 'Get-TerraformVersions.Unit' -Tag "Unit" {

        BeforeAll {
            Mock Invoke-WebRequest {
                Return @{
                    Links = @{
                        href = @(
                            "/terraform/1.1.0-alpha20210630"
                            "/terraform/1.1.0-alpha20210616"
                            "/terraform/1.0.4"
                            "/terraform/1.0.3"
                            "/terraform/1.0.2"
                            "/terraform/1.0.1"
                            "/terraform/1.0.0"
                            "/terraform/0.15.0-rc2"
                            "/terraform/0.15.0-rc1"
                            "/terraform/0.15.0-beta2"
                        )
                    }
                }
            }
        }
    
        It 'It should return the correct number of available versions' {
            $availableVersions = Get-TerraformVersions
            $availableVersions.Count | Should -BeExactly 5
        }
    
        It 'It should return valid version numbers' {
            $availableVersions = Get-TerraformVersions
            [version[]]$availableVersions | Should -BeOfType [version]
        }

}

Describe 'Get-TerraformVersions.Integration' -Tag "Integration" {

    It 'It should return the correct number of available versions' {
        $availableVersions = Get-TerraformVersions
        $availableVersions.Count | Should -BeGreaterThan 100
    }

    It 'It should return valid version numbers' {
        $availableVersions = Get-TerraformVersions
        [version[]]$availableVersions | Should -BeOfType [version]
    }

}