function Find-PwnedAccount {
    <#
        .SYNOPSIS
        Return list of sites where an email address may have been compromised

        .PARAMETER Accounts
        String array of email addresses to search for.

        .PARAMETER Truncate
        Returns
    #>
    [cmdletBinding()]
    param(
        [Parameter(Mandatory, Position = 0)]
        [string[]]
        $Accounts,

        [Parameter(Position = 1)]
        [switch]
        $IncludeUnverified

    )

    begin {

        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

    }

    process {

        Foreach ($Account in $Accounts) {

            If ($IncludeUnverified) {

                $irmParams = @{

                    Uri    = "https://haveibeenpwned.com/api/v2/breachedaccount/$Account?includeUnverified=true"
                    Method = 'Get'

                }

                $Response = Invoke-RestMethod @irmParams
                $Response | Add-Member -MemberType NoteProperty -Name 'Account' -Value $Account
                $Response
            }

            Else {

                $irmParams = @{

                    Uri    = "https://haveibeenpwned.com/api/v2/breachedaccount/$Account"
                    Method = 'Get'

                }

                $Response = Invoke-RestMethod @irmParams
                $Response | Add-Member -MemberType NoteProperty -Name 'Account' -Value $Account
                $Response

            }

        }

    }

    end {

        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::SystemDefault

    }

}