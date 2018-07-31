Function Get-SystemUptime {
    <#
        .SYNOPSIS
        Retrieve the uptime of a system

        .DESCRIPTION
        Function which accepts an array of computer names, and returns system uptime as objects.

        .PARAMETER Computername
        Accepts an array of computer names and returns uptime and boot information

        .EXAMPLE
        Get-SystemUptime -Computername RECEPTION-PC

    #>

    [cmdletbinding()]
    Param(
        [Parameter(Mandatory,Position=0,ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [String[]]$Computername
    )
    
    Process{
        
        Foreach($name in $Computername){
            $information = [pscustomobject]@{
                Name = $name
                PingResult = Test-Connection -ComputerName $name -Count 1 -Quiet
                RemotingEnabled = [Bool](Test-WSMan -ComputerName $name -ErrorAction SilentlyContinue)
                LastBootTime = $null
                SystemUptime = $null
            }

            If($information.RemotingEnabled){

                $OperatingSystem = Get-CimInstance Win32_OperatingSystem -ComputerName $name -Property LocalDateTime,LastBootUpTime
                $information.LastBootTime = $OperatingSystem.LastBootUpTime
                $information.SystemUptime = $OperatingSystem.LocalDateTime - $OperatingSystem.LastBootUpTime
            }

            $information
        }

        
    }

    End{}

}