function Get-Handle {
    <#
        .SYNOPSIS
        Return a process object by Handles ID or Name

        .DESCRIPTION
        Query a system for running processes by either the Handles ID, or Name

        .PARAMETER Name
        String process name value

        .PARAMETER ProcessID
        Int PID value

        .EXAMPLE
        Get-Handle -Name MSASCuiL

        .EXAMPLE
        Get-Handle -ProcessID 1802

        .EXAMPLE
        Get-Handle -Name sv*

        .EXAMPLE
        Get-Handle -ProcessID 4*

        #>
    [cmdletBinding()]
    Param(
        [Parameter(Mandatory=$false,Position=0)]
        [string]
        $Name,

        [Parameter(Mandatory=$false,Position=1)]
        [string]
        $ProcessID
    )

    Begin {}

    Process {

        If($Name){

            $Process = Get-Process |
                       Where-Object { $_.Name -like $Name } |
                       Select-Object -Property Handle,Handles,HandleCount,Name,ID

            return $Process
        }

        If($ProcessID){

            $Process = Get-Process |
                       Where-Object { $_.Id -like $ProcessID }|
                       Select-Object -Property Handle,Handles,HandleCount,Name,Id

            return $Process
        }
    }

    End {}
}