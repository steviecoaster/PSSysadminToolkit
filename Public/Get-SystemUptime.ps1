Function Get-SystemUptime {
    <#
        .SYNOPSIS
        Retrieve the uptime of a system

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

                $time = Get-WmiObject win32_operatingsystem -ComputerName $C
                $Uptime = $lastBoot = $time.ConvertToDateTime($time.LocalDateTime) - $time.ConvertToDateTime($time.LastBootUpTime)
                $obj.Add('Last Boot Time',$Time.ConvertToDateTime($Time.LastBootUpTime))
                $obj.Add('System Uptime',"$($Uptime.Days) Days $($Uptime.Hours) Hours $($Uptime.Minutes) Minutes $($Uptime.Seconds) Seconds")

                $Collection.Add($obj)

        }

        $Collection | ForEach-Object { return $_ }
    }

    End{}

}