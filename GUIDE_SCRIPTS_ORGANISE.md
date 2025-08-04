# 📋 Guide d'Organisation des Scripts de Déploiement

## 🎯 Organisation par Fréquence d'Utilisation

### 🔥 Scripts de Développement Quotidien (Usage Fréquent)

#### 1. **start_app.bat** - Démarrage Application Complète

```batch
@echo off
echo ================================================================
echo        DÉMARRAGE DE L'APPLICATION CANDIDATURE PLUS
echo ================================================================
echo.

echo [1/3] Démarrage du Backend Spring Boot...
start "Backend" cmd /c "cd backend && mvn spring-boot:run"
timeout /t 15 /nobreak > nul

echo [2/3] Démarrage du Frontend React...
start "Frontend" cmd /c "cd frontend && npm start"
timeout /t 10 /nobreak > nul

echo [3/3] Applications démarrées avec succès !
echo.
echo 🌐 Frontend: http://localhost:3000
echo 🔧 Backend:  http://localhost:8080
echo 📊 API Docs: http://localhost:8080/swagger-ui.html
echo.
echo ================================================================
pause
```

#### 2. **stop_app.bat** - Arrêt Application Complète

```batch
@echo off
echo ================================================================
echo         ARRÊT DE L'APPLICATION CANDIDATURE PLUS
echo ================================================================
echo.

echo Arrêt des processus Java (Backend)...
taskkill /f /im java.exe > nul 2>&1

echo Arrêt des processus Node.js (Frontend)...
taskkill /f /im node.exe > nul 2>&1

echo Arrêt des processus cmd liés...
for /f "tokens=2" %%i in ('tasklist /fi "WindowTitle eq Backend*" /fo csv /nh 2^>nul') do taskkill /pid %%i /f > nul 2>&1
for /f "tokens=2" %%i in ('tasklist /fi "WindowTitle eq Frontend*" /fo csv /nh 2^>nul') do taskkill /pid %%i /f > nul 2>&1

echo.
echo ✅ Applications arrêtées avec succès !
echo ================================================================
pause
```

#### 3. **check_system.bat** - Vérification Système Rapide

```batch
@echo off
echo ================================================================
echo           VÉRIFICATION SYSTÈME CANDIDATURE PLUS
echo ================================================================
echo.

echo 🔍 Vérification des prérequis...
echo.

:: Vérification Java
echo [Java]
java -version 2>nul
if %errorlevel% neq 0 (
    echo ❌ Java non installé ou non configuré
) else (
    echo ✅ Java installé
)
echo.

:: Vérification Maven
echo [Maven]
mvn -version 2>nul
if %errorlevel% neq 0 (
    echo ❌ Maven non installé ou non configuré
) else (
    echo ✅ Maven installé
)
echo.

:: Vérification Node.js
echo [Node.js]
node -v 2>nul
if %errorlevel% neq 0 (
    echo ❌ Node.js non installé
) else (
    echo ✅ Node.js installé
)
echo.

:: Vérification npm
echo [npm]
npm -v 2>nul
if %errorlevel% neq 0 (
    echo ❌ npm non disponible
) else (
    echo ✅ npm disponible
)
echo.

:: Vérification des ports
echo [Ports]
netstat -an | findstr ":3000" > nul
if %errorlevel% eq 0 (
    echo ⚠️  Port 3000 occupé (Frontend)
) else (
    echo ✅ Port 3000 libre
)

netstat -an | findstr ":8080" > nul
if %errorlevel% eq 0 (
    echo ⚠️  Port 8080 occupé (Backend)
) else (
    echo ✅ Port 8080 libre
)

echo.
echo ================================================================
pause
```

### 📊 Scripts de Base de Données (Usage Régulier)

#### 4. **init_database.sql** - Initialisation Base

```sql
-- Script d'initialisation de la base de données
-- Usage: Première installation ou réinitialisation complète

DROP DATABASE IF EXISTS candidature_plus;
CREATE DATABASE candidature_plus CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE candidature_plus;

-- Création des tables principales
-- (Contenu existant...)
```

#### 5. **insert_test_data.sql** - Données de Test

```sql
-- Insertion de données de test pour le développement
-- Usage: Après init_database.sql pour avoir des données d'exemple

USE candidature_plus;

-- Insertion des centres de concours
-- (Contenu existant...)
```

#### 6. **clean_test_data.sql** - Nettoyage Données Test

```sql
-- Nettoyage des données de test
-- Usage: Avant mise en production ou pour réinitialiser

USE candidature_plus;

SET FOREIGN_KEY_CHECKS = 0;

DELETE FROM candidatures;
DELETE FROM concours_specialites;
DELETE FROM concours_centres;
DELETE FROM specialites;
DELETE FROM concours;
DELETE FROM centres_concours;
DELETE FROM users;

SET FOREIGN_KEY_CHECKS = 1;

-- Réinitialisation des auto-increment
ALTER TABLE candidatures AUTO_INCREMENT = 1;
ALTER TABLE concours AUTO_INCREMENT = 1;
ALTER TABLE specialites AUTO_INCREMENT = 1;
ALTER TABLE centres_concours AUTO_INCREMENT = 1;
ALTER TABLE users AUTO_INCREMENT = 1;
```

