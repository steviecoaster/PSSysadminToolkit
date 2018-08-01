Function Get-UserLogonEvent {
    <#
    .SYNOPSIS
    Gather logon information from Security Logs

    .DESCRIPTION
    Parse Windows Security Logs for Logon Events for specified user, in the specified timeframe

    .PARAMETER User
    The username to search for

    .PARAMETER Hours
    How many hours backwards in the log to search. This gets converted to milliseconds

    .PARAMETER Computername
    The computer you wish to search. Defaults to $env:COMPUTERNAME. Requires RPC to be available

    .EXAMPLE
    Get-UserLogonEvents -User jsmith -Hours 3

    .EXAMPLE
    Get-UserLogonEvents -User jsmith -Hours 3 -Computername RECEPTIONPC

    #>
    [cmdletBinding()]
    Param(
        [Parameter(Mandatory, Position = 0)]
        [string]
        $User,

        [Parameter(Mandatory, Position = 1)]
        [Int]
        $Hours,

        [Parameter(Position = 2, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [string]
        $Computername = $env:COMPUTERNAME
    )

    Process {

        #Covert Hours to milliseconds, used by FilterXML Query
        $ms = ($Hours * 3600000)
        [xml]$Filterxml = @"

<QueryList>
<Query Id="0" Path="Security">
<Select Path="Security">*[System[EventID='4624' and TimeCreated[timediff(@SystemTime) &lt; = $ms]] and EventData/Data[@Name='TargetUserName'] = '$User']</Select>
</Query>
</QueryList>
"@


        Get-WinEvent -FilterXml $Filterxml -ComputerName $Computername | ForEach-Object {

            $UserLogonInformation = @{'ComputerName' = $Computername}
            $UserLogonInformation.Add('Username', $User)

            Switch (($_).Properties.Value[8]) {

                '2' {$UserLogonInformation.Add('LogonType', 'Interactive -- Physical')}
                '3' {$UserLogonInformation.Add('LogonType', 'Network -- File/Print')}
                '4' {$UserLogonInformation.Add('LogonType', 'Batch')}
                '5' {$UserLogonInformation.Add('LogonType', 'Service -- Startup')}
                '7' {$UserLogonInformation.Add('LogonType', 'Unlock')}
                '8' {$UserLogonInformation.Add('LogonType', 'NetworkClearText -- IIS Basic Auth')}
                '9' {$UserLogonInformation.Add('LogonType', 'NewCredentials')}
                '10' {$UserLogonInformation.Add('LogonType', 'RemoveInteractive -- RDS')}
                '11' {$UserLogonInformation.Add('LogonType', 'CachedInteractive -- Use cached creds')}

            }

            $UserLogonInformation.Add('EventCreated', $_.TimeCreated)

            return [pscustomobject]$UserLogonInformation

        }

    }

}