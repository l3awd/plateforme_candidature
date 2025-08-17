# ===============================================
# SCRIPT DE DIAGNOSTIC AUTOMATIQUE BASE DE DONNÉES
# Plateforme Candidature - PowerShell
# ===============================================

param(
    [string]$Server = "localhost",
    [string]$Database = "candidature_plus",
    [string]$Username = "root",
    [string]$Password = ""
)

Write-Host "===============================================" -ForegroundColor Cyan
Write-Host "DIAGNOSTIC BASE DE DONNÉES - PLATEFORME CANDIDATURE" -ForegroundColor Cyan
Write-Host "===============================================" -ForegroundColor Cyan
Write-Host ""

# Configuration
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$reportFile = "diagnostic_database_$timestamp.txt"

# Fonction pour exécuter une requête MySQL
function Invoke-MySQLQuery {
    param([string]$Query)
    
    try {
        $result = mysql -h $Server -u $Username $(if ($Password) { "-p$Password" }) -D $Database -e $Query 2>&1
        return $result
    }
    catch {
        Write-Host "Erreur lors de l'exécution de la requête: $_" -ForegroundColor Red
        return $null
    }
}

# Démarrage du diagnostic
Write-Host "🔍 Démarrage du diagnostic de la base de données..." -ForegroundColor Yellow
Write-Host "📊 Serveur: $Server" -ForegroundColor Gray
Write-Host "📊 Base: $Database" -ForegroundColor Gray
Write-Host "📊 Rapport: $reportFile" -ForegroundColor Gray
Write-Host ""

# Test de connexion
Write-Host "1. Test de connexion à la base de données..." -ForegroundColor Green
$connectionTest = Invoke-MySQLQuery "SELECT 'Connexion réussie' as status;"
if ($connectionTest -match "Connexion réussie") {
    Write-Host "   ✅ Connexion établie" -ForegroundColor Green
}
else {
    Write-Host "   ❌ Échec de connexion" -ForegroundColor Red
    Write-Host "   Erreur: $connectionTest" -ForegroundColor Red
    exit 1
}

# Vérification des tables
Write-Host "2. Vérification de l'existence des tables..." -ForegroundColor Green
$tables = @(
    "Candidat", "Utilisateur", "Centre", "Concours", "Specialite",
    "Candidature", "Document", "LogAction", "Notification",
    "ConcoursSpecialite", "ConcoursCentre", "CentreSpecialite"
)

$missingTables = @()
foreach ($table in $tables) {
    $result = Invoke-MySQLQuery "SHOW TABLES LIKE '$table';"
    if ($result -match $table) {
        Write-Host "   ✅ Table $table existe" -ForegroundColor Green
    }
    else {
        Write-Host "   ❌ Table $table manquante" -ForegroundColor Red
        $missingTables += $table
    }
}

# Comptage des enregistrements
Write-Host "3. Comptage des enregistrements..." -ForegroundColor Green
foreach ($table in $tables) {
    if ($table -notin $missingTables) {
        $count = Invoke-MySQLQuery "SELECT COUNT(*) FROM $table;" | Select-String -Pattern '\d+' | ForEach-Object { $_.Matches[0].Value }
        if ($count -eq "0") {
            Write-Host "   ⚠️  Table $table est vide" -ForegroundColor Yellow
        }
        else {
            Write-Host "   📊 Table $table : $count enregistrement(s)" -ForegroundColor Cyan
        }
    }
}

# Vérifications critiques
Write-Host "4. Vérifications critiques..." -ForegroundColor Green

# Utilisateurs administrateur
$adminCount = Invoke-MySQLQuery "SELECT COUNT(*) FROM Utilisateur WHERE role = 'Administrateur' AND actif = 1;" | Select-String -Pattern '\d+' | ForEach-Object { $_.Matches[0].Value }
if ($adminCount -eq "0") {
    Write-Host "   ❌ Aucun administrateur actif trouvé" -ForegroundColor Red
}
else {
    Write-Host "   ✅ $adminCount administrateur(s) actif(s)" -ForegroundColor Green
}

# Concours actifs
$concoursCount = Invoke-MySQLQuery "SELECT COUNT(*) FROM Concours WHERE actif = 1;" | Select-String -Pattern '\d+' | ForEach-Object { $_.Matches[0].Value }
if ($concoursCount -eq "0") {
    Write-Host "   ⚠️  Aucun concours actif" -ForegroundColor Yellow
}
else {
    Write-Host "   ✅ $concoursCount concours actif(s)" -ForegroundColor Green
}

# Centres actifs
$centresCount = Invoke-MySQLQuery "SELECT COUNT(*) FROM Centre WHERE actif = 1;" | Select-String -Pattern '\d+' | ForEach-Object { $_.Matches[0].Value }
if ($centresCount -eq "0") {
    Write-Host "   ⚠️  Aucun centre actif" -ForegroundColor Yellow
}
else {
    Write-Host "   ✅ $centresCount centre(s) actif(s)" -ForegroundColor Green
}

# Spécialités actives
$specialitesCount = Invoke-MySQLQuery "SELECT COUNT(*) FROM Specialite WHERE actif = 1;" | Select-String -Pattern '\d+' | ForEach-Object { $_.Matches[0].Value }
if ($specialitesCount -eq "0") {
    Write-Host "   ⚠️  Aucune spécialité active" -ForegroundColor Yellow
}
else {
    Write-Host "   ✅ $specialitesCount spécialité(s) active(s)" -ForegroundColor Green
}

# Génération du rapport complet
Write-Host "5. Génération du rapport complet..." -ForegroundColor Green
$fullDiagnostic = Invoke-MySQLQuery "source diagnostic_database.sql"

# Sauvegarde du rapport
$reportContent = @"
===============================================
RAPPORT DE DIAGNOSTIC BASE DE DONNÉES
Généré le: $(Get-Date)
Serveur: $Server
Base: $Database
===============================================

RÉSUMÉ EXÉCUTIF:
- Tables manquantes: $($missingTables.Count)
- Administrateurs actifs: $adminCount
- Concours actifs: $concoursCount
- Centres actifs: $centresCount
- Spécialités actives: $specialitesCount

TABLES MANQUANTES:
$($missingTables -join "`n")

DIAGNOSTIC COMPLET:
$fullDiagnostic
"@

$reportContent | Out-File -FilePath $reportFile -Encoding UTF8

Write-Host ""
Write-Host "===============================================" -ForegroundColor Cyan
Write-Host "DIAGNOSTIC TERMINÉ" -ForegroundColor Cyan
Write-Host "===============================================" -ForegroundColor Cyan
Write-Host "📄 Rapport sauvegardé: $reportFile" -ForegroundColor Green

# Recommandations
Write-Host ""
Write-Host "🔧 RECOMMANDATIONS:" -ForegroundColor Yellow

if ($missingTables.Count -gt 0) {
    Write-Host "   • Exécuter le script de migration: migration_complete.sql" -ForegroundColor Yellow
}

if ($adminCount -eq "0") {
    Write-Host "   • Créer un utilisateur administrateur" -ForegroundColor Yellow
}

if ($concoursCount -eq "0") {
    Write-Host "   • Ajouter des concours" -ForegroundColor Yellow
}

if ($centresCount -eq "0") {
    Write-Host "   • Ajouter des centres d'examen" -ForegroundColor Yellow
}

if ($specialitesCount -eq "0") {
    Write-Host "   • Ajouter des spécialités" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Pour plus de détails, consultez le fichier: $reportFile" -ForegroundColor Cyan
