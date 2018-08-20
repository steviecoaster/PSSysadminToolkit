Function Get-WUStatus {
    [cmdletBinding()]
    Param(

    )

    Begin {}

    Process {

        $Session = New-Object -ComObject Microsoft.Update.Session
        $Searcher = $Session.CreateUpdateSearcher()
        $Results = $Searcher.Search("IsInstalled=0 and IsHidden=0")
        $ResultCount = $Results.Updates.Count

        Switch ([bool](Get-Item "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired" -ErrorAction Ignore)) {
            $true { $PendingReboot = $true }
            $false { $PendingReboot = $false }
        }

        $PatchDate = Get-WMIObject win32_quickfixengineering |
        Select-Object @{Name="InstalledOn";E={$_.InstalledOn -as [datetime]}}|
        Sort-Object -Property InstalledOn|
        Select-Object -Property InstalledOn -Last 1

        $PatchDate = Get-Date $PatchDate.InstalledOn -Format yyyy-MM-dd
        $UpdateObject = [pscustomobject]@{
            'NeededUpdates' = $ResultCount
            'NeedsReboot' = $PendingReboot
            'LastPatched' = $PatchDate
        }

        [System.runtime.interopservices.marshal]::ReleaseComObject($Session)
        return $UpdateObject
    }



}