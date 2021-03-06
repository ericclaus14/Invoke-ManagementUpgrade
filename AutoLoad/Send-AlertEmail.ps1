function Send-AlertEmail{
    <#
    .SYNOPSIS
        Send an email (a wrapper for Send-MailMessage).

    .NOTES
        Author: Eric Claus, Sys Admin, North American Division of the Seventh-day Adventist Church, ericclaus@nadadventist.org
        Last Modified: 9/29/2020
        Thanks to https://www.pdq.com/blog/powershell-send-mailmessage-gmail/ for much of the code below.
    #>
    
    Param(
        [Parameter(Mandatory=$true)]
            [string]$FunctionName,
    
        [string]$DestinationEmail 
    )

    Write-Output $_
    Write-Output $MyInvocation

    # Send an email to the help desk and to the product owner with the error
    # Thanks to https://www.pdq.com/blog/powershell-send-mailmessage-gmail/ for the bulk of the code below. 
    $From = "PowerShell-Alerts@nadadventist.org"
    $To = $DestinationEmail
    $Subject = "$FunctionName Error"
    $Body = "There has been an error with $FunctionName. -- $_"
    $SMTPServer = "10.4.11.25"
    $SMTPPort = "25"
    Send-MailMessage -From $From -to $To -Subject $Subject -Body $Body -SmtpServer $SMTPServer -port $SMTPPort

    Stop-Transcript
}