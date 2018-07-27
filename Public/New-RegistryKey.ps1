Function New-RegistryKey {
    <#
    .SYNOPSIS
    Creates a new registry key on a computer


    #>

    [cmdletBinding()]
    Param(
        [Parameter(Mandatory,Position=0)]
        [string]$Name,
        [Parameter(Mandatory,Position=1)]
        [string]$Value,
        [Parameter(Mandatory,Position=2)]
        #MSDN reference https://msdn.microsoft.com/en-us/library/microsoft.win32.registryvaluekind.aspx
        [ValidateSet('Binary','DWORD','ExpandString','MultiString','None','QWord','String','Unknown')]
        [String]$Type,
        [Parameter(Mandatory,Position=3)]
        [ValidateSet('HKEY_LOCALMACHINE',"HKEY_CURRENT_USER")]
        [String]$Hive
    )

    Switch($Hive){

        'HKEY_LOCALMACHINE' {}
        'HKEY_CURRENT_USER' {}
    }
}