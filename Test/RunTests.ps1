$Tests = Get-ChildItem -Path . -Recurse

$Tests | ForEach-Object {

    . $_.Name
}