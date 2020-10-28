BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1','.ps1')
}

Describe 'Resolve-Version' {

    BeforeAll {
    }

    It 'It should detect the version from .terraform-version files' {
        $Config = @{
            AvailableVersions = @(
                "1.0.0"
            )
            DesiredVersion = "1.0.0"
        }
        Push-Location
        Set-Location -Path "TestDrive:\"
        Set-Content "TestDrive:\.terraform-version" -value "1.0.0"
        $Version = Resolve-Version -Config $Config
        Pop-Location

        $Version.DesiredVersion | Should -BeExactly "1.0.0"
        $Version.Source | Should -BeExactly ".terraform-version"
    }

    It 'It should detect the version from user profile config file' {
        $Config = @{
            AvailableVersions = @(
                "1.0.0"
            )
            DesiredVersion = "1.0.0"
        }
        $Version = Resolve-Version -Config $Config
        $Version.DesiredVersion | Should -BeExactly "1.0.0"
        $Version.Source | Should -BeExactly "user profile"
    }

    It 'It should default to the latest version if no version is provided' {
        $Config = @{
            AvailableVersions = @(
                "1.0.0"
                "2.0.0"
            )
        }
        $Version = Resolve-Version -Config $Config
        $Version.DesiredVersion | Should -BeExactly "2.0.0"
        $Version.Source | Should -BeExactly "latest"
    }

}