function Start-ImperialMarch {
    <#
    .SYNOPSIS
        Play the imperial march theme song (well, at least the PowerShell version).

    .NOTES
        Author: LWBM (posted on the Spiceworks Community...link in the LINK section)

    .LINK
        https://community.spiceworks.com/topic/802702-powershell-imperial-march

    #>
    start-job {
        [console]::beep(440,500)
        [console]::beep(440,500)
        [console]::beep(440,500)
        [console]::beep(349,350)
        [console]::beep(523,150)
        [console]::beep(440,500)
        [console]::beep(349,350)
        [console]::beep(523,150)
        [console]::beep(440,1000)
        [console]::beep(659,500)
        [console]::beep(659,500)
        [console]::beep(659,500)
        [console]::beep(698,350)
        [console]::beep(523,150)
        [console]::beep(415,500)
        [console]::beep(349,350)
        [console]::beep(523,150)
        [console]::beep(440,1000)
    ?}
}