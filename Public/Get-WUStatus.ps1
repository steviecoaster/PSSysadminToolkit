Function Get-WUStatus {
    [cmdletBinding()]
    Param(
        [Parameter(Mandatory,Position=0,ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [string[]]
        $Computername
    )

    Begin {}

    Process {
             
        Invoke-Command -ComputerName $Computername -ArgumentList $PSBoundParameters -ScriptBlock {
        Param(
            $BoundParameters
        )
        $BoundParameters.GetEnumerator() | ForEach-Object { New-Variable -Name $_.Key -Value $_.Value}
       
        $Session = New-Object -ComObject Microsoft.Update.Session
        $Searcher = $Session.CreateUpdateSearcher()
        $Results = $Searcher.Search("IsInstalled=0 and IsHidden=0")
        $ResultCount = $Results.Updates.Count

        Switch ([bool](Get-Item "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired" -ErrorAction Ignore)) {
            $true { $PendingReboot = $true }
            $false { $PendingReboot = $false }
        }
        
        $PatchDate = Get-WMIObject -ComputerName $Computername win32_quickfixengineering |
        Select-Object @{Name="InstalledOn";E={$_.InstalledOn -as [datetime]}}|
        Sort-Object -Property InstalledOn|
        Select-Object -Property InstalledOn -Last 1

        $PatchDate = Get-Date $PatchDate.InstalledOn -Format yyyy-MM-dd
        $UpdateObject = [pscustomobject]@{
            'NeededUpdates' = $ResultCount
            'NeedsReboot' = $PendingReboot
            'LastPatched' = $PatchDate
        }

        return $UpdateObject
    }

    }    

}