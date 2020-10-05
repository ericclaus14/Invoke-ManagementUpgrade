# Change this location as needed
Get-ChildItem C:\Scripts\AutoLoad | ForEach-Object {. $_.FullName}

Write-Output "Custom PowerShell environment loaded.`n"

# Thanks to Trevor Sullivan for this regular expression!
# https://stackoverflow.com/a/48253796
$ValidEmailAddress = '^([\w-\.]+)@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.)|(([\w-]+\.)+))([a-zA-Z]{2,4}|[0-9]{1,3})(\]?)$'

Add-Type -AssemblyName System.speech
$speak = New-Object System.Speech.Synthesis.SpeechSynthesizer

# Change the location key and api key to your own (generated on accuweather.com)
$weather = (Invoke-WebRequest "http://dataservice.accuweather.com/currentconditions/v1/locationKey=8780_PC?apikey=aZaOq2KhWRUmGDiwJAAPzaHLBcDuSjMx%20").Content | ConvertFrom-Json

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

Write-Output "Hello, $($env:USERNAME), and welcome to $($env:COMPUTERNAME)!`n"
$speak.Speak("Hello, $($env:USERNAME), and welcome to $($env:COMPUTERNAME)!`n")

Write-Output "It is currently $($weather.Temperature.Imperial.Value)$([char]176)F and $($weather.WeatherText) outside in Columbia, MD.`n"
$speak.Speak("It is currently $($weather.Temperature.Imperial.Value)$([char]176)F and $($weather.WeatherText) outside in Columbia, MD.`n")