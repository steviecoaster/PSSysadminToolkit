function Get-PendingRebootStatus {

    [cmdletBinding()]
    Param(
        [ValidateSet('WindowsUpdate', 'CBS', 'Session Manager', 'SCCM', 'All')]
        [Parameter(Mandatory, Position = 0)]
        [string]
        $Location,

        [Parameter(Position = 1, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Alias('Name')]
        [string[]]
        $Computername = $env:COMPUTERNAME
    )

    Begin {}

    Process {
        
        Foreach($Name in $Computername){
        
            $PendingUpdates = @{'ComputerName' = $Name }
        
            Switch ($Location) {
                'WindowsUpdate' {
                    
                    Switch(Get-Item "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired" -ErrorAction Ignore){
                        $true { $PendingUpdates.Add('WindowsUpdatePending',$true)}
                        $false { $PendingUpdates.Add('WindowsUpddatePending',$false)}
                    }
                    
                }

                'CBS' {

                    Switch(Get-ChildItem "HKLM:\Software\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending" -ErrorAction Ignore){
                        $true {$PendingUpdates.Add('CBSPending',$true)}
                        $false {$PendingUpdates.Add('CBSPending',$false)}
                    }
                
                }

                'Session Manager' {
                    
                    Switch(Get-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager" -Name PendingFileRenameOperations){
                        $true {$PendingUpdates.Add('SessionManager',$true)}
                        $false {$PendingUpdates.Add('SessionManager',$false)}
                    }
                    
                }
                'SCCM' {
                    
                    Switch(([wmiclass]"\\.\root\ccm\clientsdk:CCM_ClientUtilities").DetermineIfRebootPending().RebootPending){
                        'True' {$PendingUpdates.Add('SCCMPending',$true)}
                        'False' {$PendingUpdates.Add('SCCMPending',$false)}
                    }
                    
                }

                'All' {
                    Switch(Get-Item "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired" -ErrorAction Ignore){
                        $true { $PendingUpdates.Add('WindowsUpdatePending',$true)}
                        $false { $PendingUpdates.Add('WindowsUpddatePending',$false)}
                    }

                    Switch(Get-ChildItem "HKLM:\Software\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending" -ErrorAction Ignore){
                        $true {$PendingUpdates.Add('CBSPending',$true)}
                        $false {$PendingUpdates.Add('CBSPending',$false)}
                    }

                    Switch(Get-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager" -Name PendingFileRenameOperations){
                        $true {$PendingUpdates.Add('SessionManager',$true)}
                        $false {$PendingUpdates.Add('SessionManager',$false)}
                    }

                    Switch(Get-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager" -Name PendingFileRenameOperations){
                        $true {$PendingUpdates.Add('SessionManager',$true)}
                        $false {$PendingUpdates.Add('SessionManager',$false)}
                    }

                    Switch(([wmiclass]"\\.\root\ccm\clientsdk:CCM_ClientUtilities").DetermineIfRebootPending().RebootPending){
                        'True' {$PendingUpdates.Add('SCCMPending',$true)}
                        'False' {$PendingUpdates.Add('SCCMPending',$false)}
                    }

                }

            }

            [pscustomobject]$PendingUpdates
        
        }
    
    }

    End {}

}