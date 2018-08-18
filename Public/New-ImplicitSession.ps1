Function New-ImplicitSession {
    <#
        .SYNOPSIS
        Create a new Implicit remoting session
        
        .DESCRIPTION
        Access remote modules by implicityly importing them into your current powershell session
        
        .PARAMETER Computername
        The computername which has the module you wish to use installed
        
        .PARAMETER Module
        The name of the module to import

        .PARAMETER Prefix
        If desired, you may prefix the imported module's commands with a descriptor

        .EXAMPLE
        New-ImplicitSession -Computername DC01 -Module ActiveDirectory
        
        .EXAMPLE
        New-ImplicitSession -Computername Fileserver -Module NTFSSecurity -Prefix Remote
        
        #>
    [cmdletBinding()]
    Param(
        [Parameter(Mandatory,Position=0)]
        [Alias('Name')]
        [String]
        $Computername,

        [Parameter(Mandatory,Position=1)]
        [String]
        $Module,

        [Parameter(Position=2)]
        [String]
        $Prefix
    )

    Begin {}

    Process {
        $Session = New-PSSession -ComputerName $Computername
        $SessionInfo = @{
            Target = $Computername
        }
        Invoke-Command -Session $Session -ArgumentList $Module -ScriptBlock { 
            
            Param($Param)
            Import-Module $Param 
        
        }

        If($Prefix){

            Import-PSSession -Prefix $Prefix -Session $Session -ErrorAction SilentlyContinue -WarningAction SilentlyContinue >$null
            $SessionInfo.Add('Prefix',$Prefix)

        }

        Else{

            Import-PSSession -Session $Session -ErrorAction SilentlyContinue -WarningAction SilentlyContinue >$null

        }

        $SessionInfo.Add("Id",$Session.Id)
        $SessionInfo.Add("State",$Session.State)
        $SessionInfo.Add("LoadedModule",$Module) 
        
        return [pscustomobject]$SessionInfo
    
    }

}