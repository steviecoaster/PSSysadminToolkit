Function New-UniquePassword {
    <#
    .SYNOPSIS
    Generate and display a randomly generated Password.

    .PARAMETER Length
    The length of the generated Password

    .PARAMETER IncludeSymbols
    Include symbols in the randomly generated password

    .EXAMPLE
    New-UniquePassword -Length 10

    .EXAMPLE
    New-UniquePassword -Length 15 -IncludeSymbols

    .EXAMPLE
    [pscredential]::New($Username,(New-UniquePassword -Length 10 -IncludeSymbols | ConvertTo-SecureString -AsPlainText -Force))
    #>
    Param(
        [Parameter(Mandatory, Position = 0)]
        [int]
        $Length,

        [Parameter(Position = 1)]
        [switch]$IncludeSymbols
    )

    Begin {}

    Process {
        Switch ($IncludeSymbols) {
            $false {
                $Password = ( -join (48..57 + 65..90 + 97..122 | ForEach-Object {[char]$_} | Get-Random -Count $length) )
            }
            $true {
                Add-Type -AssemblyName "System.Web" -ErrorAction Stop
                $Password = [System.Web.Security.Membership]::GeneratePassword($Length, $Length / 4)
            }
        }

        return $Password
    }

    End {}

}