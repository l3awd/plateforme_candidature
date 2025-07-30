@echo off
echo ========================================
echo  DEMARRAGE ENVIRONNEMENT DEVELOPPEMENT
echo ========================================
echo.

echo 1. Demarrage du backend Spring Boot...
start "Backend" cmd /k "cd /d \"c:\Users\pc\Desktop\New folder (6)\plateforme_candidature\backend\" && mvn spring-boot:run"

echo 2. Attente de 10 secondes pour que le backend demarre...
timeout /t 10 /nobreak > nul

echo 3. Demarrage du frontend React...
start "Frontend" cmd /k "cd /d \"c:\Users\pc\Desktop\New folder (6)\plateforme_candidature\frontend\" && set BROWSER=none && npm start"

echo.
echo Applications demarrees !
echo Backend: http://localhost:8080
echo Frontend: http://localhost:3000 (ou autre port si occupe)
echo.
echo Fermez cette fenetre quand vous avez fini de tester.
pause
