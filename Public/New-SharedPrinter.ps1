Function New-SharedPrinter {
    [cmdletBinding()]
    Param(
        [Paramter(Mandatory,Position=0)]
        [String]
        $Name,

        [Parameter(Mandatory,Position=1)]
        [ipaddress]
        $IPAddress,

        [Parameter(Position=2)]
        [String]
        $Port,

        [Parameter(Mandatory,Position=3)]
        [String]
        $ShareName

    )
    #Dynamic Params require [CmdletBinding()], but are defined on their own outside the main Param() block
    DynamicParam {
        $ParameterName = 'Driver'

        $RuntimeDict = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
        $Attribs = New-Object System.Collections.ObjectModel.Collection[System.Attribute]

        $ParameterAttributes = New-Object System.Management.Automation.ParameterAttribute
        $ParameterAttributes.Mandatory = $true
        $ParameterAttributes.Position = 0

        $Attribs.Add($ParameterAttributes)

        $Dataset = Get-PrinterDriver | Select-Object -ExpandProperty Name
        $ValidateSet = New-Object System.Management.Automation.ValidateSetAttribute($Dataset)

        $Attribs.Add($ValidateSet)

        $RuntimeParam = New-Object System.Management.Automation.RuntimeDefinedParameter($ParameterName, [string[]], $Attribs)
        $RuntimeDict.Add($ParameterName, $RuntimeParam)

        return $RuntimeDict
    }

    #Pull out the Dynamic Param from BoundParameters so you can use it
    Begin {$Driver = $PSBoundParameters[$ParameterName]}

    Process {
        #region Port
        If($Port){
            Add-PrinterPort -Name $Port -PrinterHostAddress $IPAddress -OutVariable $PortName
        }

        Else {
            Add-PrinterPort -Name $IPAddress -PrinterHostAddress $IPAddress -OutVariable $PortName
        }
        #Endregion

        Add-Printer -Name $Name -DriverName $Driver -Shared $true -ShareName $ShareName
    }

    End {}

}
