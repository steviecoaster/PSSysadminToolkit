Function New-DesktopShortcut {
    <#
        .SYNOPSIS
        Creates a Desktop Shortcut in a User's profile

        .PARAMETER Target
        [String]
        The full path of the executable/file to which you are creating a shortcut.

        .PARAMETER ShortcutPath
        The path name of the new Shortcut. Must end in .lnk or .url

        .EXAMPLE
        New-DesktopShortcut -Target "C:\Program Files(x86)\SuperSoftware\SuperCool.exe" -ShortcutPath = "$env:Public\Desktop\SuperCool.lnk"
    
    #>
    [cmdletBinding()]
    Param(
        
        [Parameter(Mandatory, Position = 0)]
        [String]$Target,
        [parameter(Mandatory, Position = 1)]
        [String]$ShortcutPath,
        [Parameter(Mandatory = $False , Position = 2)]
        [String]$IconPath
        
    )

    $Shell = New-Object -ComObject Wscript.Shell
    $DesktopShortcut = $Shell.CreateShortcut($ShortcutPath)
    $DesktopShortcut.TargetPath = $Target
    $DesktopShortcut.WorkingDirectory = Split-Path -Path $Target
    
    If ($IconPath) {
        
        $DesktopShortcut.IconLocation($IconPath, 0)    
    
    }

    $DesktopShortcut.Save()

}
