Function New-ShortUri {
    <#
    .SYNOPSIS
    Generate tiny url from a web link

    .DESCRIPTION
    Take a long, unseemly URI from online, and turn it into a short link for distribution or social media

    .PARAMETER Uri
    The long URI you wish to shorten

    .PARAMETER RetrieveClipboardUri
    If you have a URI stored in your clipboard, use this to automatically retrieve and shorten it

    .PARAMETER CopyToClipboard
    Copy the shortened URI to your clipboard

    .PARAMETER Test
    Opens the short URI in your default web browser to verify the link works as expected

    .EXAMPLE

    New-ShortUri -Uri https://www.superlongdomainname/with/weird/page/links.htm

    .EXAMPLE

    New-ShortUri -RetrieveClipboardUri

    .EXAMPLE

    New-ShortUri -RetrieveCliboardUri

    .EXAMPLE

    New-ShortURI -Uri https://www.dumbsite.com/randomjunk/pg1/ha.htm -CopyToClipboard

    .EXAMPLE

    New-ShortURI -RetrieveClipboardUri -Test

    .EXAMPLE

    Get-Clipboard | New-ShortUri

    #>

    [cmdletBinding(HelpUri ='https://github.com/steviecoaster/PSSysadminToolkit/blob/Dev/Help/New-ShortUri.md')]
    [Alias('ShortUri')]
    Param(
        [Parameter(Position = 0, ValueFromPipeline)]
        [String]
        $Uri,

        [Parameter(Position = 1, ValueFromPipeline)]
        [Switch]
        $RetrieveClipboardURI,

        [Parameter(Position = 2)]
        [Switch]
        $CopyToClipboard,

        [Parameter(Position = 3)]
        [Switch]
        $Test

    )

    Process {

        If ($RetrieveClipboardURI) {
            Add-Type -AssemblyName System.Windows.Forms
            $Uri = [System.Windows.Forms.Clipboard]::GetData('System.String')
        }

        $ShortUri = Invoke-WebRequest -Uri "https://tinyurl.com/api-create.php?url=$Uri" | Select-Object -ExpandProperty Content

        If ($CopyToClipboard) {

            [System.Windows.Forms.Clipboard]::SetData('System.String', $ShortUri)
        }

        $UriObject = [pscustomobject]@{

            LongUri  = $Uri
            ShortUri = $ShortUri
        }

        $UriObject

        If ($TestLink) {

            [System.Diagnostics.Process]::Start("$ShortUri")
        }

    }

}

