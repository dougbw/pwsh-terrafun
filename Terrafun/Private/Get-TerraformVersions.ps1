Function Get-TerraformVersions {
    [cmdletbinding()]
    Param(
    )

    # api reference
    # https://releases.hashicorp.com/docs/api/v1/#operation/listReleasesV1

    $Releases = @()
    $Limit = 20
    $Uri = "https://api.releases.hashicorp.com/v1/releases/terraform?limit={0}" -f $Limit

    do{

        $Response = Invoke-RestMethod -Method Get -Uri $Uri -ContentType "application/json"
        if ($Response.count -eq 0){
            Break
        }
        $Releases += $Response

        # get the date of the oldest release - used for pagination
        # powershell automatically converts the timestamp strings to [datetime] objects
        # so the string needs to be formatted correctly when being used for pagination
        # this behaviour various across different powershell versions
        # see # https://github.com/PowerShell/PowerShell/issues/13592
        $OldestRelease = $Response.timestamp_created | Sort-Object {[datetime]$_} | Select-Object -First 1
        $AfterTimestamp = (Get-Date -Date $OldestRelease).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssK")
        $Uri = "https://api.releases.hashicorp.com/v1/releases/terraform?limit={0}&after={1}" -f $Limit, $AfterTimestamp
        Write-Debug -Message $Uri
        Write-Debug -Message ("AfterTimestamp={0}, page={1}, total={2}" -F $AfterTimestamp, $Response.count, $Releases.count)

    }
    until($Response.count -eq 0)

    $ReleaseVersions = $Releases | Where-Object {$_.is_prerelease -ne $True}
    $ReleaseVersions = $ReleaseVersions | Select-Object -ExpandProperty version

    Return [string[]]($ReleaseVersions | Sort-Object {[version] $_})
    
}