Function New-LMGTFYLink {
    <#
    .SYNOPSIS
    Generates a Let Me Google That For You url from entered query

    .PARAMETER Query
    String to be searched for

    .EXAMPLE
    New-LMGTFY -Query "Why is the sky blue?"

    .EXAMPLE 
    New-LMGTFY-Query "14th president of united states" -Clipboard
    #>

    [cmdletbinding()]
    Param(
    [Alias(lmgtfy)]
    [parameter(Mandatory,Position=0)]
    [string]$Query,
    [Parameter(Mandatory=$false,Position=1)]
    [switch]$Clipboard
    )

    If($query[-1] -eq '?'){

        $Query = $Query -replace ('\?','%3F')
    }



    $query = $query -replace (' ','+')

    $uri = "http://lmgtfy.com/?q=$query"

    Write-Output "Generated Link: $uri"

    If($Clipboard){

        $uri | Clip.exe

    }

}