# Upgrade_Enabler_Tool_v2Plus

This tool is a fork of [Enthousiast's tool](https://forums.mydigitallife.net/threads/upgradematrix-xml-fix-tool-very-beta.88518).

To modify the install.wim(esd) launch ModifyESD.cmd from the drive that contains `sources` folder.

## Missing recovery components

To upgrade from a trimmed-down Windows build with recovery missing run [addRecovery](https://github.com/gtumanyan/Upgrade_Enabler_Tool_v2Plus/blob/master/addRecovery.cmd)

You can supply a compatible Windows Recovery Environment (WinRE) image:
- extracted from an existing Windows installation;
- extracted from a Windows installation image;
- customized with additional drivers or tools.

A minimal recovery stub is also included. It should not be treated as equivalent to a fully functional WinRE image.

## To downgrade from a higher build you need to patch setupcompat.dll by chaging MOV eax, 1 to MOV eax, 0 in function ConX::Setup::Common::CWindowsVersion::IsLaterThan

Enjoy the unrestricted upgrades!

Crappy Tools by Enthousiast @ MDL modded by WindR
