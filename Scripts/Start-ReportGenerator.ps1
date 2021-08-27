dotnet tool install --global dotnet-reportgenerator-globaltool --version 4.8.12

$CoverageFiles = @(
    "linux-core/coverage.xml"
    "macos-core/coverage.xml"
    "windows-core/coverage.xml"
    "windows-powershell/coverage.xml"
)  -join ";"

reportgenerator "-reports:$CoverageFiles" "-targetdir:coveragereport" -reporttypes:Cobertura "-sourcedirs:../Terrafun"