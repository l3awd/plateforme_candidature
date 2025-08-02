@echo off
echo ===============================================
echo    APPLICATION DES CHANGEMENTS - CandidaturePlus
echo ===============================================
echo.

echo Ce script applique tous les changements necessaires apres:
echo - Modifications du code backend/frontend
echo - Ajout de nouvelles fonctionnalites
echo.
echo IMPORTANT: Assurez-vous d'avoir execute manuellement:
echo   mysql -u root --password=1234 candidature_plus ^< update_db.sql
echo.

echo [1/3] Arret de l'application...
call stop_app.bat

echo.
echo [2/3] Redemarrage de l'application...
call start_app.bat

echo.
echo [3/3] Test des fonctionnalites...
timeout /t 15 >nul
powershell -ExecutionPolicy Bypass -File diagnostic_app.ps1

echo.
echo ===============================================
echo    CHANGEMENTS APPLIQUES AVEC SUCCES !
echo ===============================================
echo.
echo L'application a ete mise a jour et redemarree.
echo Tous les changements ont ete appliques.
echo.
pause
