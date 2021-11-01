<#
.SYNOPSIS
Outputs a PRTG XML structure with a McAfee DAT Version difference between the localy installed version and the version from the online repository

.DESCRIPTION
This Script gets the newest DAT-File Version online from the official McAfee Repository and checks if the installed DAT-File Version is different than the online Version
Outputs the difference between the two versions in a PRTG XML structure with predefined Error and Warning Limits

It can handle McAfee DAT v2 and v3 files

.INSTRUCTIONS
1) Copy the script file into the PRTG Custom EXEXML sensor directory C:\Program Files (x86)\PRTG Network Monitor\Custom Sensors\EXEXML
        - prtg-sensor-mcafee-dat.ps1 (PowerShell Sensor Script)
2) Create Sensor Custom EXE/ Script Advanced Sensor for each server you wish to monitor (refer Scope) and give it a meaningful name
4) Set parameters for sensor
    - (Host) Target Array management DNS name or IP address
    - (Username) and (Password) to gain access 
   e.g. -host %host -username %windowsuser -password "%windowspassword"

.NOTES
Authors: claudio.stocker@nios.ch, daniel.scarcella@nios.ch 
Website: https://nios.ch/
Version: 1.2
Date: 29.10.2021

.PARAMETER Hostname
FQDN or IP address of the server running McAfee VirusScan Enterprise and McAfee Endpoint Security

.PARAMETER UserName
The name of the account to be used to access the Server

.PARAMETER Password
The password of the account 

.EXAMPLES
McAfee DAT Version
C:\PS>prtg-sensor-mcafee-dat.ps1 -host server01 -username Administrator -password TopSecretPW

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

Write-Host "<prtg>"
    Write-Host "<result>"
    Write-Host "<channel>DAT Version</channel>"
    Write-Host "<value>$([int]$OnlineDAT-[int]$InstalledDAT):$($DATver)</value>"
    Write-Host "<LimitMaxError>2</LimitMaxError>"
    Write-Host "<LimitMinError>-2</LimitMinError>"
    Write-Host "<LimitMaxWarning>1</LimitMaxWarning>"
    Write-Host "<LimitMinWarning>-1</LimitMinWarning>"
    Write-Host "<LimitMode>1</LimitMode>"    
    Write-Host "</result>"
Write-Host "</prtg>"
exit $code 