Function Get-ADUserProperties {

    [cmdletBinding()]
    param (
    [Parameter(mandatory = $True, ValueFromPipeline = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$Username,
    [Parameter(Mandatory,Position=0,ParameterSetName='Logging')]
    [switch]$Log,
    [Parameter(Mandatory=$false,Position=1,ParameterSetName='Logging')]
    [ValidateNotNullOrEmpty()]
    [String]$LogFileName
    )

    #Log file location ex:
    #$Logfilename = 'c:\reports\temp' + $Username + ($TimeStamp = Get-Date -Format '_yyyy_MM_dd_HH-mm-ss') + '.txt'
    Begin{}

    Processing {

        Try {

        $User = Get-ADUser $Username -Properties * -ErrorAction Stop

        }

        Catch {

            Write-Warning "User not found. Full Error:"
            Write-Error $_.Exception.Message

        }


        $managerDetails = Get-ADUser $user.manager -Properties displayName 
        #$managerDetails = Get-ADUser (Get-ADUser $Username -properties manager).manager -properties displayName
        $uprop2 = Get-ADPrincipalGroupMembership -Identity $User | Get-ADGroup -Properties * | select name, description

        $UserProperties = [pscustomobject][ordered]@{
                    "Name" = $uprop1.name
                    "User ID" = $uprop1.samaccountname
                    "Email Address" = $uprop1.emailaddress
                    "Title" = $uprop1.title
                    "Description" = $uprop1.Description
                    "Department" = $uprop1.Department
                    "Manager" = $managerDetails.Name
                    "Office Phone" = $uprop1.officephone
                    "Mobile" = $uprop1.mobile
                    "Account Created" = $uprop1.Created
                    "Password Last Changed" = $uprop1.PasswordLastSet
                    "AD Group Information" = $uprop2
                    # End of $prop1
                }

        Switch($PSCmdlet.ParameterSetName){
            'Logging' {

                 $File = $LogFileName + $User + ((Get-Date).ToLongDateString()) + '.txt'

                $UserProperties | Out-File $File

            }

        }

    }


    End{

        Write-Information "Processing has completed"

    }
            <#$4userinfo += $prop1 | FT -AutoSize | Out-String
            $4userinfo += $uprop2 | FT -AutoSize | Out-String
            $4userinfo |  Out-File -FilePath $Logfilename
            Write-host "Completed"
            #>

}