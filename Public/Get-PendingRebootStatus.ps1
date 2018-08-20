function Get-PendingRebootStatus {

    [cmdletBinding()]
    Param(
        [ValidateSet('WindowsUpdate', 'CBS', 'Session Manager', 'SCCM', 'All')]
        [Parameter(Mandatory, Position = 0)]
        [string]
        $Location,

        [Parameter(Mandatory,Position = 1, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Alias('Name')]
        [string[]]
        $Computername
    )

    Begin {}

    Process {

        
        Invoke-Command -ComputerName $Computername -ArgumentList $PSBoundParameters -ScriptBlock{ 

            Param(
                $BoundParameters
            )
                $BoundParameters.GetEnumerator() | ForEach-Object { New-Variable -Name $_.Key -Value $_.Value }
                $Location | ForEach-Object {
                    $PendingUpdates = @{'ComputerName' = $env:COMPUTERNAME }
                    Switch ($Location) {
                        'WindowsUpdate' {

                            Switch ([bool](Get-Item "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired" -ErrorAction Ignore)) {
                                $true { $PendingUpdates.Add('WindowsUpdatePending', $true)}
                                $false { $PendingUpdates.Add('WindowsUpddatePending', $false)}
                            }

                        }

                        'CBS' {

                            Switch ([bool](Get-ChildItem "HKLM:\Software\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending" -ErrorAction Ignore)) {
                                $true {$PendingUpdates.Add('CBSPending', $true)}
                                $false {$PendingUpdates.Add('CBSPending', $false)}
                            }

                        }

                        'Session Manager' {

                            Switch ([bool](Get-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager" -Name PendingFileRenameOperations)) {
                                $true {$PendingUpdates.Add('SessionManager', $true)}
                                $false {$PendingUpdates.Add('SessionManager', $false)}
                            }

                        }
                        'SCCM' {

                            Switch (([wmiclass]"\\.\root\ccm\clientsdk:CCM_ClientUtilities").DetermineIfRebootPending().RebootPending) {
                                'True' {$PendingUpdates.Add('SCCMPending', $true)}
                                'False' {$PendingUpdates.Add('SCCMPending', $false)}
                            }

                        }

                        'All' {
                            Switch ([bool](Get-Item "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired" -ErrorAction Ignore)) {
                                $true { $PendingUpdates.Add('WindowsUpdatePending', $true)}
                                $false { $PendingUpdates.Add('WindowsUpddatePending', $false)}
                            }

                            Switch ([bool](Get-ChildItem "HKLM:\Software\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending" -ErrorAction Ignore)) {
                                $true {$PendingUpdates.Add('CBSPending', $true)}
                                $false {$PendingUpdates.Add('CBSPending', $false)}
                            }

                            Switch ([bool](Get-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager" -Name PendingFileRenameOperations)) {
                                $true {$PendingUpdates.Add('SessionManager', $true)}
                                $false {$PendingUpdates.Add('SessionManager', $false)}
                            }

                            Switch (([wmiclass]"\\.\root\ccm\clientsdk:CCM_ClientUtilities").DetermineIfRebootPending().RebootPending) {
                                'True' {$PendingUpdates.Add('SCCMPending', $true)}
                                'False' {$PendingUpdates.Add('SCCMPending', $false)}
                            }

                        }

                    }

                [pscustomobject]$PendingUpdates
            }
            
           
        }

    }

    End {}

}