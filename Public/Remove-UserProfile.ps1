#Requires -RunAsAdministrator
Function Remove-UserProfile{
   <#
        .SYNOPSIS
            Removes specified user profile from a local or remote machine using Invoke-Command

        .PARAMETER
            Profile
            The profile you wish to remove from the workstation
        
        .PARAMETER
            Computername
            The remote computer(s) you wish to remove profiles from

        .EXAMPLE
            Remove-UserProfile -Profile demouser1
        
        .EXAMPLE
            Remove-UserProfile -Profile demouser1,demouser2
        
        .EXAMPLE
            Remove-UserProfile -Computername wrkstn01 -Profile demouser1

        .EXAMPLE
            Remove-UserProfile -Computername wrkstn01,wrkstn02 -Profile demouser1
   #>
   [cmdletBinding()]
    Param(
        [parameter(Mandatory,Position=0)]
        [Alias('Username','SAMAccountName')]
        [string]
        $Profile,

        [parameter(Mandatory=$false,Position=1)]
        [array]
        $Computername
        )
    
    Begin {}

    Process {
        #Work with a remote machine.
        If($Computername)
        {
            Foreach($computer in $Computername)
                {
                    Try
                        {
                            Foreach($p in $Profile)
                                {
                                    Get-CimInstance -Computername $Computer win32_userprofile | 
                                    Select-Object SID,LocalPath |                           
                                    Where-Object { $_.localpath -match "$p" } -ErrorAction Stop |
                                    Remove-CimInstance -ErrorAction Stop
                                
                                }#end foreach
                        }#end try
                    
                    Catch
                        {
                            return $_.Exception.Message
                        
                        }#end catch
                }#end foreach
        }#end if
        
        #Working with the local machine.
        Else
            {
            foreach($p in $Profile){
                Try{
                    Get-CimInstance win32_userprofile |
                    Select-Object SID,LocalPath |
                    Where-Object { $_.localpath -match "$p" } |
                    Remove-CimInstance
                }
                
                Catch{
                
                    return $_.Exception.Message
                
                }

            }
        
        }
    
    }

    End {}

}