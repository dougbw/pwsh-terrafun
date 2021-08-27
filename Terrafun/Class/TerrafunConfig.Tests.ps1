BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1','.ps1')
}

Describe 'TerrafunConfig.Unit' -Tag "Unit" {

    BeforeAll {
        Function Get-TerraformVersions{}
        Mock Get-TerraformVersions {
            Return @(
                "1.0.0"
                "2.0.0"
            )
        }
        $DateTimeString = Get-Date -format s "0001-01-01"
        Mock Get-Date {
            Return $DateTimeString
        }
    }

    BeforeEach {
        $ConfigPath = Join-Path -path $Home -ChildPath ".terrafun/config.json"
        Remove-item $ConfigPath -Force -ErrorAction SilentlyContinue
    }

    It 'Should be able to generate new config object' {
        $Config = [TerrafunConfig]::new()
        $ConfigJson = $Config | ConvertTo-Json -Compress
        $ConfigJson | Should -Be '{"DesiredVersion":null,"LastUpdateCheck":"0001-01-01T00:00:00","AvailableVersions":null}'
    }

    It 'Should be able to write a config file' {
        $ConfigPath = Join-Path -path $Home -ChildPath ".terrafun/config.json"

        $Config = [TerrafunConfig]::new()
        $Config.Read()
        $Config.Save()

        $ConfigPath | Should -Exist
        $Content = Get-Content $ConfigPath | ConvertFrom-Json | ConvertTo-Json -Compress
        $Content | Should -Be '{"DesiredVersion":null,"LastUpdateCheck":"0001-01-01T00:00:00","AvailableVersions":null}'
    }

    It 'Should be able to read a config file' {

        $Config = [TerrafunConfig]::new()
        $Config.Read()
        $Config.AvailableVersions = Get-TerraformVersions
        $Config.LastUpdateCheck = Get-Date -format s
        $Config.Save()

        $Config = [TerrafunConfig]::new()
        $Config.Read()
        $Config | ConvertTo-Json -Compress | Should -be '{"DesiredVersion":"","LastUpdateCheck":"0001-01-01T00:00:00","AvailableVersions":["1.0.0","2.0.0"]}'

    }

}