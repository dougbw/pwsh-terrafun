Function Get-TerraformVersions {
    [cmdletbinding()]
    Param()
    
    $ReleaseUrl = "https://releases.hashicorp.com/terraform"
    $Pattern = '^\/terraform\/[0-9]+\.[0-9]+\.[0-9]+$'
    Write-Verbose "getting terraform versions..."
    $Response = Invoke-WebRequest -UseBasicParsing -Uri $ReleaseUrl
    $Versions = $Response.Links.href | Where-Object { $_ -like "/terraform*" }

    $Releases = @()
    foreach ($Version in $Versions){
        if ($Version -match $Pattern){
            $Releases += $Version -replace "/terraform" -replace "/"
        }
    }
    
    Return [string[]]($Releases | Sort-Object {[version] $_})
}