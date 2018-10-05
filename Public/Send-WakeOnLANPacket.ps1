Function Send-WakeOnLANPacket {
    [cmdletBinding()]
    [Alias('Wake')]
    Param(
        [Parameter()]
        [String[]]
        $MACAddress,

        [Parameter()]
        [String[]]
        $InputObject

    )

    Begin {}

    Process {

        $MACArray = $_ -split "[:-]" | ForEach-Object { [Byte]"0x$_"}
        [Byte[]]$WoLPacket = (, 0xFF * 6) + ($MACArray * 16)
        $Client = New-Object System.Net.Sockets.UDPClient
        $Client.Connect(([System.Net.IPAddress]::Broadcast), 7)
        [void]$Client.Send($WoLPacket, $WoLPacket.Length)
        $Client.Close()
        $s = [Scriptblock]::Create("Foo")
        $s.Invoke()
    }

}