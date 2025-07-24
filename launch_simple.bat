@echo off
echo ================================================
echo    CANDIDATURE PLUS - LANCEMENT SIMPLIFIE
echo ================================================
echo.

REM Aller dans le bon repertoire
cd /d "c:\Users\pc\Desktop\New folder (6)\plateforme_candidature"

echo [1] Verification du backend...
if not exist "backend\target\candidatureplus-0.0.1-SNAPSHOT.jar" (
    echo Backend non compile. Compilation en cours...
    cd backend
    call mvn clean package -DskipTests
    if errorlevel 1 (
        echo ERREUR: Compilation echouee
        pause
        exit /b 1
    )
    cd ..
) else (
    echo Backend deja compile.
)

echo.
echo [2] Verification du frontend...
cd frontend
if not exist node_modules (
    echo Installation des dependances npm...
    call npm install
    if errorlevel 1 (
        echo ERREUR: Installation npm echouee
        pause
        exit /b 1
    )
) else (
    echo Dependances npm deja installees.
)

echo.
echo [3] Demarrage des applications...
echo.
echo BACKEND: http://localhost:8080
echo FRONTEND: http://localhost:3000
echo CREDENTIALS: admin / 1234
echo.

REM Demarrer le backend
cd ..\backend
echo Demarrage du backend Spring Boot...
start "Backend - Spring Boot" cmd /k "cd /d \"c:\Users\pc\Desktop\New folder (6)\plateforme_candidature\backend\target\" && java -jar candidatureplus-0.0.1-SNAPSHOT.jar"

echo Attente du backend (10 secondes)...
ping 127.0.0.1 -n 11 > nul

REM Demarrer le frontend  
cd ..\frontend
echo Demarrage du frontend React...
start "Frontend - React" cmd /k "cd /d \"c:\Users\pc\Desktop\New folder (6)\plateforme_candidature\frontend\" && npm start"

echo.
echo ================================================
echo   APPLICATIONS LANCEES AVEC SUCCES!
echo ================================================
echo.
echo Ouverture du navigateur dans 10 secondes...
ping 127.0.0.1 -n 11 > nul
start http://localhost:3000

echo.
echo Les applications sont maintenant actives:
echo - Backend: http://localhost:8080
echo - Frontend: http://localhost:3000
echo.
echo Pour arreter, fermez les fenetres ou utilisez stop_application.bat
echo.
echo Verification de l'etat des services:
netstat -an | findstr "8080" >nul && echo ✓ Backend actif sur port 8080 || echo ✗ Backend inactif
netstat -an | findstr "3000" >nul && echo ✓ Frontend actif sur port 3000 || echo ✗ Frontend en cours de demarrage...

pause
