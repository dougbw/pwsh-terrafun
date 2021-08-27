Function Resolve-Options {
    [cmdletbinding()]
    Param(
        [array]$Arguments
    )

    $Options = @{
        globalIsPresent      = $false
        listIsPresent = $false
        versionIsPresent     = $false
        versionNumberIsValid = $false
        versionNumber = $null
        
    }

    foreach ($Argument in $Arguments) {

        switch ($Argument) {
            { $_ -match '^version$' } {
                $Options.versionIsPresent = $true
                Write-Debug "versionIsPresent = true"
            }

            { try { [version]$_ }catch {} } {
                $Options.versionNumberIsValid = $true
                $Options.versionNumber = $_
                Write-Debug "versionNumberIsValid = true"
            }

            { $_ -match '^list$' } {
                $Options.listIsPresent = $true
                Write-Debug "listIsPresent = true"
            }
            
            { $_ -match '^global$' } {
                $Options.globalIsPresent = $true
                Write-Debug "globalIsPresent = true"
            }

        }
    }
    $Options | ConvertTo-Json | Write-Debug
    Return $Options

}