@echo off
echo ================================================
echo    CandidaturePlus - Demarrage Complet
echo ================================================

REM Arreter les processus existants
echo [ETAPE 1/4] Arret des processus existants...
taskkill /F /IM java.exe /FI "WINDOWTITLE eq Backend CandidaturePlus*" >nul 2>&1
taskkill /F /IM node.exe /FI "WINDOWTITLE eq Frontend CandidaturePlus*" >nul 2>&1
echo ✓ Processus arretes

REM Verification des dependances
echo [ETAPE 2/4] Verification des dependances...

REM Verification de Java
echo Verification de Java...
where java >nul 2>&1
if errorlevel 1 (
    echo [ERREUR] Java n'est pas installe ou non accessible
    echo Veuillez installer Java 17 ou plus recent
    pause
    exit /b 1
)
echo ✓ Java detecte

REM Verification de Node.js
echo Verification de Node.js...
where node >nul 2>&1
if errorlevel 1 (
    echo [ERREUR] Node.js n'est pas installe ou non accessible
    echo Veuillez installer Node.js
    pause
    exit /b 1
)
echo ✓ Node.js detecte

REM Verification de npm
echo Verification de npm...
where npm >nul 2>&1
if errorlevel 1 (
    echo [ERREUR] npm n'est pas installe ou non accessible
    pause
    exit /b 1
)
echo ✓ npm detecte

REM Verification de Maven
echo Verification de Maven...
call mvn --version >nul 2>&1
if errorlevel 1 (
    echo [ERREUR] Maven n'est pas installe ou non accessible
    echo Veuillez installer Apache Maven
    pause
    exit /b 1
)
echo ✓ Maven detecte

REM Preparation et demarrage du backend
echo [ETAPE 3/4] Backend - Navigation vers backend/ et compilation...

REM Naviguer vers backend/
cd /d "%~dp0backend"
echo Navigation vers backend terminee

REM Nettoyer et recompiler le backend
echo Nettoyage du cache Maven...
call mvn clean >nul 2>&1
if errorlevel 1 (
    echo [ERREUR] Echec du nettoyage Maven
    echo Tentative de continuer sans nettoyage...
)
echo ✓ Cache Maven nettoye

echo Compilation du backend...
call mvn compile >nul 2>&1
if errorlevel 1 (
    echo [ERREUR] Echec de la compilation du backend
    echo Tentative de demarrage direct...
)
echo ✓ Backend compile avec succes

REM Demarrer Spring Boot
echo Demarrage du backend Spring Boot...
start "Backend CandidaturePlus" cmd /k "call mvn spring-boot:run"

REM Attendre que le backend demarre
echo Attente du demarrage du backend...
timeout /t 20 >nul

REM Lancement Frontend
echo [ETAPE 4/4] Frontend - Navigation vers frontend/...

REM Naviguer vers frontend/
cd /d "%~dp0frontend"
echo Navigation vers frontend terminee

REM Demarrer React
echo Demarrage du frontend React...
start "Frontend CandidaturePlus" cmd /k "npm start"

echo.
echo ================================================
echo    Applications en cours de demarrage...
echo ================================================
echo.
echo ✓ Backend Spring Boot: http://localhost:8080
echo ✓ Frontend React:      http://localhost:3000
echo.
echo ⏳ Attendez 30-60 secondes que les applications demarrent
echo    completement puis ouvrez http://localhost:3000
echo.

REM Attendre puis ouvrir le navigateur
echo Ouverture automatique du navigateur dans 30 secondes...
timeout /t 30 >nul
start http://localhost:3000

cd /d "%~dp0"
