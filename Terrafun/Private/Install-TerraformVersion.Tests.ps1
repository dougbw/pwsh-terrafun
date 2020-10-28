BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1','.ps1')
    . $PSScriptRoot/Get-Platform.ps1
    . $PSScriptRoot/Get-TerraformVersions.ps1
}

Describe 'Install-TerraformVersion' {

    It 'It should install the specified version' {
        $Config = @{
            AvailableVersions = Get-TerraformVersions
        }
        $LatestVersion = $Config.AvailableVersions | Select-Object -Last 1
        Get-ChildItem ~/.terrafun -filter ("terraform_{0}*" -f $LatestVersion) -ErrorAction SilentlyContinue | Get-ChildItem -filter "terraform*" -ErrorAction SilentlyContinue | Remove-Item -Force -ErrorAction SilentlyContinue
        $Environment = Install-TerraformVersion -Config $Config -Version $LatestVersion 
        $Environment.BinaryPath | Should -Exist
    }

}