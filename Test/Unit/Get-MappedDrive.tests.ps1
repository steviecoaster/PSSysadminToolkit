. $psscriptroot\..\..\Public\Get-MappedDrive.ps1

Describe Get-MappedDrive {
    BeforeAll {
        Mock Get-CimInstance {
            Get-CimClass Win32_Process | New-CimInstance -ClientOnly
        }
        Mock Invoke-CimMethod -ParameterFilter { $MethodName -eq 'GetOwnerSid' } -MockWith {
            [PSCustomObject]@{
                SID = [System.Security.Principal.SecurityIdentifier]::new(
                    [System.Security.Principal.WellKnownSidType]::BuiltinGuestsSid,
                    $null
                )
            }
        }
        Mock Invoke-CimMethod -ParameterFilter { $MethodName -eq 'GetOwner' } -MockWith {
            [PSCustomObject]@{
                User   = 'Guest'
                Domain = 'COMPUTERNAME'
            }
        }
        Mock Invoke-CimMethod -ParameterFilter { $MethodName -eq 'EnumKey' } -MockWith {
            [PSCustomObject]@{
                sNames = 'A'
            }
        }
        Mock Invoke-CimMethod -ParameterFilter { $MethodName -eq 'GetStringValue' } -MockWith {
            [PSCustomObject]@{
                sValue = '\\server\share'
            }
        }
    }

    Context 'ComputerName parameter' {
        BeforeAll {
            $computerName = @(
                'first'
                'second'
            )
        }

        It 'When an array of computer names is passed' {
            (Get-MappedDrive -ComputerName $computerName).Count | Should -Be 2
        }

        It 'When an array of names is supplied from the input pipeline' {
            ($computerName | Get-MappedDrive).Count | Should -Be 2
        }

        It 'When using ByValue parameter binding' {
            $inputObject = $computerName | ForEach-Object {
                [PSCustomObject]@{ PSComputerName = $_ }
            }

            ($inputObject | Get-MappedDrive).Count | Should -Be 2
        }
    }

    Context 'CimSession parameter' {
        It 'When an array of CimSession is passed' {
            $cimSession = @(
                New-MockObject CimSession
                New-MockObject CimSession
            )

            Get-MappedDrive -CimSession $cimSession | Should -Not -BeNullOrEmpty
        }
    }

    Context 'Process' {
        It 'When a process exists, attempts to find mapped drives in the registry' {
            Get-MappedDrive

            Assert-MockCalled Get-CimInstance
            Assert-MockCalled Invoke-CimMethod -ParameterFilter { $MethodName -eq 'GetOwnerSid' }
            Assert-MockCalled Invoke-CimMethod -ParameterFilter { $MethodName -eq 'GetOwner' }
            Assert-MockCalled Invoke-CimMethod -ParameterFilter { $MethodName -eq 'EnumKey' }
            Assert-MockCalled Invoke-CimMethod -ParameterFilter { $MethodName -eq 'GetStringValue' }
        }
    }

    Context 'Return value' {
        It 'When a drive is found, returns the name, root path, and owner' {
            $result = Get-MappedDrive

            $result.DriveOwner | Should -Be 'COMPUTERNAME\Guest'
            $result.DriveLetter | Should -Be 'A:\'
            $result.RootPath | Should -Be '\\server\share'
        }
    }

    Context 'List filtering' {
        It 'When a filter is applied, only returns matching drives' {
            Get-MappedDrive -DriveName 'A' | Should -Not -BeNullOrEmpty
            Get-MappedDrive -DriveName 'B' | Should -BeNullOrEmpty
        }
    }

    Context 'No processes' {
        BeforeAll {
            Mock Get-CimInstance
        }

        It 'When Get-CimInstance does not return a process, throws a non-terminating error' {
            { Get-MappedDrive -ErrorAction SilentlyContinue } | Should -Not -Throw
            { Get-MappedDrive -ErrorAction Stop } | Should -Throw -ErrorId NoUserFound
        }
    }

    Context 'Get-CimInstance throws' {
        BeforeAll {
            Mock Get-CimInstance {
                throw
            }
        }

        It 'When Get-CimInstance throws, throws a non-terminating error' {
            { Get-MappedDrive -ErrorAction SilentlyContinue } | Should -Not -Throw
            { Get-MappedDrive -ErrorAction Stop } | Should -Throw -ErrorId CimQueryFailed
        }
    }
}