@echo off
setlocal
set "VISTA_DIAG_CSCRIPT=%SystemRoot%\System32\cscript.exe"
if exist "%SystemRoot%\Sysnative\cscript.exe" set "VISTA_DIAG_CSCRIPT=%SystemRoot%\Sysnative\cscript.exe"
"%VISTA_DIAG_CSCRIPT%" //nologo "%~dp0Collect-Vista.vbs" > "%~dp0Vista-install-report.txt" 2>&1
echo. >> "%~dp0Vista-install-report.txt"
echo === Service queries === >> "%~dp0Vista-install-report.txt"
sc.exe query RtlWlanuVista >> "%~dp0Vista-install-report.txt" 2>&1
sc.exe qc RtlWlanuVista >> "%~dp0Vista-install-report.txt" 2>&1
sc.exe query RtlWlanu >> "%~dp0Vista-install-report.txt" 2>&1
type "%~dp0Vista-install-report.txt"
echo.
echo Saved Vista-install-report.txt beside this script.
echo This check does not install, start, remove, or change drivers.
pause
