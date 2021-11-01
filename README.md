# McAfee DAT Sensor for PRTG

## Created by NIOS AG, https://nios.ch

## Installation

 1. Copy the script file into the PRTG Custom EXEXML sensor directory
    "C:\Program Files (x86)\PRTG Network Monitor\Custom Sensors\EXEXML"

	 - prtg-sensor-mcafee-dat.ps1 (PowerShell Sensor Script)

 2. Create Sensor Custom EXE/ Script Advanced Sensor for each server you
    wish to monitor (refer Scope) and give it a meaningful name

 3. Set parameters for sensor

	 - (Host) Target Array management DNS name or IP address
	 - (Username) and (Password) to gain access
		 - e.g. -host %host -username %windowsuser -password "%windowspassword"

## Sensor creation


## Screenshot
![McAfee DAT PRG Sensor overview](https://github.com/NIOSAG/prtg-sensor-mcafee-dat/blob/1de031a10fae612d0625d50a88a1d39fea64c46e/prtg-sensor-mcafee-dat-overview.PNG?raw=true)

## Troubleshooting
