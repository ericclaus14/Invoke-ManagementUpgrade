function Invoke-WindowsUpdateByOU {
    <#
    .SYNOPSIS
        Install Windows Updates on all computers in an OU.

    .DESCRIPTION
        This script loops through all computers in a specified OU and installed Windows Updates on them.
        Standard WinRM is not needed for remote access as remote PowerShell sessions are used instead. 

    .NOTES
        Author: Eric Claus, SysAdmin, North American Division of SDA, ericclaus@nadadventist.org
        Last Modified: 9/24/20

    .COMPONENT
        RSAT, activedirectory, PSWindowsUpdate
    #>

    [CmdletBinding()]

    Param(
        [Parameter(Mandatory=$true)]
            [string]$OU,
    
        [validatescript({$_ -match $ValidEmailAddress})]
            [string]$AlertEmail
    )

    #Install-Module PSWindowsUpdate
    #Import-Module PSWindowsUpdate

    ########## Begin Error Handling ##########
    # If a terminating error occurs, invoke the Send-AlertEmail function and stop the script
    trap {Send-AlertEmail -FunctionName "Invoke-WindowsUpdateByOU" -DestinationEmail $AlertEmail; Exit 1}
    # Treat all errors as terminating, useful for the trap statement above
    $ErrorActionPreference = "Stop"
    ########## End Error Handling ##########

    Get-ADComputer -Filter * -SearchBase $OU | Select-Object Name |
        


    echo $computers

}