function Set-ServerBaseConfig {
    <#
    .SYNOPSIS
        Configure basic Windows Server settings.

    .DESCRIPTION
         Activate Windows with AVMA, set the hostname, set the timezone, and optionally enable RDP. 

    .NOTES
        Author: Eric Claus, SysAdmin, North American Division of SDA, ericclaus@nadadventist.org
        Last Modified: 9/30/20
    #>

    # This is here so that default parameters, such as -Verbose, can be recognized by this script
    [CmdletBinding()]
    
    Param(
        [ValidateSet("Server 2019", "Server 2016")]
            [string]$OS = "Server 2019",

        [string]$HostName,

        [switch]$EnableRDP,

        [Parameter(Mandatory=$True)]
        [ValidateSet("Eastern Standard Time", "Central Standard Time", "Mountain Standard Time", "Pacific Standard Time", "Atlantic Standard Time", "West Pacific Standard Time")]
            [string]$TimeZone,

        [string]$AlertEmail = "help@nadadventist.org"
    )

    ########## Begin Error Handling ##########
    # If a terminating error occurs, invoke the Send-AlertEmail function and stop the script
    trap {Send-AlertEmail -FunctionName "Server Config" -DestinationEmail $AlertEmail; Exit 1}
    # Treat all errors as terminating, useful for the trap statement above
    $ErrorActionPreference = "Stop"
    ########## End Error Handling ##########

    # Activate Windows 
    switch ($OS) {
        "Server 2019 Datacenter" {$key = "H3RNG-8C32Q-Q8FRX-6TDXV-WMBMW"}
        "Server 2019 Standard"   {$key = "TNK62-RXVTB-4P47B-2D623-4GF74"} 
    } 	
    slmgr -ipk $key
    slmgr /ato

    Set-TimeZone -Id $TimeZone

    if ($EnableRDP) {
        # Enable RDP (https://theitbros.com/how-to-remotely-enable-remote-desktop-using-powershell/)
        Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server'-name "fDenyTSConnections" -Value 0
        Enable-NetFirewallRule -DisplayGroup "Remote Desktop"
        Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' -name "UserAuthentication" -Value 1
    }

    Rename-Computer -NewName $HostName -Force
}