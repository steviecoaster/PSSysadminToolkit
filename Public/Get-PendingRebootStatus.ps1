function Get-PendingRebootStatus {

    [cmdletBinding()]
    Param(
        [ValidateSet('WindowsUpdate', 'CBS', 'Session Manager', 'SCCM', 'All')]
        [Parameter(Mandatory = $False, Position = 0)]
        [string[]]
        $Location = "All",

        [Parameter(Mandatory = $False, Position = 1, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Alias('Name')]
        [string[]]
        $Computername = $env:ComputerName
    )

    Begin {}

    Process {
        
        Invoke-Command -ComputerName $Computername -ArgumentList $Location -HideComputerName -ScriptBlock { 
            $PendingUpdates = @{'ComputerName' = $env:COMPUTERNAME }
            
            Switch ($args[0]) {
                {$_ -match "WindowsUpdate|All"} {

                    Switch ([bool](Get-Item "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired" -ErrorAction SilentlyContinue)) {
                        $true { $PendingUpdates.Add('WindowsUpdatePending', $true)}
                        $false { $PendingUpdates.Add('WindowsUpddatePending', $false)}
                    }

                }

                {$_ -match "CBS|All"} {

                    Switch ([bool](Get-ChildItem "HKLM:\Software\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending" -ErrorAction SilentlyContinue)) {
                        $true {$PendingUpdates.Add('CBSPending', $true)}
                        $false {$PendingUpdates.Add('CBSPending', $false)}
                    }

                }

                {$_ -match "Session Manager|All"} {

                    Switch ([bool](Get-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager" -Name PendingFileRenameOperations -ErrorAction SilentlyContinue)) {
                        $true {$PendingUpdates.Add('SessionManager', $true)}
                        $false {$PendingUpdates.Add('SessionManager', $false)}
                    }

                }
                {$_ -match "SCCM|All"} {

                    try {
                        Switch (([wmiclass]"\\.\root\ccm\clientsdk:CCM_ClientUtilities").DetermineIfRebootPending().RebootPending) {
                            'True' {$PendingUpdates.Add('SCCMPending', $true)}
                            'False' {$PendingUpdates.Add('SCCMPending', $false)}
                        }
                    }
                    catch {
                        $PendingUpdates.Add('SCCMPending', $false)
                    }

                }

            }

            [pscustomobject]$PendingUpdates
        }

    }

    End {}

}