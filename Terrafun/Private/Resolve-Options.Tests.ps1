BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1','.ps1')
}

Describe 'Resolve-Options.Unit' -Tag Unit {

    BeforeAll {
    }

    It 'Given no parameters, it should return expected values' {
        $Arguments = @()
        $Options = Resolve-Options -Arguments $Arguments
        $Options.versionNumberIsValid | Should -BeFalse
        $Options.listIsPresent | Should -BeFalse
        $Options.globalIsPresent | Should -BeFalse
        $Options.versionIsPresent | Should -BeFalse
    }

    It 'Given parameters, it should return expected values' {
        $Arguments = @(
            "version"
            "list"
            "global"
            "1.0.0"
        )
        $Options = Resolve-Options -Arguments $Arguments
        $Options.versionNumberIsValid | Should -BeTrue
        $Options.listIsPresent | Should -BeTrue
        $Options.globalIsPresent | Should -BeTrue
        $Options.versionIsPresent | Should -BeTrue
        $Options.versionNumber | Should -BeExactly "1.0.0"
    }



}