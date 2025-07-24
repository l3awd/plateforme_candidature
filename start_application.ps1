# ========================================
# CANDIDATURE PLUS - SCRIPT DE LANCEMENT
# ========================================

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "    LANCEMENT DE CANDIDATURE PLUS" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Vérification des prérequis
Write-Host "Verification des prerequisites..." -ForegroundColor Yellow

# Test de Java
try { java -version *>$null; Write-Host "✓ Java: OK" -ForegroundColor Green }
catch { Write-Host "✗ Java: MANQUANT" -ForegroundColor Red; exit 1 }

# Test de Node.js
try { node --version *>$null; Write-Host "✓ Node.js: OK" -ForegroundColor Green }
catch { Write-Host "✗ Node.js: MANQUANT" -ForegroundColor Red; exit 1 }

# Test de npm
try { npm --version *>$null; Write-Host "✓ npm: OK" -ForegroundColor Green }
catch { Write-Host "✗ npm: MANQUANT" -ForegroundColor Red; exit 1 }

# Test de Maven
try { mvn --version *>$null; Write-Host "✓ Maven: OK" -ForegroundColor Green }
catch { Write-Host "✗ Maven: MANQUANT" -ForegroundColor Red; exit 1 }

Write-Host ""

# Compilation du backend
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "   COMPILATION DU BACKEND SPRING BOOT" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Set-Location "backend"
Write-Host "Compilation du backend..." -ForegroundColor Yellow

& mvn clean package -DskipTests
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERREUR: Echec de la compilation du backend!" -ForegroundColor Red
    Read-Host "Appuyez sur Entree pour quitter"
    exit 1
}

# Installation des dépendances frontend
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "   INSTALLATION DES DEPENDANCES FRONTEND" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Set-Location "..\frontend"

if (-not (Test-Path "node_modules")) {
    Write-Host "Installation des dependances npm..." -ForegroundColor Yellow
    & npm install
    if ($LASTEXITCODE -ne 0) {
        Write-Host "ERREUR: Echec de l'installation des dependances frontend!" -ForegroundColor Red
        Read-Host "Appuyez sur Entree pour quitter"
        exit 1
    }
} else {
    Write-Host "Dependances npm deja installees." -ForegroundColor Green
}

# Démarrage des applications
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "   DEMARRAGE DES APPLICATIONS" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "BACKEND: http://localhost:8080" -ForegroundColor Green
Write-Host "FRONTEND: http://localhost:3000" -ForegroundColor Green
Write-Host ""
Write-Host "Identifiants de connexion:" -ForegroundColor Yellow
Write-Host "- Nom d'utilisateur: admin" -ForegroundColor White
Write-Host "- Mot de passe: 1234" -ForegroundColor White
Write-Host ""

# Démarrage du backend
Set-Location "..\backend"
Write-Host "Demarrage du backend Spring Boot..." -ForegroundColor Yellow
Start-Process -FilePath "powershell" -ArgumentList "-Command", "java -jar target\candidatureplus-0.0.1-SNAPSHOT.jar" -WindowStyle Normal

# Attendre que le backend démarre
Write-Host "Attente du demarrage du backend (15 secondes)..." -ForegroundColor Yellow
Start-Sleep -Seconds 15

# Démarrage du frontend
Set-Location "..\frontend"
Write-Host "Demarrage du frontend React..." -ForegroundColor Yellow
Start-Process -FilePath "powershell" -ArgumentList "-Command", "npm start" -WindowStyle Normal

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "   APPLICATIONS DEMARREES AVEC SUCCES!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Backend Spring Boot: http://localhost:8080" -ForegroundColor Green
Write-Host "Frontend React: http://localhost:3000" -ForegroundColor Green
Write-Host ""
Write-Host "Le navigateur va s'ouvrir automatiquement sur l'application." -ForegroundColor Yellow
Write-Host ""
Write-Host "Pour arreter les applications:" -ForegroundColor Red
Write-Host "1. Fermez les fenetres PowerShell des applications" -ForegroundColor White
Write-Host "2. Ou utilisez Ctrl+C dans chaque terminal" -ForegroundColor White
Write-Host ""

# Attendre puis ouvrir le navigateur
Start-Sleep -Seconds 10
Start-Process "http://localhost:3000"

Write-Host "Script termine. Les applications tournent en arriere-plan." -ForegroundColor Green
Read-Host "Appuyez sur Entree pour quitter"

# Retour au répertoire de base
Set-Location ".."
