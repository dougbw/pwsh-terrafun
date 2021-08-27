Function Update-AvailableTerraformVersions {
    [cmdletbinding()]
    Param(
        [parameter(Mandatory = $True)]
        $Config
    )

    # check for new releases
    $Now = Get-Date -Format s (Get-Date).ToUniversalTime()
    $Start = Get-Date -Format s (Get-Date $Config.LastUpdateCheck)

    $Timespan = New-TimeSpan -Start $Start -End $Now

    Write-Debug ("Config.LastUpdateCheck: {0}" -f $Config.LastUpdateCheck)
    Write-Debug ("Now: {0}" -f $Now)
    Write-Debug ("Start: {0}" -f $Start)
    Write-Debug ("Minutes since last update check: {0}" -f [int]$Timespan.TotalMinutes)

    if ($Timespan.TotalHours -gt 1) {
        $Config.AvailableVersions = Get-TerraformVersions
        $Config.LastUpdateCheck = $Now
        $Config.Save()
    }

}