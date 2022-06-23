Function Get-TerraformVersions {
    [cmdletbinding()]
    Param(
        $IncludePreRelease = $false
    )

    # https://releases.hashicorp.com/docs/api/v1/#operation/listReleasesV1

    $Limit = 20
    $Releases = @()
    $AfterTimestamp = Get-Date -Date (Get-Date).ToUniversalTime() -Format o
    
    do{

        $Uri = "https://api.releases.hashicorp.com/v1/releases/terraform?limit={0}&after={1}" -f $Limit, $AfterTimestamp
        $Response = Invoke-RestMethod -Method Get -Uri $Uri -ContentType "application/json"
        if ($Response.count -eq 0){
            Break
        }
        $Releases += $Response

        Write-Debug -Message $Uri
        Write-Debug -Message ("After={0}, AfterTimestamp={1}, page={2}, total={3}" -F $After, $AfterTimestamp, $Response.count, $Releases.count)

        # get the date of the oldest release - used for pagination
        [datetime]$After = $Response.timestamp_created | Sort-Object | Select-Object -First 1
        $AfterTimestamp = $After.ToString("o")

    }
    until($Response.count -eq 0)

    $ReleaseVersions = $Releases | Where-Object {$_.is_prerelease -ne $True}
    $ReleaseVersions = $ReleaseVersions | Select-Object -ExpandProperty version

    Return [string[]]($ReleaseVersions | Sort-Object {[version] $_})
    
}