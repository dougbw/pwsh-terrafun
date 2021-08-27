class TerrafunConfig
{
    # Properties
    [String]$DesiredVersion
    [String]$LastUpdateCheck
    [string[]]$AvailableVersions

    # Constructor
    TerrafunConfig ()
    {
        $this.LastUpdateCheck = Get-Date -format s "0001-01-01"
    }

    [Void] Read()
    {
        $UserProfile = (Get-Item ~).FullName
        $WorkingDir = Join-Path -Path $UserProfile -ChildPath ".terrafun"
        $ConfigPath = Join-Path -Path $WorkingDir -ChildPath "config.json"
        Write-Debug ("reading config {0}" -f $ConfigPath)
        New-Item -ItemType Directory -Path $WorkingDir -Force -ErrorAction SilentlyContinue | Out-Null

        if (Test-Path $ConfigPath){
            $Config = Get-Content -Path $ConfigPath | ConvertFrom-Json
            $this.DesiredVersion = $Config.DesiredVersion
            $this.LastUpdateCheck = Get-Date -Format s $Config.LastUpdateCheck
            $this.AvailableVersions = $Config.AvailableVersions
        }
    }  

    [Void] Save()
    {
        $UserProfile = (Get-Item ~).FullName
        $WorkingDir = Join-Path -Path $UserProfile -ChildPath ".terrafun"
        $ConfigPath = Join-Path -Path $WorkingDir -ChildPath "config.json"
        Write-Debug ("writing config {0}" -f $ConfigPath)
        $this | ConvertTo-Json | Out-File -FilePath $ConfigPath
    }

}