### 🔧 Scripts de Maintenance (Usage Occasionnel)

#### 7. **update_db.sql** - Mise à Jour Base

```sql
-- Script de mise à jour de la base de données
-- Usage: Migrations et évolutions de schéma

USE candidature_plus;

-- Exemple de migration
-- ALTER TABLE candidatures ADD COLUMN date_modification TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP;

-- Vérification de l'intégrité
SELECT 'Candidatures' as table_name, COUNT(*) as count FROM candidatures
UNION ALL
SELECT 'Concours' as table_name, COUNT(*) as count FROM concours
UNION ALL
SELECT 'Spécialités' as table_name, COUNT(*) as count FROM specialites;
```

#### 8. **apply_changes.bat** - Application Changements

```batch
@echo off
echo ================================================================
echo       APPLICATION DES CHANGEMENTS - CANDIDATURE PLUS
echo ================================================================
echo.

echo 🔄 Arrêt des applications...
call stop_app.bat

echo.
echo 🔨 Compilation du backend...
cd backend
mvn clean compile
if %errorlevel% neq 0 (
    echo ❌ Erreur de compilation backend
    pause
    exit /b 1
)

echo.
echo 📦 Installation des dépendances frontend...
cd ..\frontend
npm install
if %errorlevel% neq 0 (
    echo ❌ Erreur installation frontend
    pause
    exit /b 1
)

echo.
echo ✅ Changements appliqués avec succès !
echo 🚀 Démarrage des applications...
cd ..
call start_app.bat
```

#### 9. **diagnostic_app.ps1** - Diagnostic Avancé

```powershell
# Script PowerShell de diagnostic avancé
# Usage: Résolution de problèmes complexes

Write-Host "================================================================" -ForegroundColor Cyan
Write-Host "           DIAGNOSTIC AVANCÉ - CANDIDATURE PLUS" -ForegroundColor Cyan
Write-Host "================================================================" -ForegroundColor Cyan
Write-Host

# Vérification des processus
Write-Host "🔍 Processus actifs:" -ForegroundColor Yellow
Get-Process | Where-Object {$_.ProcessName -match "java|node"} | Format-Table ProcessName, Id, CPU

# Vérification des ports
Write-Host "🌐 Ports utilisés:" -ForegroundColor Yellow
Get-NetTCPConnection | Where-Object {$_.LocalPort -eq 3000 -or $_.LocalPort -eq 8080} | Format-Table LocalPort, State, OwningProcess

# Vérification des logs
Write-Host "📝 Derniers logs:" -ForegroundColor Yellow
if (Test-Path "backend\logs\*.log") {
    Get-ChildItem "backend\logs\*.log" | Sort-Object LastWriteTime -Descending | Select-Object -First 1 | Get-Content -Tail 10
}

# Vérification de l'espace disque
Write-Host "💾 Espace disque:" -ForegroundColor Yellow
Get-WmiObject -Class Win32_LogicalDisk | Select-Object DeviceID, @{Name="Size(GB)";Expression={[math]::Round($_.Size/1GB,2)}}, @{Name="FreeSpace(GB)";Expression={[math]::Round($_.FreeSpace/1GB,2)}}

Read-Host "Appuyez sur Entrée pour continuer..."
```

## 📋 Guide d'Utilisation par Scénario

### 🚀 Démarrage Quotidien

1. **check_system.bat** - Vérifier que tout est OK
2. **start_app.bat** - Démarrer l'application

### 🔄 Développement

1. **Modifications code** ➜ **apply_changes.bat**
2. **Tests** ➜ **clean_test_data.sql** + **insert_test_data.sql**
3. **Fin de journée** ➜ **stop_app.bat**

### 🆕 Nouvelle Installation

1. **check_system.bat** - Vérifier prérequis
2. **init_database.sql** - Créer la base
3. **insert_test_data.sql** - Ajouter données test
4. **start_app.bat** - Démarrer

### 🔧 Résolution Problèmes

1. **diagnostic_app.ps1** - Diagnostic avancé
2. **stop_app.bat** - Arrêt propre
3. **apply_changes.bat** - Recompilation
4. **start_app.bat** - Redémarrage

### 🚀 Mise en Production

1. **clean_test_data.sql** - Nettoyer données test
2. **update_db.sql** - Appliquer migrations
3. **apply_changes.bat** - Application finale

## 📁 Structure Recommandée

```
plateforme_candidature/
├── 🔥 QUOTIDIEN/
│   ├── start_app.bat
│   ├── stop_app.bat
│   └── check_system.bat
├── 📊 BASE_DONNEES/
│   ├── init_database.sql
│   ├── insert_test_data.sql
│   ├── clean_test_data.sql
│   └── update_db.sql
├── 🔧 MAINTENANCE/
│   ├── apply_changes.bat
│   └── diagnostic_app.ps1
└── 📖 DOCUMENTATION/
    ├── README.md
    ├── SCRIPTS_GUIDE.md
    └── CHANGEMENTS_BASE_DONNEES.md
```
