Function Test-RemoteManagement {
    [cmdletBinding()]
    Param(
        [Parameter(Mandatory,Position=0)]
        [string[]]$Computername,
        [Parameter(Mandatory=$false,Position=1)]
        [Switch]$Ping,
        [Parameter(Mandatory=$false,Position=2)]
        [Switch]$WSMan,
        [Parameter(Mandatory=$false,Position=3)]
        [Switch]$WMI
    )

    $TestResults = New-Object 'System.Collections.Generic.List[pscustomobject]'

    Foreach($c in $Computername){

        $obj = [pscustomobject]@{

            'Computername' = $c
        }

        If($Ping){

            $pingParams = @{
            'Computername' = $c
            'Count' = 3
            'Quiet' = $true
            }

            $PingNoteParams = @{
            'InputObject' = $obj
            'MemberType' = 'NoteProperty'
            'Name' = 'Ping Passed'
            'Value' = (Test-Connection @pingParams)
            }

            Add-Member @PingNoteParams

        }

        If($WMI){

            $WMINoteParams = @{
                'InputObject' = $obj
                'MemberType' = 'NoteProperty'
                'Name' = 'WMI Passed'
                'Value' = [bool](Get-WmiObject win32_bios -ComputerName $c)

            }

            Add-Member @WMINoteParams

        }

        If($WSMan){

            $WSManNoteParams = @{
                'InputObject' = $obj
                'MemberType' = 'NoteProperty'
                'Name' = 'WSMan Passed'
                'Value' = [bool](Test-WSMan -ComputerName $c)

            }

            Add-Member @WSManNoteParams
        }

        $TestResults.Add($obj)
    }

    return $TestResults
}

$TestResults
