@echo off
rem DUGco AlphaGenSAM - installer for Blackmagic Fusion (Windows).
rem Copies the OFX plug-in to the standard shared OFX folder. Run as administrator.
setlocal
set "HERE=%~dp0"
set "DEST=%COMMONPROGRAMFILES%\OFX\Plugins"
if not exist "%HERE%AlphaGenSAM.ofx.bundle\Contents\Win64\AlphaGenSAM.ofx" if exist "%HERE%..\build\AlphaGenSAM.ofx.bundle\Contents\Win64\AlphaGenSAM.ofx" set "HERE=%HERE%..\build\"
if not exist "%HERE%AlphaGenSAM.ofx.bundle\Contents\Win64\AlphaGenSAM.ofx" (
    echo Can't find AlphaGenSAM.ofx.bundle next to this installer.
    pause
    exit /b 1
)
tasklist /fi "imagename eq Fusion.exe" 2>nul | find /i "Fusion" >nul && (
    echo Please close Fusion first, then run this again.
    pause
    exit /b 1
)
echo Installing DUGco AlphaGenSAM to %DEST% ...
if not exist "%DEST%" mkdir "%DEST%"
robocopy "%HERE%AlphaGenSAM.ofx.bundle" "%DEST%\AlphaGenSAM.ofx.bundle" /E /NJH /NJS /NFL /NDL >nul
if errorlevel 8 (
    echo Copy failed. Run install.bat as administrator.
    pause
    exit /b 1
)
echo.
echo Done. Restart Fusion and find AlphaGenSAM in the OpenFX tool list.
echo.
echo Using Comfy Local (the default): start ComfyUI and confirm the node's "local server"
echo address is http://127.0.0.1:8188. Press "Test Connection" to verify it.
echo.
pause
