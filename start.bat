@echo off
REM ========================================
REM CANDIDATURE PLUS - DETECTEUR D'ENVIRONNEMENT
REM ========================================

echo Demarrage de CandidaturePlus...
echo.

REM Tester si nous sommes dans PowerShell ou CMD
echo %PSModulePath% >nul 2>&1
if errorlevel 1 (
    echo Detection: Invite de commandes classique
    call launch_simple.bat
) else (
    echo Detection: PowerShell - Lancement du script PowerShell
    powershell -ExecutionPolicy Bypass -File "launch_simple.ps1"
)
