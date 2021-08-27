BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1','.ps1')
    . $PSScriptRoot/Get-Platform.ps1
    . $PSScriptRoot/Get-TerraformVersions.ps1
}

Describe 'Install-TerraformVersion.Integration' -Tag "Integration" {

    It 'It should install the latest version' {
        $Config = @{
            AvailableVersions = Get-TerraformVersions
        }
        $LatestVersion = $Config.AvailableVersions | Select-Object -Last 1
        Get-ChildItem ~/.terrafun -filter ("terraform_{0}*" -f $LatestVersion) -ErrorAction SilentlyContinue | Get-ChildItem -filter "terraform*" -ErrorAction SilentlyContinue | Remove-Item -Force -ErrorAction SilentlyContinue
        $Environment = Install-TerraformVersion -Config $Config -Version $LatestVersion
        $Output = & $Environment.BinaryPath version

        $Environment.BinaryPath | Should -Exist
        $Output | Should -Not -BeLike "*out*of*date*"
    }

    It 'It should install the specified version' {
        $Config = @{
            AvailableVersions = @(
                "1.0.0"
            )
        }
        $LatestVersion = $Config.AvailableVersions | Select-Object -Last 1
        Get-ChildItem ~/.terrafun -filter ("terraform_{0}*" -f $LatestVersion) -ErrorAction SilentlyContinue | Get-ChildItem -filter "terraform*" -ErrorAction SilentlyContinue | Remove-Item -Force -ErrorAction SilentlyContinue
        $Environment = Install-TerraformVersion -Config $Config -Version $LatestVersion 
        $Environment.BinaryPath | Should -Exist
    }

    It 'It should fail to install a non-existent version' {
        $Config = @{
            AvailableVersions = @(
                "1.0.0"
            )
        }
        {Install-TerraformVersion -Config $Config -Version "999.999.999"} | Should -Throw -ExpectedMessage "Could not find release for version 999.999.999"
    }

    It 'Should throw if terraform was not installed' {
        Mock Invoke-WebRequest {
            Param(
                $OutFile
            )
            Push-Location
            Set-Location -Path "TestDrive:\"
            Set-Content -Path "test.file" -value "test"
            compress-archive -Path test.file -DestinationPath test.zip
            $zip = Get-Item test.zip
            Pop-Location
            Copy-Item -Path $zip.fullname -Destination $OutFile
        }

        $Config = @{
            AvailableVersions = @(
                "1.0.0"
            )
        }
        $LatestVersion = $Config.AvailableVersions | Select-Object -Last 1
        Get-ChildItem ~/.terrafun -filter ("terraform_{0}*" -f $LatestVersion) -ErrorAction SilentlyContinue | Get-ChildItem -filter "terraform*" -ErrorAction SilentlyContinue | Remove-Item -Force -ErrorAction SilentlyContinue
        {Install-TerraformVersion -Config $Config -Version "1.0.0"} | Should -Throw -ExpectedMessage "failed to install terraform 1.0.0"

    }

}