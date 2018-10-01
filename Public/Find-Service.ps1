function Find-Service {
    <#
        .SYNOPSIS
        Find a specified service on remote endpoints
        .PARAMETER ComputerName
        The remote endpoint(s) to query
        .PARAMETER ServiceDisplayName
        The Display Name of the service to query
        .EXAMPLE
        Find-Service -Computername reception-pc -ServiceDisplayName 'Windows Audio'
        .EXAMPLE
        Find-Service -Name reception-pc -Service 'Windows Audio'
        .EXAMPLE
        Find-Service -Name @((Get-ADComputer -Filter * -Searchbase $ou).Name) -Service 'Windows Audio'
        .EXAMPLE
        (Get-ADComputer -Filter * -Searchbase $ou).Name | Find-Service -Service 'Windows Audio'
    #>
    [CmdletBinding()]
    param(
        [Parameter(Position = 0, Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('PSComputerName', 'PC')]
        [ValidateNotNullOrEmpty()]
        [string[]]
        $ComputerName,

        [Parameter(Mandatory, Position = 1, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Alias('Name', 'ServiceName')]
        [ValidateNotNullOrEmpty()]
        [string[]]
        $ServiceDisplayName
    )
    process {
        $ComputerName | ForEach-Object {
            if (-not (Test-Connection -ComputerName $_ -Count 1 -Quiet)) {
                Write-Error [PSCustomObject]@{
                    Computername   = $_
                    TargetOffline  = $true
                    WSManAvailable = $null
                    Service        = $null
                    Message        = 'Ping Failed'
                }

                return
            }
            else {
                try {
                    Test-WSMan -ComputerName $_ -ErrorAction Stop > $null
                }
                catch {
                    Write-Error [PSCustomObject]@{
                        Computername   = $_
                        TargetOffline  = $false
                        WSManAvailable = $false
                        Service        = $null
                        Message        = "WSMan Unresponsive"
                    }

                    return
                }

                Invoke-Command -ComputerName $_ -ArgumentList $ServiceDisplayName -ScriptBlock {
                    param($Params)

                    $Service = Get-Service -DisplayName $Params

                    if ($Service) {
                        return [PSCustomObject]@{
                            Computername = $env:COMPUTERNAME
                            Service      = $Service.DisplayName -join ', '
                            StartupType  = $Service.StartType
                            Status       = $Service.Status
                        }
                    }
                    else {
                        Write-Error [PSCustomObject]@{
                            Computername   = $env:COMPUTERNAME
                            TargetOffline  = $false
                            WSManAvailable = $true
                            Service        = $Params -join ', '
                            Message        = "$Params not found on this system"
                        }
                    }#inner else

                }#invoke

            }#outer else

        }#Foreach

    }#process

}#function