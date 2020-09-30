New-Item -Path C:\Downloads -ItemType directory
wget "http://aka.ms/WACDownload" -outfile "C:\Downloads\WindowsAdminCenterCurrent.msi"
Cd C:\Downloads
msiexec /i WindowsAdminCenterCurrent.msi /qn /L*v log.txt SME_PORT=443 SSL_CERTIFICATE_OPTION=generate

# Wait some time for the install to finish and then check the install log file to make sure it has installed successfully.
# If so, the "Installation success or error status" should be "0". Run the following command to check the install status:
#Get-Content C:\Downloads\log.txt -Tail 20