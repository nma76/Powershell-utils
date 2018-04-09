#
# PowerShell Script used to create new websites. Requires Eleveted PowerShell Console!
# This script: 
# - Creates a new Applicatiopn Pool with our preferred settings
#	- Creates a new website using that pool
#
# Make sure to edit these parameters before you run the script:
# - $AppPoolName Sets the name of AppPool and WebSite
# - $AppPoolIdentityName and $AppPoolIdentityPwd to set the identity
# - $SiteDirectory is the base path to the folder holding websites
#

#########################
# Import modules needed #
#########################

Import-Module WebAdministration

######################
# Set all parameters #
######################

#AppPool parameters
$AppPoolName 			= "Www.Domain.Com"	            #Name of ApplicationPool, Should be the same as the name of the website (Eg. Soot.Msb.Se)!
$AppPoolDotNetVersion 	= "v4.0"						#.NET version for pool
$UseAppPoolIdentity     = 0                             #Set to 1 to user app-pool identity instead of domain account
$AppPoolIdentityName 	= "DOMAIN\Username"			#Identity to execute pool
$AppPoolIdentityPwd 	= "MySecurePassword"			#Identity password
$AppPoolRecycleTime		= "02:00"						#Default time is 02:00, on load balanced environments, set first host to 02:00 and second to 03:00

#WebSite parameters
$SiteName 				= $AppPoolName					#WebSite name, by default the same as name of pool
$SiteDirectory 			= "C:\WebSite\Sites\"	#Base folder, where the site should be created. Site folder is created automatically

###########################
# Create application pool #
###########################

#Create Pool and store it in $AppPool
New-WebAppPool –Name $AppPoolName
$AppPool = Get-Item IIS:\AppPools\$($AppPoolName) 

#Stop AppPool
$AppPool | Stop-WebAppPool 

#Set additional properties
#Set AppPool Identity and password
if($UseAppPoolIdentity -eq 0)
{
    $AppPool.ProcessModel.identityType = 3
    $AppPool.ProcessModel.Username = $AppPoolIdentityName 
    $AppPool.ProcessModel.Password = $AppPoolIdentityPwd
}

#Set idle time-out to zero
$AppPool.ProcessModel.IdleTimeout = "0"

#Set desired .NET version
$AppPool.ManagedRuntimeVersion = $AppPoolDotNetVersion

#Set periodic recycle schedule
Set-ItemProperty -Path IIS:\AppPools\$($AppPoolName) -Name Recycling.periodicRestart.schedule -Value @{value=$AppPoolRecycleTime}

#Save and start AppPool
$AppPool | Set-Item
$AppPool | Start-WebAppPool

#Clear periodic restart time (defaults to 1740 minutes)
Set-ItemProperty -Path IIS:\AppPools\$($AppPoolName) -Name Recycling.periodicRestart.time -Value "00:00:00"


##################
# Create website #
##################

#Create Website Directory
New-Item -ItemType directory -Path "$($SiteDirectory)$($SiteName)"

#Create Website and set default binding
New-Website -Name $SiteName -PhysicalPath "$($SiteDirectory)$($SiteName)" -ApplicationPool $AppPoolName -IPAddress "*" -Port 80 -HostHeader $AppPoolName.ToLower()

#Get the newly created website and store it in $WebSite
$WebSite = Get-Item IIS:\Sites\$($SiteName) 

#Set additional binding based on AppPool name
$WebSitePort = (17000 + $WebSite.id)
New-WebBinding -Name $SiteName -Port $WebSitePort -HostHeader "" -IPAddress "*"

#Start Website
$WebSite | Start-WebSite
