Function Set-RemoteExecutionPolicy{
    [cmdletBinding()]
    Param(
        [Parameter(Mandatory,Position=0,ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [Alias(Name)]
        [String[]]
        $Computername,

        [Parameter(Mandatory,Position=1)]
        [ValidateSet('Unrestricted','RemoteSigned','AllSigned','Restricted','Bypass')]
        [String]
        $ExecutionPolicy,

        [Parameter(Position=2)]
        [scriptblock]
        $Scriptblock

    )

    Begin {}

    Process {
        $Computername | ForEach-Object {
            <#
            Registry Location Info
            ##32 bit##
            HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\PowerShell\1\ShellIds\Microsoft.PowerShell
            Key: ExecutionPolicy
            Type: String
            Values: Unrestricted | RemoteSigned | AllSigned | Restricted | Bypass

            ##64 bit##
            HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Microsoft\PowerShell\1\ShellIds\Microsoft.PowerShell
            Key: ExecutionPolicy
            Type: String
            Value: Unrestricted | RemoteSigned | AllSigned | Restricted | Bypass
            #>

            Switch ([System.Runtime.InterOpServices.Marshal]::SizeOf([System.IntPtr])){

                4 {
                    
                    $CurrentSetting = reg query HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\PowerShell\1\ShellIds\Microsoft.PowerShell
                    $CurrentSetting = $CurrentSetting[3].Split(' ')[-1]

                    $SetNewSetting = [scriptblock]::Create("reg add \\$_\HKLM\SOFTWARE\Microsoft\PowerShell\1\ShellIds\Microsoft.PowerShell /v ExecutionPolicy /t REG_SZ /d $ExecutionPolicy /f")
                    $SetNewSetting.Invoke()
                }

                8 {
                    
                    $CurrentSetting = reg query HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Microsoft\PowerShell\1\ShellIds\Microsoft.PowerShell
                    $CurrentSetting = $CurrentSetting[3].Split(' ')[-1]

                    $SetNewSetting = [scriptblock]::Create("reg add \\$_\HKLM\SOFTWARE\Microsoft\PowerShell\1\ShellIds\Microsoft.PowerShell /v ExecutionPolicy /t REG_SZ /d $ExecutionPolicy /f")
                    $SetNewSetting.Invoke()

                }
            }

            Invoke-Command -ComputerName $_ -ScriptBlock $Scriptblock

            Switch([System.Runtime.InteropServices.Marshal]::SizeOf([System.IntPtr])){
                4 {
                    
                    $RevertSetting = [scriptblock]::Create("reg add \\$_\HKLM\SOFTWARE\Microsoft\PowerShell\1\ShellIds\Microsoft.PowerShell /v ExecutionPolicy /t REG_SZ /d $CurrentSetting /f")
                    $RevertSetting.Invoke()
                
                }

                8 {
                    
                    $RevertSetting = [scriptblock]::Create("reg add \\$_\HKLM\SOFTWARE\Microsoft\PowerShell\1\ShellIds\Microsoft.PowerShell /v ExecutionPolicy /t REG_SZ /d $CurrentSetting /f")
                    $RevertSetting.Invoke()

                }
            
            }

        }

    }

    End {}
 
}