Function Remove-InstalledUpdate{

    [cmdletBinding()]
    Param(
        [Parameter(Mandatory,Position=0,ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [Alias('KBNumber')]
        [String[]]
        $KB
    )


    $session = New-Object -ComObject Microsoft.Update.Session
    $Installer = $session.CreateUpdateInstaller()
    $Searcher = $session.CreateUpdateSearcher()
    $Searcher.QueryHistory(0,$Searcher.GetTotalHistoryCount()) |
    Where-Object { $_.Title -match $KB } | 
    ForEach-Object { 
            Write-Verbose "Found update history entry $($_.Title)"
            $SearchResult = $Searcher.Search("UpdateID='$($_.UpdateIdentity.UpdateID)' and RevisionNumber=$($_.UpdateIdentity.RevisionNumber)")
            Write-Verbose "Found $($SearchResult.Updates.Count) update entries"
            if($SearchResult.Updates.Count -gt 0) {
                $Installer.Updates = $SearchResult.Updates
                $Installer.Uninstall()
                $Installer | Select-Object -Property ResultCode,RebootRequired,Exception
            }
    }
}
