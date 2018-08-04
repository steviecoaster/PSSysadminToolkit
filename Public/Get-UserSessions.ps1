Function Get-UsersAndLogOffComputers {

    #requires -Module ActiveDirectory
    #requires -RunAsAdministrator
    #requires -Version 3.0

    <#
    .SYNOPSIS
        This will check to see if a user is logged on to a server and if specified, log them off.
        For updated help and examples refer to -Online version.

    .DESCRIPTION
        This will check to see if a user is logged on to a server and if specified, log them off.
        For updated help and examples refer to -Online version.

    .NOTES
        Name: Get-UsersAndLogOffComputers
        Author: The Sysadmin Channel
        Version: 1.01
        DateCreated: 2017-Apr-01
        DateUpdated: 2017-Apr-09

    .LINK
        https://thesysadminchannel.com/find-users-logged-into-a-server-and-log-them-off-remotely/ -
        For updated help and examples refer to -Online version.

    #>

        [CmdletBinding()]
            param(
                [Parameter(
                    ValueFromPipeline=$true,
                    ValueFromPipelineByPropertyName=$true,
                    Position=0)]
                [string[]]
                $ComputerName = $env:COMPUTERNAME,

                [Parameter()]
                [string]
                $Username = $env:USERNAME,

                [Parameter()]
                [switch]
                $Logoff,

                [Parameter()]
                [switch]
                $LogErrors

            )

        BEGIN {
            $ErrorLogFile = "$env:USERPROFILE\Desktop\Get-UsersAndLogOffComputers.txt"
            if (Test-Path $ErrorLogFile) {Remove-Item $ErrorLogFile}
        }

        PROCESS {
            
                try {
                    If($ComputerName){
                        
                        $ExplorerProcess = Get-WmiObject Win32_Process -Filter "Name = 'explorer.exe'" -ComputerName $Computer -ErrorAction Stop

                    }
                    Else{
                       
                        $ExplorerProcess = Get-WmiObject Win32_Process -Filter "Name = 'explorer.exe'"  -ErrorAction Stop

                    }
                        
                    if ($ExplorerProcess) {
                        $ExplorerProcess = $ExplorerProcess.GetOwner().User
                        foreach ($Person in $ExplorerProcess) {
                            if ($Username -eq $Person) {
                                $Session = (query session $Username /Server:$Computer | Select-String -Pattern $Username -EA Stop).ToString().Trim()
                                $Session = $Session -replace '\s+', ' '
                                $Session = $Session -replace '>', ''

                                if ($Session.Split(' ')[2] -cne "Disc") {
                                    $Properties = @{Computer  = $Computer
                                            Username  = $Username.Replace('{}','')
                                            Session   = $Session.Split(' ')[0]
                                            SessionID = $Session.Split(' ')[2]
                                            State     = $Session.Split(' ')[3]
                                            }
                       
                                } 
                                
                                else {
                                    $Properties = @{Computer  = $Computer
                                        Username  = $Username.Replace('{}','')
                                        Session   = 'Idle'
                                        SessionID = $Session.Split(' ')[1]
                                        State     = 'Disconnected'
                                    }

                                }
                                
                                $Object = New-Object -TypeName PSObject -Property $Properties | Select-Object Computer, Username, State, Session, SessionID
                            }
                        }
                    }

                } 
                
                catch {
                
                    $ErrorMessage = $Computer + " Error: " + $_.Exception.Message

                } 
                
                finally {
                    if ($ErrorMessage -and $LogErrors) {
                            Write-Output $ErrorMessage | Out-File $ErrorLogFile -Append
                            $ErrorMessage = $null
                    }

                    if ($Logoff -and $Object.SessionID) {
                        LogOff.exe /server:$Computer $Object.SessionID
                    }

                    
                    
                }
            
            return $Object
            
        }

        END {}

    }