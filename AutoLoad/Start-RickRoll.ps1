function Start-RickRoll {
    <#
    .SYNOPSIS
        Rick Roll in PowerShell

    .LINK
        https://www.nextofwindows.com/powershell-fun-watch-rick-astley-sing-and-dance-never-let-you-down
    #>

    iex (New-Object Net.WebClient).DownloadString("http://bit.ly/e0Mw9w")
}