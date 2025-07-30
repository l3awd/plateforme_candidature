@echo off
REM ========================================
REM   REDEMARRAGE RAPIDE - CANDIDATURE PLUS
REM ========================================

echo Redemarrage rapide de l'application...
echo.

REM Sauvegarder le repertoire actuel
set "ORIGINAL_DIR=%CD%"

REM Arreter les processus existants
echo Arret des processus existants...
taskkill /F /IM java.exe >nul 2>&1
taskkill /F /IM node.exe >nul 2>&1
timeout /t 3 >nul

REM Verifier que le JAR existe
if not exist "backend\target\candidatureplus-0.0.1-SNAPSHOT.jar" (
    echo ERREUR: Le fichier JAR n'existe pas. Construction du projet...
    cd /d "%ORIGINAL_DIR%\backend"
    mvn clean package -DskipTests
    if %errorlevel% neq 0 (
        echo ERREUR: Echec de la construction du projet!
        cd /d "%ORIGINAL_DIR%"
        pause
        exit /b 1
    )
    cd /d "%ORIGINAL_DIR%"
)

REM Demarrage du backend
echo Demarrage du backend...
cd /d "%ORIGINAL_DIR%\backend"
start "Backend - Spring Boot" cmd /k "java -jar target/candidatureplus-0.0.1-SNAPSHOT.jar"

REM Attendre que le backend demarre
echo Attente du demarrage du backend (15 secondes)...
timeout /t 15 /nobreak >nul

REM Demarrage du frontend
echo Demarrage du frontend...
cd /d "%ORIGINAL_DIR%\frontend"

REM Verifier que node_modules existe
if not exist "node_modules" (
    echo Installation des dependances npm...
    npm install
)

start "Frontend - React" cmd /k "set BROWSER=none && npm start"

echo.
echo ========================================
echo   APPLICATION REDEMARREE AVEC SUCCES!
echo ========================================
echo Backend: http://localhost:8080
echo Frontend: http://localhost:3000 (ou port automatique)
echo.
echo Attente de 5 secondes avant ouverture du navigateur...
timeout /t 5 /nobreak >nul

REM Tenter d'ouvrir le navigateur
echo Ouverture du navigateur...
start http://localhost:3000

REM Retour au repertoire original
cd /d "%ORIGINAL_DIR%"

echo.
echo Appuyez sur une touche pour fermer cette fenetre...
pause >nul
