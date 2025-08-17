@echo off
echo ================================================================
echo        RÉORGANISATION DES SCRIPTS - CANDIDATURE PLUS
echo ================================================================
echo.

echo 🗂️  Création de la structure organisée...

:: Création des dossiers
if not exist "QUOTIDIEN" mkdir "QUOTIDIEN"
if not exist "BASE_DONNEES" mkdir "BASE_DONNEES"
if not exist "MAINTENANCE" mkdir "MAINTENANCE"
if not exist "DOCUMENTATION" mkdir "DOCUMENTATION"

echo ✅ Dossiers créés

:: Déplacement vers QUOTIDIEN
if exist "start_app.bat" move "start_app.bat" "QUOTIDIEN\"
if exist "stop_app.bat" move "stop_app.bat" "QUOTIDIEN\"
if exist "check_system.bat" move "check_system.bat" "QUOTIDIEN\"

echo ✅ Scripts quotidiens déplacés

:: Déplacement vers BASE_DONNEES
if exist "init_database.sql" move "init_database.sql" "BASE_DONNEES\"
if exist "insert_test_data.sql" move "insert_test_data.sql" "BASE_DONNEES\"
if exist "clean_test_data.sql" move "clean_test_data.sql" "BASE_DONNEES\"
if exist "update_db.sql" move "update_db.sql" "BASE_DONNEES\"

echo ✅ Scripts base de données déplacés

:: Déplacement vers MAINTENANCE
if exist "apply_changes.bat" move "apply_changes.bat" "MAINTENANCE\"
if exist "diagnostic_app.ps1" move "diagnostic_app.ps1" "MAINTENANCE\"

echo ✅ Scripts maintenance déplacés

:: Déplacement vers DOCUMENTATION
if exist "README.md" move "README.md" "DOCUMENTATION\"
if exist "SCRIPTS_GUIDE.md" move "SCRIPTS_GUIDE.md" "DOCUMENTATION\"
if exist "GUIDE_SCRIPTS_ORGANISE.md" move "GUIDE_SCRIPTS_ORGANISE.md" "DOCUMENTATION\"
if exist "CHANGEMENTS_BASE_DONNEES.md" move "CHANGEMENTS_BASE_DONNEES.md" "DOCUMENTATION\"
if exist "MODIFICATIONS_README.md" move "MODIFICATIONS_README.md" "DOCUMENTATION\"
if exist "NOUVELLES_FONCTIONNALITES.md" move "NOUVELLES_FONCTIONNALITES.md" "DOCUMENTATION\"
if exist "SCRIPTS.md" move "SCRIPTS.md" "DOCUMENTATION\"

echo ✅ Documentation déplacée

echo.
echo 📁 Structure finale créée :
echo   📁 QUOTIDIEN/          - Scripts usage quotidien
echo   📁 BASE_DONNEES/       - Scripts base de données
echo   📁 MAINTENANCE/        - Scripts maintenance
echo   📁 DOCUMENTATION/      - Guides et documentation
echo.

:: Création d'un script de lancement rapide dans le dossier racine
echo @echo off > quick_start.bat
echo echo 🚀 Démarrage rapide Candidature Plus >> quick_start.bat
echo call QUOTIDIEN\start_app.bat >> quick_start.bat

echo @echo off > quick_stop.bat
echo echo 🛑 Arrêt rapide Candidature Plus >> quick_stop.bat
echo call QUOTIDIEN\stop_app.bat >> quick_stop.bat

echo ✅ Scripts de démarrage rapide créés

echo.
echo ================================================================
echo               RÉORGANISATION TERMINÉE !
echo ================================================================
echo.
echo 🎯 Utilisez maintenant :
echo   • quick_start.bat     - Démarrage rapide
echo   • quick_stop.bat      - Arrêt rapide
echo   • QUOTIDIEN\          - Scripts quotidiens
echo   • MAINTENANCE\        - Scripts maintenance
echo.
pause
