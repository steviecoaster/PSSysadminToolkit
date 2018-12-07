Function Find-OutdatedModules {
    <#
        .SYNOPSIS
        Returns a list of modules that are outdated on a system
        
        .PARAMETER Computername
        String array of Computers to query

        .EXAMPLE
        Find-OutdatedModules

        .EXAMPLE
        Find-OutdatedModules -Computername pc1

        .EXAMPLE
        Import-CSV C:\temp\pclist.csv | Find-OutdatedModules
    #>
    [cmdletBinding()]
    Param(

    [Parameter(Position=0,ValueFromPipeline,ValueFromPipelineByPropertyName)]
    [string[]]
    $Computername

    )

    Begin {}

    Process {
        $Scriptblock = {

            Get-InstalledModule | 
            Select-Object Name, @{Name='Installed';Expression={$_.Version}},
            @{Name='Available';Expression={(Find-Module -Name $_.Name).Version}} |
            Where-Object {$_.Available -gt $_.Installed}

        }

        If($Computername){

            Invoke-Command -ComputerName $Computername -ScriptBlock $Scriptblock

        }

        Else {

            $Scriptblock.InvokeReturnAsIs()

        }

    }

    End {}
}