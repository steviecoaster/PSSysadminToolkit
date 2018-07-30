function Get-PendingRebootStatus {

    [cmdletBinding()]
    Param(
        [ValidateSet('WindowsUpdate', 'CBS', 'Session Manager', 'SCCM', 'All')]
        [Parameter(Mandatory, Position = 0)]
        [string]
        $Location,

        [Parameter(Position = 1, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Alias('Name')]
        [string]
        $Computername = $env:COMPUTERNAME
    )

    $PendingUpdates = @{'ComputerName' = $Computername}
    Switch ($Location) {
        'WindowsUpdate' {

            If (Get-Item "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired" -ErrorAction Ignore) {

                $PendingUpdates.Add('WindowsUpatePending', $true)
            }

            Else {
                $PendingUpdates.Add('WindowsUpdatePending', $false)
            }

        }

        'CBS' {

            If (Get-ChildItem "HKLM:\Software\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending" -ErrorAction Ignore) {
                $PendingUpdates.Add('CBSPending', $true)

            }

            Else {

                $PendingUpdates.Add('CBSPending', $false)

            }
        }

        'Session Manager' {
            If (Get-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager" -Name PendingFileRenameOperations) {

                $PendingUpdates.Add('SessionManager', $true)

            }

            Else {

                $PendingUpdates.Add('SessionManager', $false)

            }
        }
        'SCCM' {

            If (([wmiclass]"\\.\root\ccm\client\clientsdk:CCM_ClientUtilities").DetermineIfRebootPending().RebootPending -eq 'True') {

                $PendingUpdates.Add('SCCM', $true)
            }

            Else {

                $PendingUpdates.Add('SCCM', $false)

            }
        }
        'All' {
            #Windows Update
            If (Get-Item "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired" -ErrorAction Ignore) {

                $PendingUpdates.Add('WindowsUpatePending', $true)
            }

            Else {
                $PendingUpdates.Add('WindowsUpdatePending', $false)
            }

            #CBS
            If (Get-ChildItem "HKLM:\Software\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending" -ErrorAction Ignore) {
                $PendingUpdates.Add('CBSPending', $true)

            }

            Else {

                $PendingUpdates.Add('CBSPending', $false)

            }

            #Session Manager
            If (Get-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager" -Name PendingFileRenameOperations) {

                $PendingUpdates.Add('SessionManager', $true)

            }

            Else {

                $PendingUpdates.Add('SessionManager', $false)

            }

            #SCCM
            If (([wmiclass]"\\.\root\ccm\clientsdk:CCM_ClientUtilities").DetermineIfRebootPending().RebootPending -eq 'True') {

                $PendingUpdates.Add('SCCM', $true)
            }

            Else {

                $PendingUpdates.Add('SCCM', $false)

            }

        }
    }

    [pscustomobject]$PendingUpdates
}