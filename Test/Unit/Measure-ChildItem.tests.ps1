. $psscriptroot\..\..\Public\Measure-ChildItem.ps1

Describe Measure-ChildItem {
    BeforeAll {
        Push-Location TestDrive:\

        $basePath = (Get-Item TestDrive:\).FullName
    }

    AfterAll {
        Pop-Location
    }

    Context 'Short paths' {
        BeforeAll {
            New-Item 1\1\1\1 -ItemType Directory -Force
            New-Item 2\2\2\2 -ItemType Directory -Force
            New-Item 3\3\3\3 -ItemType Directory -Force
            New-Item 4\4\4\4 -ItemType Directory -Force

            $byte = [Byte[]]::new(43MB)
            [System.IO.File]::WriteAllBytes(
                (Join-Path $basePath '1\1\1.bin'),
                $byte
            )

            $byte = [Byte[]]::new(102MB)
            [System.IO.File]::WriteAllBytes(
                (Join-Path $basePath '2\2.bin'),
                $byte
            )

            $byte = [Byte[]]::new(1MB)
            [System.IO.File]::WriteAllBytes(
                (Join-Path $basePath '3\3\3.bin'),
                $byte
            )

            $byte = [Byte[]]::new(354MB)
            [System.IO.File]::WriteAllBytes(
                (Join-Path $basePath '4\4\4\4\4.bin'),
                $byte
            )
        }

        It 'When no parameters are supplied, measures the size and item counts for the current directory' {
            $sizeInfo = Measure-ChildItem

            $sizeInfo.DirectoryCount | Should -Be 16
            $sizeInfo.FileCount | Should -Be 4
            $sizeInfo.Size | Should -Be (500MB)
        }

        It 'When ValueOnly is set, returns the size value only' {
            Measure-ChildItem -Path 4 -ValueOnly | Should -Be 354MB
        }

        It 'When a Unit is defined, converts the size value' {
            (Measure-ChildItem -Path . -Unit MB).Size | Should -Be 500
        }

        It 'When pipelined from Get-ChildItem, counts children' {
            $sizeInfo = Get-ChildItem | Measure-ChildItem

            $sizeInfo.Count | Should -Be 4
            $sizeInfo[0].Size | Should -Be 43MB
            $sizeInfo[1].Size | Should -Be 102MB
            $sizeInfo[2].Size | Should -Be 1MB
            $sizeInfo[3].Size | Should -Be 354MB
        }
    }

    Context 'Long paths' {
        BeforeAll {
            $byte = [Byte[]]::new(1MB)
            [System.IO.File]::WriteAllBytes(
                (Join-Path $basePath '5.bin'),
                $byte
            )

            $longName = '5' * 261
            robocopy 5.bin "5\$longName.bin"
            Remove-Item 5.bin
        }

        It 'When the path length exceeds 260 characters, correctly returns the size' {
            $sizeInfo = Measure-ChildItem -Path "5\$longName.bin"

            $sizeInfo.Path.Length | Should -BeGreaterThan 260
            $sizeInfo.Size | Should -Be 0
        }
    }
}