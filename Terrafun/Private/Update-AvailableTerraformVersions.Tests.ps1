BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1','.ps1')
    . $PSScriptRoot/../Class/TerrafunConfig.ps1
}

Describe 'Update-AvailableTerraformVersions.Unit' -Tag Unit {

    BeforeAll {
        Function Get-TerraformVersions{}
        Mock Get-TerraformVersions {
            return @()
        }
    }

    It 'Should check for new versions if the last check was more than 1 hour ago' {
        $Config = [TerrafunConfig]::new()
        $Config.Read()
        $Config.LastUpdateCheck = Get-Date -Format s (Get-Date).AddMinutes(-61).ToUniversalTime()

        Update-AvailableTerraformVersions -Config $Config
        Should -Invoke -CommandName Get-TerraformVersions -Times 1
    }

    It 'Should not for new versions if the last check was less than 1 hour ago' {
        $Config = [TerrafunConfig]::new()
        $Config.Read()
        $Config.LastUpdateCheck = Get-Date -Format s (Get-Date).AddMinutes(-59).ToUniversalTime()

        Update-AvailableTerraformVersions -Config $Config
        Should -Invoke -CommandName Get-TerraformVersions -Times 0
    }



}