curl.exe --remote-name https://download.microsoft.com/download/6/7/4/674ec7db-7c89-4f2b-8363-689055c2b430/adk/Installers/52be7e8e9164388a9e6c24d01f6f1625.cab
curl.exe --remote-name https://download.microsoft.com/download/6/7/4/674ec7db-7c89-4f2b-8363-689055c2b430/adk/Installers/5d984200acbde182fd99cbfbe9bad133.cab
curl.exe --remote-name https://download.microsoft.com/download/6/7/4/674ec7db-7c89-4f2b-8363-689055c2b430/adk/Installers/9d2b092478d6cca70d5ac957368c00ba.cab
curl.exe --remote-name https://download.microsoft.com/download/6/7/4/674ec7db-7c89-4f2b-8363-689055c2b430/adk/Installers/bbf55224a0290f00676ddc410f004498.cab
curl.exe https://download.microsoft.com/download/6/7/4/674ec7db-7c89-4f2b-8363-689055c2b430/adk/Installers/Oscdimg%%20(DesktopEditions)-x86_en-us.msi --output "Oscdimg (DesktopEditions)-x86_en-us.msi"

mkdir temp
msiexec.exe /a "Oscdimg (DesktopEditions)-x86_en-us.msi" /qb TARGETDIR="%CD%\temp"
copy "temp\Windows Kits\10\Assessment and Deployment Kit\Deployment Tools\amd64\Oscdimg\oscdimg.exe" "oscdimg.exe"
rmdir /s /q temp

del "Oscdimg (DesktopEditions)-x86_en-us.msi"
del bbf55224a0290f00676ddc410f004498.cab
del 9d2b092478d6cca70d5ac957368c00ba.cab
del 5d984200acbde182fd99cbfbe9bad133.cab
del 52be7e8e9164388a9e6c24d01f6f1625.cab