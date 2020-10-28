Function Invoke-Terrafun {
    Param(
    )
        
    # load configuration
    $Config = [TerrafunConfig]::new()
    $Config.ReadConfigFile()
    
    # check for new releases
    $Timespan = New-TimeSpan -Start $Config.LastUpdateCheck -End (Get-Date)
    if ($Timespan.TotalHours -gt 1) {
        $Config.AvailableVersions = Get-TerraformVersions
        $Config.LastUpdateCheck = Get-Date
        $Config.WriteConfigFile()
    }

    # parse cmdline args for version selection
    $Opts = Resolve-Options -Arguments $args

    if ($Opts.versionIsPresent -and $Opts.ListIsPresent){
        Get-TerraformVersions | Write-Verbose -Verbose
        Return
    }

    if ($Opts.versionIsPresent -and $Opts.versionNumberIsValid){
        $ShouldExecuteTerraform = $false
        if ($ArgOptions.globalVersion){
            $Config.DesiredVersion = $Opts.versionNumber
            $Config.WriteConfigFile()
        }
        else{
            Set-Content -Path ".terraform-version" -Value $Opts.versionNumber -NoNewline
        }
    }

    # resolve which version of terraform to use
    $Version = Resolve-Version -Config $Config
    
    # install required terraform version
    $Environment = Install-TerraformVersion -Config $Config -Version $Version.DesiredVersion
    Write-Verbose -Verbose ("terrafun: platform = {0}, arch = {1}, version_source = {3}, version = {2}" -f $Environment.Platform, $Environment.Arch, $Version.DesiredVersion, $Version.Source)

    # if we are only managing versions then exit now
    if ($ShouldExecuteTerraform -eq $false){
        Return
    }

    # execute terraform
    & $Environment.BinaryPath $args
    
}