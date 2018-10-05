
#Region register every OU in the domain for autocompletion in the OU parameter
Register-ArgumentCompleter -CommandName Get-ComputerFromOU -ParameterName OU -ScriptBlock {
    (Get-ADOrganizationalUnit -Filter *).DistinguishedName | ForEach-Object {
        $Text = $_
        If($Text -match '\s') {$Text = "'$Text'"}

        New-Object System.Management.Automation.CompletionResult @(
            $Text
            $_
            'ParameterValue'
            "$_"
        )
    }
}
#endregion

Function Get-ComputerFromOU{
    <#
    .SYNOPSIS
    Return a computer object from Active Directory filtered by OU
    
    .PARAMETER OU
    Dynamically generated list of OUs in an Active Directory Domain
    
    .PARAMETER Computer
    Array of computer names to search for
    
    .EXAMPLE
    Get-ComputerFromOU -OU "OU=Marketing,DC=contoso,DC=com"
    
    .EXAMPLE
    Get-ComputerFromOU -OU "OU=Marketing,DC=contoso,DC=com" -Computer JSMITH
    
    .EXAMPLE
    Get-ComputerFromOU -OU "OU=Marketing,DC=contoso,DC=com" -Computer JSMITH,TROMERO

    .EXAMPLE
    Get-ComputerFromOU -OU "OU=Marketing,DC=contoso,DC=com" -Computer @(Get-Content C:\Files\computers.txt)

    .EXAMPLE
    $Computers = Import-CSV 'C:\Files\computers.csv'
    Foreach($c in $Computers){
        Get-ComputerFromOU -OU "OU=Marketing,DC=contoso,DC=com" -Computer $_.Name
    }

    #>
    
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position = 0)]
        [Alias('OU')]
        [string]
        $OrganizationalUnit,

        [Parameter(Position = 1,ValueFromPipeline)]
        [string[]]
        $ComputerName, 
        
        [Parameter()]
        # Could use a good [ValidateSet()]
        [string[]]
        $Properties
    )
    process {
        if ($PSBoundParameters.ContainsKey('Properties')) {
            $ComputerName | 
                Get-ADComputer -SearchBase $OrganizationalUnit -Properties $Properties
        }
        else {
            Get-ADComputer -Filter * -SearchBase $OU -Properties DistinguishedName,DNSHostName,Name,SAMAccountName
        }
    }
}
