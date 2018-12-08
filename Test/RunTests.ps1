$Tests = Get-ChildItem -Path . -Recurse | Where { $_.Extension -eq '.ps1'}

$Tests | ForEach-Object {

    . $_.Name
}