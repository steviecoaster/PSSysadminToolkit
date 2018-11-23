function Get-UserProfileSize {
    <#
        .SYNOPSIS
        Gather profile sizes on a computer

        .DESCRIPTION
        Returns the size of a user profile on a given computername

        .PARAMETER IncludeSpecial
        Includes built-in accounts in the object

        .PARAMETER Computername
        The remote computer to query for data

        .EXAMPLE
        Get-UserProfileSize

        .EXAMPLE
        Get-UserProfileSize -IncludeSpecial

        .EXAMPLE
        Get-UserProfileSize -Computername foobar

        .EXAMPLE
        (Get-ADComputer foobar).Name | Get-UserProfileSize

    #>
    [CmdletBinding()]
    param(
        [Parameter()]
        [switch]
        $IncludeSpecial,

        [Parameter(Position = 0,ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [Alias('Name','PSComputerName')]
        [string[]]
        $ComputerName
    )
    begin {}
    process {
        if (-not $ComputerName) {
            $ComputerName = '.'
        }
        
        foreach ($Computer in $ComputerName) {
            $FolderList = if (-not $IncludeSpecial) {
                Get-CimInstance -ClassName 'win32_userprofile' -ComputerName $Computer -Filter "Special = 'False'" |
                    Select-Object -ExpandProperty Localpath
            }
            else {
                Get-CimInstance -ClassName 'win32_userprofile' -ComputerName $Computer |
                    Select-Object -ExpandProperty Localpath
            }

            foreach ($Folder in $FolderList) {
                $FileSizeScript = {
                    param($Folder)

                    Get-ChildItem -Path $Folder -Recurse -Force -ErrorAction SilentlyContinue |
                        Measure-Object -Property Length -Sum
                }

                $Size = if ($Computer -eq '.') {
                    $FileSizeScript.InvokeReturnAsIs($Folder)
                }
                else {
                    Invoke-Command -ComputerName $Computer -ScriptBlock $FileSizeScript -ArgumentList $Folder
                }

                [pscustomobject]@{
                    Name   = $Folder | Split-Path -Leaf
                    SizeMB = [Math]::Round(($Size.Sum / 1MB), 2)
                    SizeGB = [Math]::Round(($Size.Sum / 1GB), 2)
                }
            }
        }
    }
    end {}
}
