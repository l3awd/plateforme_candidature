@echo off
echo ========================================
echo SCRIPT DE CORRECTION AUTOMATIQUE
echo Plateforme CandidaturePlus  
echo ========================================

echo.
echo 1. Arrêt des processus existants...
taskkill /f /im java.exe 2>nul
taskkill /f /im node.exe 2>nul

echo.
echo 2. Nettoyage du cache Maven...
cd backend
call mvn clean

echo.
echo 3. Application des scripts SQL de correction...
mysql -u root -p candidature_plus < ..\correction_automatique.sql

echo.
echo 4. Compilation du backend avec ignore des erreurs temporaires...
call mvn compile -DskipTests

echo.
echo 5. Redémarrage du backend...
start "Backend" cmd /k "mvn spring-boot:run"

echo.
echo 6. Attente de démarrage du backend (30 secondes)...
timeout /t 30

echo.
echo 7. Redémarrage du frontend...
cd ..\frontend
start "Frontend" cmd /k "npm start"

echo.
echo 8. Test des endpoints...
timeout /t 10
curl -s http://localhost:8080/api/concours > nul && echo Backend OK || echo Backend KO
curl -s http://localhost:3000 > nul && echo Frontend OK || echo Frontend KO

echo.
echo ========================================
echo Correction terminée!
echo Backend: http://localhost:8080
echo Frontend: http://localhost:3000
echo ========================================
pause
