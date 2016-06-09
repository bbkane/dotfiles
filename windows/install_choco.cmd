@echo off
goto check_Permissions

:check_Permissions
    echo Administrative permissions required. Detecting permissions...

    net session >nul 2>&1
    if %errorLevel% == 0 (
        echo Success: Administrative permissions confirmed.
	goto install
    ) else (
        echo Failure: Current permissions inadequate.
	pause
	exit
    )

    
:install

@powershell -NoProfile -ExecutionPolicy Bypass -Command "iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))" && SET PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin

choco install powershell4

@powershell Set-ExecutionPolicy RemoteSigned

:: For some reasion, the path saving isn't working...
echo "Saving Path to %HOMEPATH%\path.txt"
echo %PATH% > "%HOMEPATH%\path.txt"
mkdir %HOMEPATH%\bin
SETX PATH "%PATH%;%HOMEPATH%\bin"

color 0B
echo "Now reboot!"

PAUSE