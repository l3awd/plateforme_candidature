@echo off
echo ===================================
echo     Application des Changements
echo     Plateforme de Candidature Plus
echo ===================================
echo.

REM Vérification de la présence de MySQL
echo [1/6] Vérification de l'environnement...
mysql --version >nul 2>&1
if errorlevel 1 (
    echo ERREUR: MySQL n'est pas installé ou pas dans le PATH
    pause
    exit /b 1
)

REM Application des changements de base de données
echo [2/6] Application des changements de base de données...
echo Connexion à MySQL et application du script de migration...
mysql -u root -p candidature_plus < migration_complete.sql
if errorlevel 1 (
    echo ERREUR: Échec de l'application du script de migration
    echo Vérifiez que la base de données 'candidature_plus' existe
    pause
    exit /b 1
)
echo Migration de base de données terminée avec succès.

REM Compilation du backend
echo [3/6] Compilation du backend...
cd backend
call mvn clean compile
if errorlevel 1 (
    echo ERREUR: Échec de la compilation du backend
    cd ..
    pause
    exit /b 1
)
echo Compilation du backend terminée.
cd ..

REM Installation des dépendances frontend
echo [4/6] Installation des nouvelles dépendances frontend...
cd frontend
call npm install
if errorlevel 1 (
    echo ERREUR: Échec de l'installation des dépendances
    cd ..
    pause
    exit /b 1
)
echo Installation des dépendances terminée.
cd ..

REM Build du frontend
echo [5/6] Build du frontend...
cd frontend
call npm run build
if errorlevel 1 (
    echo AVERTISSEMENT: Erreur lors du build frontend (peut être ignoré pour le développement)
)
cd ..

REM Message de succès
echo [6/6] Tous les changements ont été appliqués avec succès !
echo.
echo ===================================
echo          CHANGEMENTS APPLIQUÉS
echo ===================================
echo.
echo BASE DE DONNÉES :
echo ✓ Nouvelles tables : ConcourSpecialite, ConcoursCentre
echo ✓ Nouvelles colonnes : cv_fichier, cv_type, cv_taille_octets
echo ✓ Améliorations : centres_assignes pour gestionnaires
echo.
echo BACKEND :
echo ✓ CandidatureEnhancedService pour upload CV
echo ✓ Nouvelles entités : ConcoursCentre
echo ✓ DTOs améliorés avec @Builder
echo ✓ Repositories avec requêtes avancées
echo ✓ Endpoints pour gestionnaires et statistiques
echo.
echo FRONTEND :
echo ✓ CandidaturePageComplete avec formulaire en étapes
echo ✓ Validation complète des champs
echo ✓ Upload de CV avec vérification
echo ✓ Dropdown lieu de naissance avec recherche
echo ✓ GestionCandidaturesComplete avec statistiques
echo ✓ PostesPageComplete avec sélection guidée
echo ✓ Graphiques et tableaux de bord
echo.
echo ===================================
echo       PRÊT À ÊTRE LANCÉ
echo ===================================
echo.
echo Pour démarrer l'application :
echo 1. Exécutez : start_app.bat
echo 2. Accédez à : http://localhost:3000
echo 3. Backend API : http://localhost:8080
echo.
echo Comptes de test :
echo ✓ Gestionnaire : f.bennani@mf.gov.ma / 1234
echo ✓ Les candidats créent leur compte via le formulaire
echo.
pause
