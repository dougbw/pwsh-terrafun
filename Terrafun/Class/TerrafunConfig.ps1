class TerrafunConfig
{
    # Properties
    [String]$DesiredVersion
    [DateTime]$LastUpdateCheck
    [string[]]$AvailableVersions

    # Constructor
    TfConfig ()
    {
    }

    [Void] ReadConfigFile()
    {
        $UserProfile = (Get-Item ~).FullName
        $WorkingDir = Join-Path -Path $UserProfile -ChildPath ".terrafun"
        $ConfigPath = Join-Path -Path $WorkingDir -ChildPath "config.json"
        Write-Debug ("reading config {0}" -f $ConfigPath)
        New-Item -ItemType Directory -Path $WorkingDir -Force -ErrorAction SilentlyContinue | Out-Null

        if (Test-Path $ConfigPath){
            $Config = Get-Content -Path $ConfigPath | ConvertFrom-Json
            $this.DesiredVersion = $Config.DesiredVersion
            $this.LastUpdateCheck = $Config.LastUpdateCheck
            $this.AvailableVersions = $Config.AvailableVersions
        }
    }  

    [Void] WriteConfigFile()
    {
        $UserProfile = (Get-Item ~).FullName
        $WorkingDir = Join-Path -Path $UserProfile -ChildPath ".terrafun"
        $ConfigPath = Join-Path -Path $WorkingDir -ChildPath "config.json"
        Write-Debug ("writing config {0}" -f $ConfigPath)
        $this | ConvertTo-Json | Out-File -FilePath $ConfigPath

    }

}
