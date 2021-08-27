Function Resolve-Version {
    [cmdletbinding()]
    Param(
        $Config
    )

    # order of precedence for desired version:
    # .terraformversion > $env:terraformversion > user profile > default to latest

    $ErrorActionPreference = "stop"

    $Version = [pscustomobject]@{
        DesiredVersion = $null
        Source         = $null
    }

    # check user profile
    if ($Config.DesiredVersion) {
        if ($Config.AvailableVersions -contains $Config.DesiredVersion) {
            $Version.DesiredVersion = $Config.DesiredVersion
            $Version.Source = "profile"
        }
        else {
            throw ("unable to find specified terraform version: source={0}, version={1}" -f "profile", $Config.DesiredVersion)
        }
    }
    
    # check .terraformversion file
    if (Test-Path -Path ".terraformversion") {
        $VersionFile = (Get-Content -Path ".terraformversion" -Raw).Trim()
        if ($Config.AvailableVersions -contains $VersionFile) {
            $Version.DesiredVersion = $VersionFile
            $Version.Source = "file"
        }
        else {
            throw ("unable to find specified terraform version: source={0}, version={1}" -f "file", $VersionFile)
        }
        
    }

    # check env variable
    if ($env:terraformversion) {
        if ($Config.AvailableVersions -contains $env:terraformversion) {
            $Version.DesiredVersion = $env:terraformversion
            $Version.Source = 'environment'
        }
        else {
            throw ("unable to find specified terraform version: source={0}, version={1}" -f "environment", $env:terraformversion)
        }
    }
    
    # default to latest
    if ($null -eq $Version.DesiredVersion) {
        $Version.DesiredVersion = [version[]]$Config.AvailableVersions | Sort-Object -Descending | Select-Object -First 1
        $Version.Source = "latest"
    }

    Return $Version

}