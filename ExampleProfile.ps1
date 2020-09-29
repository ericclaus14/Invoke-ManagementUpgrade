Get-ChildItem C:\Scripts\Repos\Invoke-ManagementUpgrade\AutoLoad | ForEach-Object {. $_.FullName}

# Thanks to Trevor Sullivan for this regular expression!
# https://stackoverflow.com/a/48253796
$ValidEmailAddress = '^([\w-\.]+)@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.)|(([\w-]+\.)+))([a-zA-Z]{2,4}|[0-9]{1,3})(\]?)$'

Write-Output "Custom PowerShell environment loaded.`n"
Write-Output "Hello, $($env:USERNAME), and welcome to $($env:COMPUTERNAME)!`n"

$weather = (Invoke-WebRequest "http://dataservice.accuweather.com/currentconditions/v1/locationKey=8780_PC?apikey=aZaOq2KhWRUmGDiwJAAPzaHLBcDuSjMx%20").Content | ConvertFrom-Json
Write-Output "It is currently $($weather.Temperature.Imperial.Value)$([char]176)F and $($weather.WeatherText) outside in Columbia, MD.`n"
