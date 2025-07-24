@echo off
echo ========================================
echo    EXECUTION DU SCRIPT SQL - CandidaturePlus
echo ========================================
echo.

echo Ajout de MySQL au PATH...
set PATH=%PATH%;C:\Program Files\MySQL\MySQL Server 8.0\bin

echo.
echo Verification de MySQL...
mysql --version
if %errorlevel% neq 0 (
    echo ERREUR: MySQL non trouve!
    pause
    exit /b 1
)

echo.
echo ========================================
echo Execution du script de base de donnees...
echo ========================================
echo.

echo ATTENTION: Cela va recreer completement la base de donnees!
echo Appuyez sur une touche pour continuer ou Ctrl+C pour annuler...
pause

echo.
echo 1. Suppression de l'ancienne base de donnees...
echo DROP DATABASE IF EXISTS candidature_plus; | mysql -u root -p

echo.
echo 2. Creation de la nouvelle base de donnees...
type create_database.sql | mysql -u root -p

if %errorlevel% equ 0 (
    echo.
    echo ========================================
    echo   BASE DE DONNEES CREEE AVEC SUCCES!
    echo ========================================
    echo.
    echo Verification des tables creees:
    mysql -u root -p -e "USE candidature_plus; SHOW TABLES;"
    echo.
    echo Verification des donnees d'exemple:
    mysql -u root -p -e "USE candidature_plus; SELECT nom, ville FROM centre; SELECT nom, code FROM specialite;"
) else (
    echo.
    echo ========================================
    echo      ERREUR LORS DE LA CREATION!
    echo ========================================
)

echo.
pause
