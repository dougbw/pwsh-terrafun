Function Invoke-Terrafun {
    Param(
    )
        
    # load configuration
    $Config = [TerrafunConfig]::new()
    $Config.Read()
    
    # check for new releases
    Update-AvailableTerraformVersions -Config $Config

    # parse cmdline args for version selection
    $Opts = Resolve-Options -Arguments $args

    if ($Opts.versionIsPresent -and $Opts.ListIsPresent){
        Get-TerraformVersions
        Return
    }

    if ($Opts.versionIsPresent -and $Opts.versionNumberIsValid){
        $ShouldExecuteTerraform = $false
        if ($Opts.globalIsPresent){
            $Config.DesiredVersion = $Opts.versionNumber
            $Config.Save()
        }
        else{
            Set-Content -Path ".terraformversion" -Value $Opts.versionNumber -NoNewline
        }
    }

    # resolve which version of terraform to use
    $Version = Resolve-Version -Config $Config
    
    # install required terraform version
    $Environment = Install-TerraformVersion -Config $Config -Version $Version.DesiredVersion

    # if we are only managing versions then exit now
    if ($ShouldExecuteTerraform -eq $false){
        Return
    }

    Write-Verbose ("terrafun: platform={0}, arch={1}, version_source={3}, version={2}" -f $Environment.Platform, $Environment.Arch, $Version.DesiredVersion, $Version.Source)

    # execute terraform
    & $Environment.BinaryPath $args
    
}