@echo off
REM ========================================
REM   REDEMARRAGE RAPIDE - CANDIDATURE PLUS
REM ========================================

echo Redemarrage rapide de l'application...
echo.

REM Arreter les processus existants
echo Arret des processus existants...
taskkill /F /IM java.exe >nul 2>&1
taskkill /F /IM node.exe >nul 2>&1
timeout /t 2 >nul

REM Demarrage du backend
echo Demarrage du backend...
cd backend
start "Backend - Spring Boot" cmd /k "java -jar target/candidatureplus-0.0.1-SNAPSHOT.jar"

REM Attendre 10 secondes
timeout /t 10 /nobreak >nul

REM Demarrage du frontend
echo Demarrage du frontend...
cd ..\frontend
start "Frontend - React" cmd /k "npm start"

echo.
echo Application redemarree avec succes!
echo Backend: http://localhost:8080
echo Frontend: http://localhost:3000
echo.

timeout /t 5 /nobreak >nul
start http://localhost:3000

pause
