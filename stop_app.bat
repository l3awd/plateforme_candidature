
@echo off
echo ========================================
echo    ARRET DE CANDIDATURE PLUS
echo ========================================
echo.

echo Recherche et arret des processus...

REM Arret des fenetres de commande specifiques
echo Arret des fenetres Backend et Frontend...
taskkill /F /FI "WINDOWTITLE eq Backend CandidaturePlus*" >nul 2>&1
taskkill /F /FI "WINDOWTITLE eq Frontend CandidaturePlus*" >nul 2>&1

REM Arret de Spring Boot (Java) - port 8080
echo Arret du backend Spring Boot (port 8080)...
for /f "tokens=5" %%a in ('netstat -aon ^| findstr ":8080"') do (
    taskkill /F /PID %%a >nul 2>&1
)

REM Arret de React (Node.js) - port 3000  
echo Arret du frontend React (port 3000)...
for /f "tokens=5" %%a in ('netstat -aon ^| findstr ":3000"') do (
    taskkill /F /PID %%a >nul 2>&1
)

REM Arret general des processus Java et Node
echo Arret des processus Java et Node.js restants...
taskkill /F /IM java.exe /FI "COMMANDLINE eq *candidatureplus*" >nul 2>&1
taskkill /F /IM node.exe /FI "COMMANDLINE eq *react-scripts*" >nul 2>&1

REM Verification
timeout /t 2 >nul
echo.
echo Verification des ports:
netstat -an | findstr ":8080.*LISTENING" >nul 2>&1
if errorlevel 1 (
    echo ✓ Port 8080 (backend) libere
) else (
    echo ⚠ Port 8080 encore occupe
)

netstat -an | findstr ":3000.*LISTENING" >nul 2>&1
if errorlevel 1 (
    echo ✓ Port 3000 (frontend) libere  
) else (
    echo ⚠ Port 3000 encore occupe
)

echo.
echo ========================================
echo    ARRET TERMINE
echo ========================================
echo.
echo Les applications CandidaturePlus ont ete arretees.
echo Vous pouvez maintenant relancer start_app.bat si necessaire.
echo.
pause
taskkill /f /im npm.cmd >nul 2>&1

REM Nettoyer les ports
echo Nettoyage des ports...
for /f "tokens=5" %%i in ('netstat -ano ^| findstr ":8080"') do taskkill /pid %%i /f >nul 2>&1
for /f "tokens=5" %%i in ('netstat -ano ^| findstr ":3000"') do taskkill /pid %%i /f >nul 2>&1

echo.
echo ========================================
echo   APPLICATIONS ARRETEES AVEC SUCCES!
echo ========================================
echo.
echo Tous les processus ont ete arretes.
echo Les ports 8080 et 3000 sont maintenant libres.
echo.

pause
