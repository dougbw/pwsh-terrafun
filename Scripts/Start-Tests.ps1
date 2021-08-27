if (Get-Module -ListAvailable pester){
  Import-Module -Name Pester
}
else{
  Install-Module -Name Pester -Force -SkipPublisherCheck
  Import-Module -Name Pester
}

$Configuration = [PesterConfiguration]@{
  Output = @{
    Verbosity = "Detailed"
  }
  TestResult = @{
    Enabled = $true
  }
  Filter = @{
      Tag = @(
        "Unit"
        "Integration"
        "Acceptance"
      )
  }
  CodeCoverage = @{
      Enabled = $true
      CoveragePercentTarget = 95
      Path = @( 
      "*/Private/*.ps1"
      "*/Public/*.ps1"
      "*/Class/*.ps1"
      )
  }
}

Invoke-Pester -Configuration $Configuration