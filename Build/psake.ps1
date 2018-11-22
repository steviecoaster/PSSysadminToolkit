[CmdletBinding()]
param()
# Psake makes variables declared here available in other scriptblocks
# Init some things
Properties {
    # Find the build folder based on build system
    $ProjectRoot = $env:BHProjectPath
    if (-not $ProjectRoot) {
        $ProjectRoot = Resolve-Path -Path "$PSScriptRoot\.."
    }

    $Timestamp = Get-Date -Format "yyyyMMdd-hhmmss"
    $PSVersion = $PSVersionTable.PSVersion
    $TestFile = "TestResults_PS${PSVersion}_${TimeStamp}.xml"
    $Lines = '-' * 70

    $DeploymentParams = @{
        Path    = "$ProjectRoot"
        Force   = $true
        Recurse = $false # We keep psdeploy artifacts, avoid deploying those
    }
    if ($ENV:BHCommitMessage -match "!verbose") {
        $DeploymentParams.Add('Verbose', $true)
    }

    $Continue = @{
        InformationAction = if ($PSBoundParameters['InformationAction']) {
            $PSBoundParameters['InformationAction']
        }
        else {
            'Continue'
        }
    }
}

Task 'Default' -Depends 'Test'

Task 'Init' {
    Set-Location -Path $ProjectRoot

    $CommitTag = if ($env:APPVEYOR_REPO_TAG_NAME) {
        $env:APPVEYOR_REPO_TAG_NAME
    }
    else {
        "None"
    }

    Write-Information @Continue @"
$Lines
Repository Branch: $env:APPVEYOR_REPO_BRANCH
Commit Tag: $CommitTag

Build System Details:
"@
    Get-Item 'ENV:BH*'
}

Task 'Test' -Depends 'Init' {
    Write-Information @Continue @"
$Lines
STATUS: Testing with PowerShell $PSVersion
"@
    # Testing links on github requires >= tls 1.2
    $SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

    # Import the module
    Import-Module "$ProjectRoot/PSSysadminToolkit.psd1"

    # Gather test results. Store them in a variable and file
    $PesterParams = @{
        Path         = "$ProjectRoot/Test"
        PassThru     = $true
        OutputFormat = 'NUnitXml'
        OutputFile   = "$ProjectRoot/$TestFile"
    }
    $TestResults = Invoke-Pester @PesterParams

    [Net.ServicePointManager]::SecurityProtocol = $SecurityProtocol

    # In Appveyor?  Upload our tests!
    If ($ENV:BHBuildSystem -eq 'AppVeyor') {
        (New-Object 'System.Net.WebClient').UploadFile(
            "https://ci.appveyor.com/api/testresults/nunit/$($env:APPVEYOR_JOB_ID)",
            "$ProjectRoot\$TestFile"
        )
    }

    Remove-Item -Path "$ProjectRoot/$TestFile" -Force -ErrorAction SilentlyContinue

    # Failed tests?
    # Need to tell psake or it will proceed to the deployment. Danger!
    if ($TestResults.FailedCount -gt 0) {
        Write-Error "Failed $($TestResults.FailedCount) tests; build failed!"
    }
}