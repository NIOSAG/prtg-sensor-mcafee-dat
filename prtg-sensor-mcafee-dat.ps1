<#
.SYNOPSIS
Outputs a PRTG XML structure with a Pure Storage Array capacity datadfsfsdfafds

.DESCRIPTION
Provides a look at the global array capaicty metrics and at the inidividual
volumes consumption levels. If account credentials are provided it will obtain an 
API Key from the array, if an API key is provided it skips this step. It is encouraged
to provide an API key for the array so that account credentials dont need to be provided

Written for Purity REST API 1.6

.INSTRUCTIONS
1) Copy the script file into the PRTG Custom EXEXML sensor directory C:\Program Files (x86)\PRTG Network Monitor\Custom Sensors\EXEXML
        - Get-PureFA-Sensor.ps1 (PowerShell Sensor Script)
2) Copy the Lookup files into the PRTG lookup file directory C:\Program Files (x86)\PRTG Network Monitor\lookups\custom
        - prtg.standardlookups.purestorage.drivestatus.ovl (Drive status value lookup file)
        - prtg.standardlookups.purestorage.hardwarestatus.ovl (Hardware status value lookup file)
3) Restart the 'PRTG Core Server Service' windows service to load the custom lookup files
3) Create Sensor Custom EXE/ Script Advanced Sensor for each sensor you wish to monitor (refer Scope) and give it a meaniful name
4) Set Parameters for sensor
    - (ArrayAddress) Target Array management DNS name or IP address
    - (UserName) and (Password) or (APIKey) to gain access 
    - (Scope) to set which element to monitor with Sensor
   e.g. -arrayaddress '%host' -scope 'hardware' -apikey '3bdf3b60-f0c0-fa8a-83c1-b794ba8f562c'
5) For the monitoring of individual volumes a sensor is created for each volume. As such the scope option 'volumemanage' is required to maintain these
   sensors. THis then copies itself to a new sensor assigned to the holding device and updates the paramdeters accordingly. It also removes sensors of any 
   volume that has been deleted 
    - Create 'VolumeManage' sensor with the additional parameters -prtghosturl -prtguser -prtgpassword -DeviceID -SensorID


.NOTES
Author: lloydy@purestorage.com
Version: 1.10
Date: 6/9/2017

.PARAMETER ArraryAddress
DNS Name or IP Address of the FlashArray

.PARAMETER UserName
The name of the account to be used to access the array (not required if API token provided)

.PARAMETER Password
The password of the account 

.PARAMETER APIKey
An API Key generated from within the Purity console linked to the account to be used (not required if UserName and Password supplied)

.PARAMETER Scope
The scope defines the details to be monitored from the array
Supported Scope Values:

-   Capacity
-   Performance      
-   Hardware
-   Drive
-   VolumeManage (creates a sensor for each volume)
-   Volume (Sensor created dynamically)
-   HostGroup (not currently supported)

.PARAMETER Item
For monitoring of volumes and hostgroups lets the sensor have the targetted item specified

.PARAMETER SensorID
For new sensor creation for volumes and host groups a copy of the calling sensor is created. This needs to be done with the SensorID so use 
the parameter with the %sensorid which passes the sensorid through. This is required as the API does not currently support the creation of new sensors :(

.PARAMETER DeviceID
For new sensor creation this is the DeviceID of the parent device. Use the %deviceid parameter in the arguments

.PARAMETER PRTGHostURL
The URL to be used to make API calls back to the PRTG host to manage sensors eg http://prtg.domain.local, https://prtg.domain.local, https://prtg.domain.local:8443

.PARAMETER PRTGUser
Account to access PRTG API Service

.PARAMETER PRTGPassword
Password for account used to access PRTG API Service

.PARAMETER DebugDump
Will provide console prompts duering execution. Can not be enabled when running a a sensor

.EXAMPLES
Array Capacity Monitor
C:\PS>Get_PureFA-Sensor.ps1 -ArrayAddress 1.2.3.4 -Username pureuser -Password purepassword -Scope Array
Volume Sensor Manager
C:\PS>Get_PureFA-Sensor.ps1 -ArrayAddress 1.2.3.4 -Username pureuser -Password purepassword -Scope VolumeManage -deviceid 1234 -sensorid 4321 -PRTGHostURL https://prtg.domain.local -PRTGUser admin -PRTGPassword password


#>

param
(
	 [string]$hostname,
	 [string]$username,
	 [string]$password,
     [string]$authentication
)

Set-Item WSMan:\localhost\Client\TrustedHosts -Value "*" -Force
$creds = New-Object System.Management.Automation.PSCredential ($username, (ConvertTo-SecureString $password -AsPlainText -Force))

# Define Variables
$v2daturl = "http://update.nai.com/products/DatFiles/4.x/nai/"
$v2regkey = "HKLM:/Software/WOW6432Node/McAfee/AVEngine"
$v2regvalue = "AVDatVersion"
$v2datregex = '^(\d{5})xdat\.exe'

$v3daturl = "http://update.nai.com/products/datfiles/v3dat/"
$v3regkey = "HKLM:/Software/McAfee/AVSolution/DS/DS"
$v3regvalue = "dwContentMajorVersion"
$v3datregex = '^v3_(\d{4})dat\.exe'

if ($authentication -ne "CredSSP") {
    $authentication = "Default"
}

function Check-InstalledDAT($regkey, $regvalue) {
    return Invoke-Command -ComputerName $hostname -Credential $creds -Authentication $authentication -ErrorAction SilentlyContinue -ScriptBlock {
        (Get-ItemProperty $using:regkey).$using:regvalue
    }
}

function Check-OnlineDAT($daturl, $datregex) {
    try { $response = Invoke-WebRequest $daturl -UseBasicParsing} catch { $responsecode = $_.Exception.Response.StatusCode.Value__ }
    if ($responsecode) {
        Throw "Could not check newest McAfee DAT version online. Web request response code: $($responsecode)"
    } else {
        $newestdat = ($response.Links | Sort-Object {$_.href -replace '\d',''},{($_.href -replace '\D','') -as [int]} -Descending | select -First 1).HREF
        if ($newestdat -match $datregex) {
            return $Matches[1]
        } else {
            Throw "Could not find McAfee DAT version online. Please check URL manually!"
        }
    }
}


$InstalledDAT = Check-InstalledDAT -regkey $v2regkey -regvalue $v2regvalue
if ($InstalledDAT) {
    $daturl = $v2daturl
    $datregex = $v2datregex
    $datver = "Version $($InstalledDAT) (DATv2)"
} else {
    $InstalledDAT = Check-InstalledDAT -regkey $v3regkey -regvalue $v3regvalue
    if ($InstalledDAT) {
        $daturl = $v3daturl
        $datregex = $v3datregex
        $datver = "Version $($InstalledDAT) (DATv3)"
    } else {
        Throw "Could not find a McAfee DAT version in remote registry."
    }
}
$OnlineDAT = Check-OnlineDAT -daturl $daturl -datregex $datregex

# Calculate and return result
Write-Host "$([int]$OnlineDAT-[int]$InstalledDAT):$($DATver)"