@echo off
rem DUGco AlphaGenSAM - removes the plug-in from the shared OFX folder.
rem Your API key (Documents\DUGco\comfy_cloud_api_key.txt) is left alone; delete it yourself if you want.
setlocal
set "DEST=%COMMONPROGRAMFILES%\OFX\Plugins"
tasklist /fi "imagename eq Fusion.exe" 2>nul | find /i "Fusion" >nul && (
    echo Please close Fusion first, then run this again.
    pause
    exit /b 1
)
if exist "%DEST%\AlphaGenSAM.ofx.bundle" rmdir /s /q "%DEST%\AlphaGenSAM.ofx.bundle"
if exist "%DEST%\AlphaGenSAM.ofx.bundle" (
    echo Removal failed. Run uninstall.bat as administrator.
    pause
    exit /b 1
)
echo DUGco AlphaGenSAM removed from the shared OFX folder. Restart Fusion.
pause
