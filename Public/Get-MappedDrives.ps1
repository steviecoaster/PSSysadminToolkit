function Get-MappedDrives {
    <#
    .SYNOPSIS
    Collected mapped drives for logged on users

    .PARAMETER Computername
    The computer you wish to collect data from

    .EXAMPLE
    Get-MappedDrives -Computername RECEPTION-PC

    .EXAMPLE
    (Get-ADComputer -Filter * -Searchbase "OU=Sales,DC=contoso,DC=com").Name | Foreach-Object { Get-MappedDrives }

    #>

    [cmdletBinding()]

    Param(
        [Parameter(Mandatory, Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Alias('Name')]
        [string[]]
        $Computername

    )

    Begin {}

    Process {

        $Computername | ForEach-Object {
            $DriveObject = @{ Computer = $_ }
            if (Test-Connection -ComputerName $_ -Count 1 -Quiet) {
                #Get remote explorer session to identify current user
                $explorer = Get-WmiObject -ComputerName $_ -Class win32_process | Where-Object {$_.name -eq "explorer.exe"}

                #If a session was returned check HKEY_USERS for Network drives under their SID
                if ($explorer) {
                    #$Hive = [long]$HIVE_HKU = 2147483651
                    [long]$Hive = 2147483651
                    $sid = ($explorer.GetOwnerSid()).sid
                    $owner = $explorer.GetOwner()
                    $RegProv = get-WmiObject -List -Namespace "root\default" -ComputerName $_ | Where-Object {$_.Name -eq "StdRegProv"}
                    $DriveList = $RegProv.EnumKey($Hive, "$($sid)\Network")

                    #If the SID network has mapped drives iterate and report on said drives
                    if ($DriveList.sNames.count -gt 0) {
                        $DriveObject.Add('DriveOwner', "$($owner.Domain)\$($owner.user)")
                        foreach ($drive in $DriveList.sNames) {
                            $DriveObject.Add("$($drive.ToUpper()):\", $(($RegProv.GetStringValue($Hive, "$($sid)\Network\$($drive)", "RemotePath")).sValue))

                            #"$($drive)`t$(($RegProv.GetStringValue($Hive, "$($sid)\Network\$($drive)", "RemotePath")).sValue)"
                        }
                    }
                    else { $DriveObject.Add('DriveLetter', "No Mapped Drives") }
                }
                else {$DriveObject.Add('DriveOwner', "No logged on users")}
            }
            else {$DriveObject.Add('ConnectionIssue', "Device failed to respond to Ping")}

            return [PSCustomObject]$DriveObject
        }
    }

    End {}

}