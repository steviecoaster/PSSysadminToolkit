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
    [CmdletBinding(DefaultParameterSetName = 'ProcessName')]
    param(
        [Parameter(Position = 0, Mandatory, ParameterSetName = 'ProcessName', ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [Alias('Name')]
        [string[]]
        $ProcessName,

        [Parameter(Position = 1, Mandatory, ParameterSetName = 'ProcessID', ValueFromPipeline)]
        [ValidateNotNull()]
        [ValidateRange(0, [int]::MaxValue)]
        [int[]]
        $ProcessID
    )
    begin {}
    process {
        switch ($PSCmdlet.ParameterSetName)
        {
            'ProcessName' {
                $ProcessName |
                    Get-Process -Name {$_} |
                    Select-Object -Property Handle, Handles, HandleCount, Name, Id
            }
            'ProcessID' {
                $ProcessID |
                    Get-Process -Id {$_} |
                    Select-Object -Property Handle, Handles, HandleCount, Name, Id
            }
        }
    }
    end {}
}