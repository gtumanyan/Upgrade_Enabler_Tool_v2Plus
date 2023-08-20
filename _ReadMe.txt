# Bypass ESU Blue v2

* A project to install Extended Security Updates for:  
Windows 8.1 and Server 2012 R2  
Windows 8 and Server 2012

* It consist of one function:

- suppress ESU eligibility check for OS updates (including all .NET Framework updates)

______________________________

## Important Notes:

* Make sure that "Windows Management Instrumentation (winmgmt)" service is not disabled

* You can acquire and download the updates manually from Microsoft Update Catalog  
https://www.catalog.update.microsoft.com

to track the updates KB numbers, either check the official Update History page  
https://support.microsoft.com/help/4009470  
https://support.microsoft.com/help/4009471

or follow this MDL thread  
https://forums.mydigitallife.net/threads/47590/

* ESU updates for each month will require (at least) the latest SSU from previous month(s)  

* Unless you integrate the ESU Suppressor, ESU updates are not supported offline (you cannot integrate them), they must be installed online on live system.

* Extract the 7z pack contents to a folder with simple path, example C:\files\BypassESU

* Temporarily turn off Antivirus protection (if any), or exclude the extracted folder

______________________________

## How to Use - Live OS Installation

* Install the recommended updates (reboot if required)

* right-click on LiveOS-Setup.cmd and "Run as administrator"  

* from the menu, press the corresponding number for the desired option

* Remarks:

ESU Suppressor cannot be uninstalled after installing ESU updates, and option [5] is not shown in that case

______________________________

## How to Use - Offline Image/Wim Integration

* Wim-Integration.cmd support two target types to integrate BypassESU:

[1] Direct WIM file (not mounted), either install.wim or boot.wim

[2] Already Mounted image directory, or offline image deployed on another partition/drive/vhd

___
** Direct WIM file integration **

- place install.wim or boot.wim (one of them, not both) next to Wim-Integration.cmd, then run the script as administrator

- alternatively, run the script as administrator, and when prompted, enter the full path for the wim file

- choose the desired option from the menu (similar to live setup)

- Notes about this method:  

it will also integrate the Suppressor for winre.wim, if it exists inside install.wim  

it does not provide options to remove the Suppressor, for that, mount the wim image then use second method

___
** Mounted directory / offline image integration **

- manually mount the image of install.wim or boot.wim  
no need for this step if the image is already deployed on another partition/drive/vhd, example Z:\

- No need to integrate the recommended updates, you can integrate BypassESU first

- right-click on Wim-Integration.cmd and "Run as administrator"

- enter the correct path for mounted directory or offline image drive letter

- choose the desired option from the menu (similar to live setup)

- afterwards, continue to integrate the updates, including ESU updates

- manually unmount install.wim/boot.wim image and commit changes

______________________________

## Credits

* Gamers-Against-Weed (superUser, haveSxS)
