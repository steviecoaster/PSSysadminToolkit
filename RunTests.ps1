$Tests = Get-ChildItem -Path .\Test -Recurse | Where { $_.Extension -eq '.ps1'}

$Tests | ForEach-Object {

    . $_.Name
}