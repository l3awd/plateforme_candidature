@echo off
echo ========================================
echo   Insertion des donnees de test
echo   CandidaturePlus Database Setup
echo ========================================

echo.
echo Connexion a MySQL et insertion des donnees de test...

mysql -u root -p candidature_plus < insert_test_data.sql

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ========================================
    echo   SUCCES ! Donnees de test inserees
    echo ========================================
    echo.
    echo Les donnees suivantes ont ete inserees :
    echo - 5 centres d'examen
    echo - 6 specialites
    echo - 3 concours ouverts
    echo - 4 gestionnaires
    echo - 5 candidats avec candidatures
    echo - Donnees de test complementaires
    echo.
    echo Candidats de test disponibles :
    echo - CAND-2025-000001 : Benali Youssef ^(candidature acceptee^)
    echo - CAND-2025-000002 : Zahra Khadija ^(candidature rejetee^)
    echo - CAND-2025-000003 : Idrissi Omar ^(en cours de validation^)
    echo - CAND-2025-000004 : Rhazi Sanaa ^(soumise^)
    echo - CAND-2025-000005 : Mansouri Rachid ^(confirmee^)
    echo.
    echo Vous pouvez maintenant tester l'application !
) else (
    echo.
    echo ========================================
    echo   ERREUR lors de l'insertion
    echo ========================================
    echo Verifiez que :
    echo - MySQL est demarre
    echo - La base candidature_plus existe
    echo - Le fichier insert_test_data.sql est present
    echo - Vous avez les droits d'acces
)

echo.
pause
