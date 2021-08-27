Function Get-Platform {
    [cmdletbinding()]
    Param()

    # the IsWindows/IsMacOs/IsLinux variables are not present in powershell 5 and lower
    if ( -not (Test-Path 'variable:/IsWindows') ) {
        $script:IsWindows = $true
        $script:IsLinux = $false
        $script:IsMacOS = $false
    }

    # powershell 6+
    if ($IsWindows) {
        $Platform = "windows"
    }
    if ($IsMacOS) {
        $Platform = "darwin"
    }
    if ($IsLinux) {
        $Platform = "linux"
    }

    Return $Platform
}