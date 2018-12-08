[cmdletBinding()]
Param(
    [Parameter(Position=0)]
    [String]
    $Key
)
$Manifest = Import-PowerShellDataFile .\PSSysadminToolkit.psd1 
[version]$version = $Manifest.ModuleVersion
# Add one to the build of the version number
[version]$NewVersion = "{0}.{1}.{2}" -f $Version.Major, $Version.Minor, ($Version.Build + 1) 
# Update the manifest file
Update-ModuleManifest -Path .\PSSysadminToolkit.psd1 -ModuleVersion $NewVersion

    $PublishOptions = @{
        Name = "$PSScriptRoot\PSSysadminToolkit.psd1"
        NuGetApiKey = $Key
        LicenseUri = "https://github.com/steviecoaster/PSSysadminToolkit/blob/Dev/LICENSE"
        Tag = "Sysadmin Administration", "Toolkit"

    }
 
    Publish-Module @PublishOptions 