Import-Module -Force "./Terrafun/Terrafun.psd1"

BeforeAll {
}

Describe 'Invoke-Terrafun.Acceptance' -Tag "Acceptance" {

    InModuleScope "Terrafun" {

        BeforeAll  {
            # run acceptance tests on n-3 major.minor versions
            # include all patch releases within those versions
            # e.g if latest version is 1.5.0 then all of the current versions are in scope
            # 1.5.x (n)
            # 1.4.x (n-1)
            # 1.3.x (n-2)
            # 1.2.x (n-3)
            $AllVersions = Invoke-Terrafun version list
            $NMinus3Versions = [version[]]$AllVersions | Group-Object -property Major, Minor | Select-Object -Last 4
            $TargetVersions = [string[]]$NMinus3Versions.Group
        }

        BeforeEach {
            Push-Location
            Set-Location -Path "TestDrive:\"
            Remove-Item ".terraformversion" -Force -ErrorAction SilentlyContinue
        }

        AfterEach {
            Pop-Location
        }

        It 'Defaults to the latest version' {

            # setup
            $ConfigPath = Join-Path -path $HOME -ChildPath ".terrafun/config.json"
            Remove-item $ConfigPath -ErrorAction SilentlyContinue -Force

            # execute
            $Version = Invoke-Terrafun version -json | ConvertFrom-Json

            # assert
            $Version.terraform_outdated | Should -Be $False
        }

        It 'Lists the available versions' {

            # execute
            $Output = Invoke-Terrafun version list

            # assert
            $Output.count | Should -BeGreaterThan 100
        }

        It 'Sets the correct version inside the current directory' {

            # execute
            Invoke-Terrafun version 1.0.0
            Invoke-Terrafun version global 1.0.1
            $Content = Get-Content ".terraformversion"
            $Version = Invoke-Terrafun version -json | ConvertFrom-Json

            # assert
            $Content | Should -Be "1.0.0"
            $Version.terraform_version | Should -Be "1.0.0"
        }

        It 'Sets the correct version in the user profile' {

            # execute
            Invoke-Terrafun version global 1.0.0
            $Version = Invoke-Terrafun version -json | ConvertFrom-Json

            # assert
            $Version.terraform_version | Should -Be "1.0.0"
        }

        It 'Uses the version set in the current directory when a user profile is present' {

            # setup
            Invoke-Terrafun version 1.0.0
            Invoke-Terrafun version global 1.0.1

            # execute
            $Content = Get-Content ".terraformversion"
            $Version = Invoke-Terrafun version -json | ConvertFrom-Json

            # assert
            $Content | Should -Be "1.0.0"
            $Version.terraform_version | Should -Be "1.0.0"
        }


        It 'Executes the "terraform version" command on version <_>' -ForEach ($TargetVersions) {

            # execute
            Invoke-Terrafun version $_
            $Version = Invoke-Terrafun version -json | ConvertFrom-Json

            # assert
            $Version.terraform_version | Should -Be $_
        }

        It 'Successfully executes the "terraform init" command on version <_>' -ForEach ($TargetVersions) {

            # setup
            $Content = @"
resource "local_file" "test" {
    content     = "apply_result_content"
    filename = "apply_result_filename"
}
"@
            $TestDirectory = "version-$_"
            mkdir $TestDirectory
            Set-Location $TestDirectory
            Set-Content -Path "main.tf" -Value $Content

            # execute
            Invoke-Terrafun version $_
            $Output = Invoke-Terrafun init -no-color | Out-String

            # assert
            $Output | Should -BeLike "*Terraform has been successfully initialized!*"
        }

        It 'Successfully executes the "terraform plan" command on version <_>' -ForEach ($TargetVersions) {

            # setup
            $TestDirectory = "version-$_"
            Set-Location $TestDirectory

            # execute
            Invoke-Terrafun version $_
            $PlanOutput = Invoke-Terrafun plan -no-color -out plan.tfstate | Out-String
            $PlanContent = Invoke-Terrafun show -json plan.tfstate | Convertfrom-json

            # assert
            $PlanContent.resource_changes.count | Should -BeExactly 1
            $PlanOutput | Should -BeLike "*Plan: 1 to add, 0 to change, 0 to destroy*"
        }

        It 'Successfully executes the "terraform apply" command on version <_>' -ForEach ($TargetVersions) {

            # setup
            $TestDirectory = "version-$_"
            Set-Location $TestDirectory

            # execute
            Invoke-Terrafun version $_
            $Output = Invoke-Terrafun apply --auto-approve -no-color | Out-String
            $Content = Get-Content -path "apply_result_filename"

            # assert
            $Content | Should -Be "apply_result_content"
            $Output | Should -BeLike "*Apply complete! Resources: 1 added, 0 changed, 0 destroyed*"
        }

    }


}