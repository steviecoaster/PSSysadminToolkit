[cmdletBinding()]
Param(
    [Parameter(Position=0)]
    [String]
    $Key
)
    
    $PublishOptions = @{
        Name = "$PSScriptRoot\PSSysadminToolkit.psd1"
        NuGetApiKey = $Key
        LicenseUri = "https://github.com/steviecoaster/PSSysadminToolkit/blob/Dev/LICENSE"
        Tag = "Sysadmin Administration", "Toolkit"

    }
 
    Publish-Module @PublishOptions 