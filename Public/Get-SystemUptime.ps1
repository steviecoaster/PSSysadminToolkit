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

    $UptimeObjects = New-Object System.Collections.Generic.List
    Foreach($c in $Computername){
        Try {

            Test-Connection -ComputerName $c -Quiet -Count 2 -ErrorAction Stop
        }

        Catch {

            $uptimeResult = "Ping failed, assuming computer offline!"
        }

        Try {

            Test-WSMan -ComputerName $c -ErrorAction Stop
        }

        Catch {

            $uptimeResult = "Computer online, CIM read failure. Check WSMan."
        }

        Try {
            $time = Get-WmiObject Win32_OperatingSystem -ComputerName $c -ErrorAction Stop
            $lastBoot = $time.ConvertToDateTime($time.LocalDateTime) - $time.ConvertToDateTime($time.LastBootUpTime)

        }

        Catch {

            $lastBoot = "Computer is online, but not responding to WMI"
        }

        $obj = [pscustomobject]@{

            'Server' = $c
            'System Uptime' = "$($lastBoot.Days) Days:$($lastBoot.Hours) Hours: $($lastBoot.Minutes) Minutes: $($lastBoot.Seconds) Seconds"
        }

    }
}