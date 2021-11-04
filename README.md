

# McAfee DAT Sensor for PRTG
 Created by [NIOS AG](https://nios.ch)

## Description
This Script gets the newest DAT-File Version online from the official McAfee Repository and checks if the installed DAT-File version is different than the online version. It then outputs the difference between the two versions in a PRTG XML structure with predefined error and warning limits.

It can handle McAfee DAT v2 (McAfee VirusScan Enterprise) and DAT v3 (McAfee Endpoint Security) files.

## Installation
### Sensor creation
 1. Copy the script file into the PRTG Custom EXEXML sensor directory:
    "C:\Program Files (x86)\PRTG Network Monitor\Custom Sensors\EXEXML"

	- prtg-sensor-mcafee-dat.ps1 (PowerShell Sensor Script)

 2. Select the parent device on which you want to check the version of the McAfee DAT and choose Add sensor. Select the sensor type EXE/Script Advanced in the group Custom sensors. Adjust the following settings:

	- **Name:** Enter a name that allows for easy identification of the sensor.
	- **Tags:** Add custom Tag like "McAfee"
	- **EXE/Script:** Select the corresponding script "prtg-sensor-mcafee-dat.ps1"
	- **Parameters:** Set the parameters as required. See below for further Information and an example.
	- **Security Context:** Assert that the script is run under a useraccount which can access the server
	- **Result Handling:** For easier troubleshooting, it is advisable to store the result of the sensor in the logs directory, at a minimum if errors occure.

### Parameters
    -host %host -username %windowsuser -password "%windowspassword"

### Screenshot of sensor creation
![McAfee DAT PRG Sensor creation](https://github.com/NIOSAG/prtg-sensor-mcafee-dat/blob/master/prtg-sensor-mcafee-dat-configuration.PNG?raw=true)

### Screenshot of sensor overview
![McAfee DAT PRG Sensor overview](https://github.com/NIOSAG/prtg-sensor-mcafee-dat/blob/1de031a10fae612d0625d50a88a1d39fea64c46e/prtg-sensor-mcafee-dat-overview.PNG?raw=true)

## Troubleshooting
If the sensors report errors please follow this steps to identity the cause:

- Make sure that the sensor stores the EXE result in the file system, so that you can access the error message in the folder C:\ProgramData\Paessler\PRTG Network Monitor\Logs (Sensors).
- Let the PRTG Sensor recheck the McAfee DAT Version.
- Check the LOG files.
