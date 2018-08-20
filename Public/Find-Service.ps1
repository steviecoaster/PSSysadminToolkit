Function Find-Service {
    <#
        .SYNOPSIS
        Find a specified service on remote endpoints
        .PARAMETER Computername
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
    [cmdletBinding()]
    Param(
    [Parameter(Mandatory,Position=0,ValueFromPipeline,ValueFromPipeLineByPropertyName)]
    [Alias('Name')]
    [string[]]
    $ComputerName,

    [Parameter(Mandatory,Position=1)]
    [Alias('Service')]
    [string]
    $ServiceDisplayName
    )

    Process {

        $Computername | ForEach-Object {

            If(!(Test-Connection $psitem -Count 1 -Quiet)){
                $offlineError = [pscustomobject]@{
                Computername = $psitem
                TargetOffline = $true
                Message = "Ping failed to this endpoint"
                }

                Return $offlineError
            }

           

            Else {

             Try { 
                 
                Test-WSMan $psitem -ErrorAction Stop | Out-Null 
            
            }
            
            Catch { 
                
                $WSManError = [pscustomobject]@{
                Computername = $tryitem
                WSManError = $true
                Message = "Unable to remote to endpoint"
                }

                return $WSManError

            }

            Invoke-Command -ComputerName $psitem -ArgumentList $ServiceDisplayName -ScriptBlock {
                Param($Params)
                $Service = Get-Service -DisplayName $Params
                If($Service){

                    $ServiceData = [pscustomobject]@{
                    Computername = $env:COMPUTERNAME
                    Service = $Service.DisplayName
                    StartupType = $Service.StartType
                    Status = $Service.Status
                    }

                    return $ServiceData

                }#inner if

                Else {

                $ServiceData = [pscustomobject]@{
                    Computername = $env:COMPUTERNAME
                    Service = $Params
                    Error = "$Params not found on this system"
                    }

                 return $ServiceData

                }#inner else

            }#invoke

            }#outer else

        }#Foreach

    }#process

}#Function