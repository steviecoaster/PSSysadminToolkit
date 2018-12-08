#region Quickly Get a recovery key, even remotely
Function Get-BitlockerKeyProtector {

    <#
    .SYNOPSIS
    Retrieve Key Protector Info from computers

    .PARAMETER Computer
    Remote computer to query

    .PARAMETER KeyType
    Which Protector do you want information for?

    .EXAMPLE
    Get-BitlockerKeyProtector

    .EXAMPLE
    Get-BitlockerKeyProtector -KeyType TPM
    #>

    [cmdletBinding()]
    Param(
        [Parameter(Position = 0)]
        [string[]]
        $Computername,

        [Parameter(Position = 1 )]
        [ValidateSet('TPM', 'RecoveryPassword', 'Both')]
        [String]
        $KeyType
    )

    $Scriptblock = {

        Switch ($KeyType) {

            "RecoveryPassword" {$Protectors = (Get-BitLockerVolume).KeyProtector[1]}
            "TPM" {$Protectors = (Get-BitLockerVolume).KeyProtector[0]}
            "Both" {$Protectors = (Get-BitLockerVolume).KeyProtector}
            default { $Protectors = (Get-BitLockerVolume).KeyProtector}

        }

        $Object = [pscustomobject]@{

            KeyProtectorId   = $Protectors.KeyProtectorId
            KeyProtectorType = $Protectors.KeyProtectorType
            RecoveryPassword = $Protectors.RecoveryPassword
            Status           = $Protectors.VolumeStatus
            ProtectionStatus = $Protectors.ProtectionStatus

        }

        $Object
    }

    If ($Computername) {

        Invoke-Command -ComputerName $Computername -ScriptBlock $Scriptblock
    }

    Else {

        $Scriptblock.InvokeReturnAsIs()

    }

}
#endregion