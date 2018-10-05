function Get-MappedDrive {
    <#
    .SYNOPSIS
    Collected mapped drives for logged on users

    .PARAMETER Computername
    The computer you wish to collect data from

    .PARAMETER CimSession
    A CimSession, or array of Cim sessions, created using New-CimSession. The CimSession parameter allows customisation of the connection method, including the protocol and any credentials.

    .PARAMETER DriveName
    By default, all mapped drives are returned. The list may be filtered using this parameter. Names should not include ":".

    .EXAMPLE
    Get-MappedDrive

    Get the drives mapped by all users on the current machine.

    .EXAMPLE
    Get-MappedDrive -Computername RECEPTION-PC

    Get the drives mapped by all users on RECEPTION-PC

    .EXAMPLE
    Get-ADComputer -Filter * -Searchbase "OU=Sales,DC=contoso,DC=com" -Properties dnsHostName | Get-MappedDrive

    Get drives mapped by all users for all computers in the Sales OU in Active Directory.
    #>

    [CmdletBinding(DefaultParameterSetName = 'ComputerName')]
    [Alias('Get-MappedDrives')]
    param(
        [Parameter(Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'ComputerName')]
        [Alias('PSComputerName', 'DnsHostName')]
        [ValidateNotNullOrEmpty()]
        [string[]]
        $ComputerName = $env:COMPUTERNAME,

        [Parameter(Mandatory, ParameterSetName = 'CimSession')]
        [CimSession[]]$CimSession,

        [Parameter(Position = 1, ValueFromPipelineByPropertyName)]
        [string[]]
        $DriveName
    )

    begin {
        $ErrorActionPreference = 'Stop'
        [UInt32]$HKEY_USERS = 2147483651
    }

    process {
        if ($PSCmdlet.ParameterSetName -eq 'ComputerName') {
            $computers = $ComputerName
        }
        else {
            $computers = $CimSession
        }

        $getParams = @{
            ClassName   = 'Win32_Process'
            Filter      = 'Name="explorer.exe"'
            Property    = 'Name'
        }
        foreach ($computer in $computers) {
            $connectionParams = @{
                $PSCmdlet.ParameterSetName = $computer
            }

            try {
                $explorer = Get-CimInstance @getParams @connectionParams

                if ($explorer) {
                    $sid = ($explorer | Invoke-CimMethod -MethodName GetOwnerSid).Sid
                    $owner = $explorer | Invoke-CimMethod -MethodName GetOwner

                    $invokeParams = @{
                        ClassName = 'StdRegProv'
                        Namespace = 'root/default'
                    }
                    $driveList = Invoke-CimMethod @invokeParams @connectionParams -MethodName EnumKey -Arguments @{
                        hDefKey     = $HKEY_USERS
                        sSubKeyName = Join-Path $SID 'Network'
                    }
                    if ($PSBoundParameters.ContainsKey('DriveName')) {
                        $driveList.sNames = $driveList.sNames | Where-Object { $_ -in $DriveName }
                    }

                    foreach ($drive in $driveList.sNames) {
                        $remotePath = Invoke-CimMethod @invokeParams @connectionParams -MethodName GetStringValue -Arguments @{
                            hDefKey     = $HKEY_USERS
                            sSubKeyName = [System.IO.Path]::Combine($SID, 'Network', $drive)
                            sValueName  = 'RemotePath'
                        }
                        
                        [PSCustomObject]@{
                            DriveOwner  = '{0}\{1}' -f $Owner.Domain, $Owner.User
                            DriveLetter = '{0}:\' -f $drive.ToUpper()
                            RootPath    = $remotePath.sValue
                        }
                    }
                }
                else {
                    $errorRecord = [System.Management.Automation.ErrorRecord]::new(
                        [System.UnauthorizedAccessException]::new('Unable to find a logged on user on target machine'),
                        'NoUserFound',
                        [System.Management.Automation.ErrorCategory]::ObjectNotFound,
                        $computer
                    )

                    $PSCmdlet.WriteError($errorRecord)
                }
            }
            catch {
                $ErrorRecord = [System.Management.Automation.ErrorRecord]::new(
                    [System.TimeoutException]::new('Unable to query WMI on the target machine', $_.Exception),
                    'CimQueryFailed',
                    [System.Management.Automation.ErrorCategory]::ConnectionError,
                    $computer
                )

                $PSCmdlet.WriteError($ErrorRecord)
            }
        }
    }
}