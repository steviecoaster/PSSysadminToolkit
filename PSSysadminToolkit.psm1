$Public = Get-ChildItem -Path $PSScriptRoot\Public\*.ps1

$Public | ForEach-Object {
    . $_.FullName
}

Export-ModuleMember -Function *

