@echo off
echo ========================================
echo    LANCEMENT DE CANDIDATURE PLUS
echo ========================================
echo.

echo Verification des prerequisites...

REM Verification de Java
java -version >nul 2>&1
if %errorlevel% neq 0 (
    echo ERREUR: Java non trouve! Veuillez installer Java 17 ou superieur.
    pause
    exit /b 1
)

REM Verification de Node.js
node --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ERREUR: Node.js non trouve! Veuillez installer Node.js.
    pause
    exit /b 1
)

REM Verification de npm
npm --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ERREUR: npm non trouve! Veuillez installer npm.
    pause
    exit /b 1
)

REM Verification de Maven
mvn --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ERREUR: Maven non trouve! Veuillez installer Apache Maven.
    pause
    exit /b 1
)

echo Prerequisites OK!
echo.

echo ========================================
echo   COMPILATION DU BACKEND SPRING BOOT
echo ========================================
echo.

cd backend
echo Compilation du backend...
call mvn clean package -DskipTests
if %errorlevel% neq 0 (
    echo ERREUR: Echec de la compilation du backend!
    pause
    exit /b 1
)

echo.
echo ========================================
echo   INSTALLATION DES DEPENDANCES FRONTEND
echo ========================================
echo.

cd ..\frontend
if not exist node_modules (
    echo Installation des dependances npm...
    call npm install
    if %errorlevel% neq 0 (
        echo ERREUR: Echec de l'installation des dependances frontend!
        pause
        exit /b 1
    )
) else (
    echo Dependances npm deja installees.
)

echo.
echo ========================================
echo   DEMARRAGE DES APPLICATIONS
echo ========================================
echo.

echo BACKEND: http://localhost:8080
echo FRONTEND: http://localhost:3000
echo.
echo Identifiants de connexion:
echo - Nom d'utilisateur: admin
echo - Mot de passe: 1234
echo.
echo Appuyez sur Ctrl+C dans cette fenetre pour arreter les deux applications.
echo.

REM Demarrage du backend en arriere-plan
cd ..\backend
echo Demarrage du backend Spring Boot...
start "Backend - Spring Boot" cmd /k "java -jar target/candidatureplus-0.0.1-SNAPSHOT.jar"

REM Attendre un peu pour que le backend demarre
echo Attente du demarrage du backend (15 secondes)...
timeout /t 15 /nobreak >nul

REM Demarrage du frontend en arriere-plan  
cd ..\frontend
echo Demarrage du frontend React...
start "Frontend - React" cmd /k "npm start"

echo.
echo ========================================
echo   APPLICATIONS DEMARREES AVEC SUCCES!
echo ========================================
echo.
echo Backend Spring Boot: http://localhost:8080
echo Frontend React: http://localhost:3000
echo.
echo Le navigateur va s'ouvrir automatiquement sur l'application.
echo.
echo Pour arreter les applications:
echo 1. Fermez les fenetres "Backend - Spring Boot" et "Frontend - React"
echo 2. Ou appuyez sur Ctrl+C dans chaque fenetre
echo.

REM Attendre un peu puis ouvrir le navigateur
timeout /t 10 /nobreak >nul
start http://localhost:3000

echo Script termine. Les applications tournent en arriere-plan.
pause
