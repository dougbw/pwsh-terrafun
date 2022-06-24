BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1','.ps1')
}

Describe 'Get-TerraformVersions.Unit' -Tag "Unit" {

        BeforeAll {

            Mock Invoke-RestMethod {
                Get-Content "$PSScriptRoot/Get-TerraformVersions.Tests.MockData.Page1.json" | ConvertFrom-Json
            }  -ParameterFilter {
                $Uri -eq "https://api.releases.hashicorp.com/v1/releases/terraform?limit=20"
            }

            Mock Invoke-RestMethod {
                Get-Content "$PSScriptRoot/Get-TerraformVersions.Tests.MockData.Page2.json" | ConvertFrom-Json
            } -ParameterFilter {
                $Uri -eq "https://api.releases.hashicorp.com/v1/releases/terraform?limit=20&after=2022-04-20T13:46:15Z"
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