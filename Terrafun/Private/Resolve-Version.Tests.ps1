BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1','.ps1')
}

Describe 'Resolve-Version' -Tag Unit {

    BeforeEach {
        Push-Location
        Set-Location -Path "TestDrive:\"
        $env:terraformversion=$null
        Remove-Item "env:/terraformversion" -ErrorAction SilentlyContinue -Force
        Remove-Item  "TestDrive:\.terraformversion" -ErrorAction SilentlyContinue -Force
    }

    AfterEach {
        $env:terraformversion=$null
        Remove-Item  "env:/terraformversion" -ErrorAction SilentlyContinue -Force
        Remove-Item  "TestDrive:\.terraformversion" -ErrorAction SilentlyContinue -Force
        Pop-Location
    }

    It 'It should default to the latest version' {
        $Config = @{
            AvailableVersions = @(
                "1.0.0"
                "2.0.0"
                "3.0.0"
            )
        }
        $Version = Resolve-Version -Config $Config
        $Version.DesiredVersion | Should -BeExactly "3.0.0"
        $Version.Source | Should -BeExactly "latest"
    }

    It 'It should resolve the correct version specified by .terraformversion file' {
        $Config = @{
            AvailableVersions = @(
                "1.0.0"
                "2.0.0"
            )
            DesiredVersion = "1.0.0"
        }
        Set-Content "TestDrive:\.terraformversion" -value "2.0.0"
        $Version = Resolve-Version -Config $Config
        $Version.DesiredVersion | Should -BeExactly "2.0.0"
        $Version.Source | Should -BeExactly "file"
    }

    It 'It should resolve the correct version specified by environment variable' {
        $Config = @{
            AvailableVersions = @(
                "1.0.0"
                "2.0.0"
                "3.0.0"
            )
            DesiredVersion = "1.0.0"
        }
        Set-Content "TestDrive:\.terraformversion" -value "2.0.0"
        $env:terraformversion="3.0.0"
        $Version = Resolve-Version -Config $Config
        $Version.DesiredVersion | Should -BeExactly "3.0.0"
        $Version.Source | Should -BeExactly "environment"
    }


    It 'It should resolve the correct version specified by profile configuration' {
        $Config = @{
            AvailableVersions = @(
                "1.0.0"
                "2.0.0"
            )
            DesiredVersion = "2.0.0"
        }
        $Version = Resolve-Version -Config $Config
        $Version.DesiredVersion | Should -BeExactly "2.0.0"
        $Version.Source | Should -BeExactly "profile"
    }


    It 'It should fail to resolve a non-existent version provided by configuration' {
        $Config = @{
            AvailableVersions = @(
                "1.0.0"
            )
            DesiredVersion = "999.999.999"
        }
        {Resolve-Version -Config $Config} | Should -Throw "unable to find specified terraform version: source=profile, version=999.999.999"
    }

    It 'It should fail to resolve a non-existent version provided by environment variable' {
        $Config = @{
            AvailableVersions = @(
                "1.0.0"
            )
        }
        $env:terraformversion = "999.999.999"
        {Resolve-Version -Config $Config} | Should -Throw "unable to find specified terraform version: source=environment, version=999.999.999"
        $env:terraformversion = $null
    }

    It 'It should fail to resolve a non-existent version provided by file' {
        $Config = @{
            AvailableVersions = @(
                "1.0.0"
            )
        }
        Push-Location
        Set-Location -Path "TestDrive:\"
        Set-Content "TestDrive:\.terraformversion" -value "999.999.999"
        {Resolve-Version -Config $Config} | Should -Throw "unable to find specified terraform version: source=file, version=999.999.999"
        Pop-Location
    }

}