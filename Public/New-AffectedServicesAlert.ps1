function New-AffectedServicesAlert {
    <#
    .SYNOPSIS
    Generate an email alert when a service outage is planned

    .DESCRIPTION
    Send an email to stakeholders of services when a planned service outage is scheduled

    .PARAMETER AffectedServer
    The service that will be undergoing service

    .PARAMETER Reason
    The reason for the outage

    .PARAMETER OutageLength
    The amount of time the service will be offline

    .PARAMETER Stakeholders
    An array of email addresses to send alert too

    .EXAMPLE
    New-AffectedServicesAlert -AffectedService 'Intranet Site' -Reason 'Restore from backup' -OutageLength '5 minutes' -Stakeholders 'employees@company.com
    #>
    [cmdletBinding()]
    Param(
        [Parameter(Mandatory,Position=0)]
        [string]
        $AffectedService,

        [Parameter(Mandatory,Position=1)]
        [string]
        $Reason,

        [Parameter(Mandatory,Position=2)]
        [string]
        $OutageLength,

        [Parameter(Mandatory,Position=3)]
        [string[]]
        $Stakeholders
    )

    Begin {}

    Process {
    $content = @"
    <!DOCTYPE html>
    <html>
    <head>
    <style>
    table {
        border-collapse: collapse;
        width: 100%;
    }

    tr {
        border-bottom: 1px solid #ccc;
    }

    th {
        text-align: left;
        bgcolor: #FF0000
    }
    </style>
    <title>Pending Service interruption for $AffectedService</title>
    </head>

    <body>
        <table>
            <tr>
                <th>Affected Server</th>
                <th>Reason</th>
                <th>Expected Downtime</th>
            </tr>
            <tr>
                <td>$AffectedService</td>
                <td>$Reason</td>
                <td>$OutageLength</td>
            </tr>
        </table>
    </body>

    </html>
"@

    $mailParams = @{
        'SmtpServer' = 'smtp.server.fqdn' #edit this value
        'Subject' = "Affected Services Alert"
        'From' = "servicealert@company.com" #edit this value
        'To' = $Stakeholders
        'Body' = $content
        'BodyAsHtml' = $true

    }

    Send-MailMessage @mailParams

    }

    End {}
}