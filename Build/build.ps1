param (
    [string[]]
    $Task = 'Default'
)

# Automatically kick off deploy task when committing to master (skip deploy on PRs to master)


# Grab nuget bits, set build variables, start build.
Get-PackageProvider -Name NuGet -ForceBootstrap > $null

Set-BuildEnvironment

Invoke-Psake -BuildFile "$PSScriptRoot\psake.ps1" -TaskList $Task -NoLogo

exit ([int](-not $Psake.Build_Success))