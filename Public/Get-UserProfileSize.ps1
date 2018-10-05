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
            $FolderList = if ($IncludeSpecial) {
                Get-CimInstance -ClassName 'win32_userprofile' -ComputerName $Computer |
                    Select-Object -ExpandProperty Localpath
            }
            else {
                Get-CimInstance -ClassName 'win32_userprofile' -ComputerName $Computer -Filter "Special = 'False'" |
                    Select-Object -ExpandProperty Localpath
            }

            $List = [System.Collections.Generic.List[pscustomobject]]::new()

            foreach ($Folder in $FolderList) {
                $Profile = $Folder.Split("\")[-1]

                $FileSizeScript = {
                    param($Folder)

                    Get-ChildItem -Path $Folder -Recurse -Force -ErrorAction SilentlyContinue |
                        Measure-Object -Property Length -Sum
                }

                $Size = if ($Computer -ne '.') {
                    Invoke-Command -ComputerName $Computer -ScriptBlock $FileSizeScript -ArgumentList $Folder
                }
                else {
                    $FileSizeScript.InvokeReturnAsIs($Folder)
                }

                $Object = [pscustomobject]@{
                    Name   = $Profile
                    SizeMB = [Math]::Round(($Size.Sum / 1MB), 2)
                    SizeGB = [Math]::Round(($Size.Sum / 1GB), 2)
                }

                $List.Add($Object)
            }

            $List
        }
    }

    end {}

}