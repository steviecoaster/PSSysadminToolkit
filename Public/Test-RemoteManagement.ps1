function Test-RemoteManagement {
    <#
    .SYNOPSIS
    Test various aspects of remote computer connectivity

    .DESCRIPTION
    This function can test connectivity to a remote endpoint via Ping, WSMan, and WMI

    .PARAMETER Computername
    An array of computers you wish to test

    .PARAMETER Ping
    Switch to test Ping connectivity

    .PARAMETER WSMan
    Switch to test WSMan connectivity used in PSRemoting

    .PARAMETER WMI
    Switch to test WMI connectivity

    .EXAMPLE
    Test-RemoteManagement -Computername PC1 -Ping

    .EXAMPLE
    Test-RemoteManagement -Computername PC1 -Ping -WMI

    .EXAMPLE
    Test-RemoteManagement -Computername @((Get-ADComputer -Filter * -Searchbase "OU=PC,DC=test,DC=ad").Name) -Ping

    #>
    [cmdletBinding()]
    Param(
        [Parameter(Mandatory,Position=0,ValueFromPipeline)]
        [Alias('Name','Target')]
        [string[]]
        $Computername,
        
        [Parameter(Position=1)]
        [Switch]
        $Ping,
        
        # Neither Position nor Mandatory really do anything useful with switches
        [Parameter()] 
        [Switch]
        $WSMan,
        
        [Parameter()]
        [Switch]
        $WMI
    )
    # Process needed for pipeline
    process {
        foreach ($Computer in $ComputerName){
        # We can build as hashtable completely first, avoiding slow Add-Member calls
            $Object = @{
                'Computername' = $Computer
            }
            
            # This is weird, but better than a stack of ifs!
            switch ($true) {
                {$Ping} {
                    $PingParams = @{
                        'Computername' = $Computer
                        'Count' = 3
                        'Quiet' = $true
                    }
                    # Best to avoid properties with spaces in the name, they can be annoying
                    $Object.Add('PingResponse',(Test-Connection @PingParams))
                }
                {$WMI} {
                    $WmiParams = @{
                        'ComputerName' = $Computer
                        'ClassName' = 'Win32_Bios'
                    }
                    $Object.Add('WmiAvailable',[bool](Get-WmiObject @WmiParams))
                }
                {$WSMan} {
                    $Object.Add('WSManAvailable', [bool](Test-WSMan -ComputerName $Computer))
                }
            }
            # Adding to a list is bad if youre just outputting it to pipeline!
            # The quicker the next cmdlet in line gets the next object, the quicker the pipeline can be!
            [PSCustomObject] $Object
        }
    }
}


