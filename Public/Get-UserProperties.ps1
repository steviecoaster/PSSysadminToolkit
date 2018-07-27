Function Get-ADUserProperties {

    [cmdletBinding()]
    param (
    [Parameter(mandatory,Position=0)]
    [ValidateNotNullOrEmpty()]
    [string]$Username,
    [Parameter(Mandatory=$false,Position=1)]
    [ValidateNotNullOrEmpty()]
    [String]$LogFilePath
    )

    Begin{}

    Process {

        Try {

        $User = Get-ADUser $Username -Properties * -ErrorAction Stop

        }

        Catch {

            Write-Warning "User not found. Full Error:"
            Write-Error $_.Exception.Message

        }


        #$managerDetails = Get-ADUser $user.manager -Properties displayName 
        #$managerDetails = Get-ADUser (Get-ADUser $Username -properties manager).manager -properties displayName
        $UserGroups = Get-ADPrincipalGroupMembership -Identity $User | Get-ADGroup -Properties * -ErrorAction SilentlyContinue| select name, description

        $UserProperties = [pscustomobject][ordered]@{
                    "Name" = $user.name
                    "User ID" = $User.samaccountname
                    "Email Address" = $User.emailaddress
                    "Title" = $User.title
                    "Description" = $User.Description
                    "Department" = $User.Department
                    #"Manager" = $managerDetails.Name
                    "Office Phone" = $User.officephone
                    "Mobile" = $User.mobile
                    "Account Created" = $User.Created
                    "Password Last Changed" = $User.PasswordLastSet
                    "AD Group Information" = $UserGroups
                    # End of $prop1
                }


        If($LogFilePath){
            $time = (Get-Date -Format yyyy-mm-dd-hh-mm-ss)
            $File = "$LogFilePath\$($User.SamAccountName)_$($time).txt"

            $UserProperties | Out-File $File

        }

        Else {

            Write-Output $UserProperties
        }

    }


    End{

        Write-Information "Processing has completed"

    }

}