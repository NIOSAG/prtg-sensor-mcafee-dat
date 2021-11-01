# McAfee DAT Sensor for PRTG

## Created by NIOS AG, https://nios.ch

## Installation

 1. Copy the script file into the PRTG Custom EXEXML sensor directory
    "C:\Program Files (x86)\PRTG Network Monitor\Custom Sensors\EXEXML"

	 - prtg-sensor-mcafee-dat.ps1 (PowerShell Sensor Script)

## Sensor creation


## Screenshot
![McAfee DAT PRG Sensor overview](https://github.com/NIOSAG/prtg-sensor-mcafee-dat/blob/1de031a10fae612d0625d50a88a1d39fea64c46e/prtg-sensor-mcafee-dat-overview.PNG?raw=true)

## Troubleshooting
If the sensors report errors please follow this steps to identity the cause:

- Make sure that the sensor stores the EXE result in the file system, so that you can access the error message in the folder C:\ProgramData\Paessler\PRTG Network Monitor\Logs (Sensors).
- Let the PRTG Sensor recheck the McAfee DAT Version.
- Check the LOG files.
