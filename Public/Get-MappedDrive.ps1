function Get-MappedDrive {
    <#
    .SYNOPSIS
    Collected mapped drives for logged on users

    .PARAMETER Computername
    The computer you wish to collect data from

    .EXAMPLE
    Get-MappedDrive -Computername RECEPTION-PC

    .EXAMPLE
    (Get-ADComputer -Filter * -Searchbase "OU=Sales,DC=contoso,DC=com").Name | Foreach-Object { Get-MappedDrive $_ }
    #>
    [CmdletBinding()]
    [Alias('Get-MappedDrives')]
    param(
        [Parameter(Position = 0, Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Alias('PSComputerName')]
        [ValidateNotNullOrEmpty()]
        [string[]]
        $ComputerName,

        [Parameter(Position = 1, ValueFromPipelineByPropertyName)]
        [Alias('Name')]
        [string[]]
        $DriveName
    )
    begin {}
    process {
        $ComputerName | ForEach-Object {
            if (Test-Connection -ComputerName $_ -Count 1 -Quiet) {
                #Get remote explorer session to identify current user
                $Explorer = Get-WmiObject -ComputerName $_ -Class 'Win32_Process' |
                    Where-Object Name -eq 'explorer.exe'

                #If a session was returned check HKEY_USERS for Network drives under their SID
                if ($Explorer) {
                    $Hive = 2147483651L
                    $SID = $Explorer.GetOwnerSid().SID
                    $Owner = $Explorer.GetOwner()

                    $RegistryProvider = Get-WmiObject -List -Namespace "root\default" -ComputerName $_ |
                        Where-Object Name -eq "StdRegProv"
                    $DriveList = $RegistryProvider.EnumKey($Hive, "$SID\Network")

                    #If the SID network has mapped drives iterate and report on said drives
                    if ($DriveList.sNames.Count -gt 0) {
                        $MappedDrivesToQuery = if ($DriveName) {
                            $DriveList.sNames.ToUpper() | Where-Object {$_ -in $DriveName}
                        }
                        else {
                            $DriveList.sNames.ToUpper()
                        }

                        foreach ($Drive in $MappedDrivesToQuery) {
                            $MappedDrivePath = $RegistryProvider.GetStringValue($Hive, "$($SID)\Network\$($Drive)", "RemotePath").sValue

                            [PSCustomObject]@{
                                'DriveOwner'  = "{0}\{1}" -f $Owner.Domain, $Owner.User
                                'DriveLetter' = "${Drive}:\"
                                'RootPath'    = $MappedDrivePath
                            }
                        }
                    }
                }
                else {
                    $ErrorRecord = [System.Management.Automation.ErrorRecord]::new(
                        [System.UnauthorizedAccessException]::new('Unable to find a logged on user on target machine'),
                        'NoUserFound',
                        [System.Management.Automation.ErrorCategory]::ObjectNotFound,
                        $_
                    )

                    $PSCmdlet.WriteError($ErrorRecord)
                }
            }
            else {
                $ErrorRecord = [System.Management.Automation.ErrorRecord]::new(
                    [System.TimeoutException]::new('Unable to establish connection to target machine'),
                    'ConnectionTimedOut',
                    [System.Management.Automation.ErrorCategory]::ConnectionError,
                    $_
                )

                $PSCmdlet.WriteError($ErrorRecord)
            }
        }
    }
    end {}
}