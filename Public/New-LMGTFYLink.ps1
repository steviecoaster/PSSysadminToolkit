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

    $iievalue = "0"

    If ($Explainer.IsPresent) {

        $iievalue = "1"

    }

    #rewrite query special characters for URL
    $query = $query.Replace("%" , "%25")
    $query = $query.Replace("@" , "%40")
    $query = $query.Replace("#" , "%23")
    $query = $query.Replace("$" , "%24")
    $query = $query.Replace("^" , "%5E")
    $query = $query.Replace("&" , "%26")
    $query = $query.Replace("+" , "%2B")
    $query = $query.Replace("=" , "%3D")
    $query = $query.Replace("<" , "%3C")
    $query = $query.Replace(">" , "%3E")
    $query = $query.Replace("," , "%2C")
    $query = $query.Replace("/" , "%2F")
    $query = $query.Replace("\" , "%5C")
    $query = $query.Replace("{" , "%7B")
    $query = $query.Replace("}" , "%7D")
    $query = $query.Replace("[" , "%5B")
    $query = $query.Replace("]" , "%5D")
    $query = $query.Replace("'" , "%27")
    $query = $query.replace("+" , "%2B")
    $query = $query.replace(" " , "+")
    $query = $query -replace (' ','+')
    $url = "http://lmgtfy.com/?iie=" + $iievalue + "&q=$query"


    Write-Output "Generated Link: $url"

    If($Clipboard){

       Set-Clipboard -Value $url

    }

}