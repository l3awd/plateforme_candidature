
@echo off
echo ========================================
echo    ARRET DE CANDIDATURE PLUS
echo ========================================
echo.

echo Recherche et arret des processus...

REM Arret de Spring Boot (Java)
echo Arret du backend Spring Boot...
for /f "tokens=2" %%i in ('tasklist /fi "imagename eq java.exe" /fo csv ^| findstr "candidatureplus"') do (
    taskkill /pid %%i /f >nul 2>&1
)

REM Arret de Node.js (React)
echo Arret du frontend React...
taskkill /f /im node.exe >nul 2>&1

REM Arret des processus npm
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
