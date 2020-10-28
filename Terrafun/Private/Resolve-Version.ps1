Function Resolve-Version {
    [cmdletbinding()]
    Param(
        $Config
    )

    # order of precedence for desired version:
    # .terrafun-version > $env:terraform_version > user profile > default to latest

    $ErrorActionPreference = "stop"

    $Version = [pscustomobject]@{
        DesiredVersion = $null
        Source         = $null
    }

    # check user profile
    if ($Config.DesiredVersion) {
        if ($Config.AvailableVersions -contains $Config.DesiredVersion) {
            $Version.DesiredVersion = $Config.DesiredVersion
            $Version.Source = "user profile"
        }
        else {
            Write-Error ("unable to find specified terraform version {0}" -f $Config.DesiredVersion)
        }
    }
    
    # check env variable
    if ($env:terraform_version) {
        if ($Config.AvailableVersions -contains $env:terraform_version) {
            $Version.DesiredVersion = $env:terraform_version
            $Version.Source = '$env:terraform_version'
        }
        else {
            Write-Error ("unable to find specified terraform version {0}" -f $env:terraform_version)
        }
    }
    
    # check .terraform-version file
    if (Test-Path -Path ".terraform-version") {
        $VersionFile = (Get-Content -Path ".terraform-version" -Raw).Trim()
        if ($Config.AvailableVersions -contains $VersionFile) {
            $Version.DesiredVersion = $VersionFile
            $Version.Source = ".terraform-version"
        }
        else {
            Write-Error ("unable to find specified terraform version {0}" -f $VersionFile)
        }
        
    }
    
    # default to latest
    if ($null -eq $Version.DesiredVersion) {
        $Version.DesiredVersion = [version[]]$Config.AvailableVersions | Sort-Object -Descending | Select-Object -First 1
        $Version.Source = "latest"
    }

    Return $Version

}