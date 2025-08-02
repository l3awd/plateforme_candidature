@echo off
echo ================================================
echo    CandidaturePlus - Démarrage Complet
echo ================================================

:: Vérifier si MySQL est démarré
echo [1/5] Vérification de MySQL...
net start | find "MySQL" >nul
if errorlevel 1 (
    echo MySQL n'est pas démarré. Démarrage...
    net start MySQL80
    timeout /t 3 >nul
)

:: Installer les dépendances backend si nécessaire
echo [2/5] Vérification des dépendances backend...
cd /d "%~dp0backend"
echo Répertoire backend: %CD%
if not exist "target\candidatureplus-0.0.1-SNAPSHOT.jar" (
    echo JAR non trouvé. Installation des dépendances Maven...
    call mvn clean install -DskipTests
    if errorlevel 1 (
        echo Erreur lors de la compilation Maven
        pause
        exit /b 1
    )
) else (
    echo ✓ JAR trouvé: target\candidatureplus-0.0.1-SNAPSHOT.jar
)

:: Démarrer le backend
echo [3/5] Démarrage du backend Spring Boot...
start "Backend CandidaturePlus" cmd /k "cd /d \"%~dp0backend\" && java -jar target\candidatureplus-0.0.1-SNAPSHOT.jar"
timeout /t 10

:: Installer les dépendances frontend si nécessaire
echo [4/5] Vérification des dépendances frontend...
cd /d "%~dp0frontend"
echo Répertoire frontend: %CD%
if not exist "node_modules" (
    echo node_modules non trouvé. Installation des dépendances npm...
    call npm install
    if errorlevel 1 (
        echo Erreur lors de l'installation npm
        pause
        exit /b 1
    )
) else (
    echo ✓ node_modules trouvé
)

:: Démarrer le frontend
echo [5/5] Démarrage du frontend React...
start "Frontend CandidaturePlus" cmd /k "cd /d \"%~dp0frontend\" && npm start"
start "Frontend CandidaturePlus" cmd /k "cd /d \"%~dp0frontend\" && npm start"

echo.
echo ================================================
echo    Démarrage terminé !
echo ================================================
echo.
echo Frontend: http://localhost:3000
echo Backend:  http://localhost:8080
echo.
echo Comptes de test:
echo - h.alami@mf.gov.ma (Gestionnaire Local)
echo - f.bennani@mf.gov.ma (Gestionnaire Local)  
echo - m.chraibi@mf.gov.ma (Gestionnaire Global)
echo - a.talbi@mf.gov.ma (Administrateur)
echo - admin@test.com (Admin Test)
echo.
echo Mot de passe: 1234 (pour tous)
echo.
echo Appuyez sur une touche pour fermer...
pause >nul

cd /d "%~dp0"
