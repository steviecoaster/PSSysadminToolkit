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
        [Parameter(Mandatory,Position=0)]
        [String[]]$Computername
    )

    Begin{}

    Process{
        $Collection = New-Object System.Collections.ArrayList

        Foreach($c in $Computername){
            $obj = @{
                'Workstation' = $c
            }

            @('Ping','WMI') |
            ForEach-Object {

                Switch($_) {

                    'Ping' {
                        If(!(Test-Connection -ComputerName $c -Count 1 -Quiet))
                        { 
                            $obj.Add('Ping Result',"$c Appears Offline")
                        
                        }
                        
                        Else
                        {
                            $obj.Add('Ping Result','OK')
                        }
                        
                    }
                        
                    'WMI' {

                        If([bool](Get-WmiObject win32_operatingsystem -ComputerName $c) -eq $false)
                        {
                            $obj.Add('Remote WMI',"$c not accessible via WMI")
                        }
                        Else
                        {
                            $obj.Add('Remote WMI',"OK")
                        }
                    }

                }
            }

                $time = Get-CimInstance win32_operatingsystem -ComputerName $C
                $Uptime = $time.LocalDateTime - $time.LastBootUpTime
                $obj.Add('Last Boot Time',$Time.LastBootUpTime)
                $obj.Add('System Uptime',"$($Uptime.Days) Days $($Uptime.Hours) Hours $($Uptime.Minutes) Minutes $($Uptime.Seconds) Seconds")

                [void]$Collection.Add($obj)

        }

        $Collection | ForEach-Object { return $_ }
    }

    End{}

}