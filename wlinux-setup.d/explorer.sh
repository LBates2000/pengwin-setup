#!/bin/bash

source $(dirname "$0")/common.sh "$@"

execname='wlinux.exe'
echo "WSL executable name: ${execname}"
plainname='WLinux'

if (whiptail --title "EXPLORER" --yesno "Would you like to enable Windows Explorer shell integration?" 8 65); then
    echo "Enabling Windows Explorer shell integration."
    createtmp
    cat << EOF >> Install.reg
    Windows Registry Editor Version 5.00
    [HKEY_CURRENT_USER\Software\Classes\Directory\Background\shell\\${plainname}]
    @="Open with ${plainname}"
    [HKEY_CURRENT_USER\Software\Classes\Directory\Background\shell\\${plainname}\command]
    @="wsl -d ${plainname,,} -e bash -l -c \\"cd \\\\\\"\$(wslpath \\\\\\"%V\\\\\\")\\\\\\" && \$(getent passwd \$LOGNAME | cut -d: -f7)\\""
    [HKEY_CURRENT_USER\Software\Classes\Directory\shell\\${plainname}]
    @="Open with ${plainname}"
    [HKEY_CURRENT_USER\Software\Classes\Directory\shell\\${plainname}\command]
    @="wsl -d ${plainname,,} -e bash -l -c \\"cd \\\\\\"\$(wslpath \\\\\\"%V\\\\\\")\\\\\\" && \$(getent passwd \$LOGNAME | cut -d: -f7)\\""
EOF

    cp Install.reg $(wslpath "$(cmd.exe /c 'echo %TEMP%' 2>&1 | tr -d '\r')")/Install.reg
    cmd.exe /C "Reg import %TEMP%\Install.reg"
    cleantmp
else
    echo "Disabling Windows Explorer shell integration."
    createtmp
    cat << EOF >> Uninstall.reg
    Windows Registry Editor Version 5.00
    [-HKEY_CURRENT_USER\Software\Classes\Directory\Background\shell\\${plainname}]
    [-HKEY_CURRENT_USER\Software\Classes\Directory\shell\\${plainname}]
EOF
    cp Uninstall.reg $(wslpath "$(cmd.exe /c 'echo %TEMP%' 2>&1 | tr -d '\r')")/Uninstall.reg
    cmd.exe /C "Reg import %TEMP%\Uninstall.reg"
    cleantmp
fi
