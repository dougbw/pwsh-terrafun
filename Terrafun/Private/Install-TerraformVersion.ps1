Function Install-TerraformVersion {
    [cmdletbinding()]
    Param(
        [parameter(Mandatory = $True)]
        [string]
        $Version,

        [parameter(Mandatory = $True)]
        $Config
    )
    
    # install desired version
    # platform = windows, linux, darwin
    # arch = 386, amd64
    # version
    # E.g https://releases.hashicorp.com/terraform/0.12.19/terraform_0.12.19_windows_386.zip
    
    $Environment = @{
        Platform   = $null
        Arch       = $null
        BinaryPath = $null
        BinaryName = $null
    }

    # Determine platform
    $Environment.Platform = Get-Platform
    if ($Environment.Platform -eq "windows"){
        $Environment.BinaryName = "terraform.exe"
    }
    else{
        $Environment.BinaryName = "terraform"
    }
    
    # Determine arch
    if ([Environment]::Is64BitOperatingSystem) {
        $Environment.Arch = "amd64"
    }
    else {
        $Environment.Arch = "386"
    }
    
    $Url = "https://releases.hashicorp.com/terraform/{0}/terraform_{0}_{1}_{2}.zip" -f $Version, $Environment.Platform, $Environment.Arch
    $UserProfile = (Get-Item ~).FullName
    $WorkingDir = Join-Path -Path $UserProfile -ChildPath ".terrafun"
    $BaseName = (Split-Path -Path $Url -Leaf)
    $DownloadFilePath = Join-Path -Path $WorkingDir -ChildPath $BaseName
    $DestinationDir = Join-Path -Path $WorkingDir -ChildPath ("terraform_{0}_{1}_{2}" -f $Version, $Environment.Platform, $Environment.Arch)
    $Environment.BinaryPath = Join-Path -Path $DestinationDir -ChildPath $Environment.BinaryName
    if (Test-Path -Path $Environment.BinaryPath) {
        Return $Environment
    }
    
    if ($Config.AvailableVersions -notcontains $Version) {
        throw ("Could not find release for version {0}" -f $Version)
    }

    New-Item -Path $DestinationDir -ItemType Directory -Force | Out-Null
    Write-Verbose ("downloading {0}..." -f $Url)
    $ProgressPreference = 'silentlyContinue'
    Invoke-WebRequest -Uri $Url -OutFile $DownloadFilePath
    Expand-Archive -Path $DownloadFilePath -DestinationPath $DestinationDir -Force
    Remove-Item $DownloadFilePath

    if (Test-Path -Path $Environment.BinaryPath) {

        if ($Environment.Platform -ne "windows"){
            & chmod +x $Environment.BinaryPath
        }

        Return $Environment
    }
    else {
        throw ("failed to install terraform {0}" -f $Version)
    }
    
}