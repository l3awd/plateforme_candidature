# ========================================
# SCRIPT DE DIAGNOSTIC COMPLET
# Plateforme CandidaturePlus
# ========================================

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "   DIAGNOSTIC COMPLET CANDIDATURE PLUS" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$errors = @()
$warnings = @()
$successes = @()

# ========================================
# 1. VERIFICATION DES PROCESSUS
# ========================================
Write-Host "1. VERIFICATION DES PROCESSUS" -ForegroundColor Yellow
Write-Host "===============================" -ForegroundColor Yellow

# Vérifier Java
Write-Host "Vérification des processus Java..." -ForegroundColor White
$javaProcesses = Get-Process -Name "java" -ErrorAction SilentlyContinue
if ($javaProcesses) {
    foreach ($proc in $javaProcesses) {
        Write-Host "  ✓ Processus Java trouvé - PID: $($proc.Id), Mémoire: $([math]::Round($proc.WorkingSet/1MB, 2)) MB" -ForegroundColor Green
        $successes += "Processus Java actif (PID: $($proc.Id))"
    }
}
else {
    Write-Host "  ✗ Aucun processus Java trouvé" -ForegroundColor Red
    $errors += "Aucun processus Java en cours d'exécution"
}

# Vérifier Node.js
Write-Host "Vérification des processus Node.js..." -ForegroundColor White
$nodeProcesses = Get-Process -Name "node" -ErrorAction SilentlyContinue
if ($nodeProcesses) {
    foreach ($proc in $nodeProcesses) {
        Write-Host "  ✓ Processus Node.js trouvé - PID: $($proc.Id), Mémoire: $([math]::Round($proc.WorkingSet/1MB, 2)) MB" -ForegroundColor Green
        $successes += "Processus Node.js actif (PID: $($proc.Id))"
    }
}
else {
    Write-Host "  ⚠ Aucun processus Node.js trouvé" -ForegroundColor Yellow
    $warnings += "Frontend React possiblement non démarré (aucun processus Node.js)"
}

# ========================================
# 2. VERIFICATION DES PORTS
# ========================================
Write-Host ""
Write-Host "2. VERIFICATION DES PORTS" -ForegroundColor Yellow
Write-Host "==========================" -ForegroundColor Yellow

# Port 8080 (Backend)
Write-Host "Vérification du port 8080 (Backend Spring Boot)..." -ForegroundColor White
$port8080 = netstat -ano | Select-String ":8080.*LISTENING"
if ($port8080) {
    Write-Host "  ✓ Port 8080 en écoute" -ForegroundColor Green
    $port8080 | ForEach-Object {
        $parts = $_.ToString().Split() | Where-Object { $_ -ne "" }
        if ($parts.Length -ge 5) {
            $processId = $parts[4]
            Write-Host "    - Processus PID: $processId" -ForegroundColor Cyan
        }
    }
    $successes += "Port 8080 actif (Backend Spring Boot)"
}
else {
    Write-Host "  ✗ Port 8080 non utilisé" -ForegroundColor Red
    $errors += "Backend Spring Boot n'écoute pas sur le port 8080"
}

# Port 3000 (Frontend)
Write-Host "Vérification du port 3000 (Frontend React)..." -ForegroundColor White
$port3000 = netstat -ano | Select-String ":3000.*LISTENING"
if ($port3000) {
    Write-Host "  ✓ Port 3000 en écoute" -ForegroundColor Green
    $successes += "Port 3000 actif (Frontend React)"
}
else {
    Write-Host "  ⚠ Port 3000 non utilisé" -ForegroundColor Yellow
    $warnings += "Frontend React n'écoute pas sur le port 3000"
}

# ========================================
# 3. TEST DE CONNECTIVITE BACKEND
# ========================================
Write-Host ""
Write-Host "3. TEST DE CONNECTIVITE BACKEND" -ForegroundColor Yellow
Write-Host "================================" -ForegroundColor Yellow

# Test ping backend
Write-Host "Test de connectivité basique vers le backend..." -ForegroundColor White
try {
    $response = Invoke-WebRequest "http://localhost:8080/api/test/ping" -UseBasicParsing -TimeoutSec 5 -ErrorAction Stop
    Write-Host "  ✓ Backend répond au ping - Status: $($response.StatusCode)" -ForegroundColor Green
    Write-Host "    Response: $($response.Content)" -ForegroundColor Cyan
    $successes += "Backend répond au ping"
}
catch {
    Write-Host "  ✗ Backend ne répond pas au ping" -ForegroundColor Red
    Write-Host "    Erreur: $($_.Exception.Message)" -ForegroundColor Red
    $errors += "Backend ne répond pas au ping - $($_.Exception.Message)"
}

# Test health check
Write-Host "Test du health check backend..." -ForegroundColor White
try {
    $response = Invoke-WebRequest "http://localhost:8080/api/test/health" -UseBasicParsing -TimeoutSec 5 -ErrorAction Stop
    Write-Host "  ✓ Health check réussi - Status: $($response.StatusCode)" -ForegroundColor Green
    $healthData = $response.Content | ConvertFrom-Json
    Write-Host "    Base de données: $($healthData.status)" -ForegroundColor Cyan
    Write-Host "    Utilisateurs: $($healthData.nombre_utilisateurs)" -ForegroundColor Cyan
    Write-Host "    Candidats: $($healthData.nombre_candidats)" -ForegroundColor Cyan
    $successes += "Health check backend réussi"
}
catch {
    Write-Host "  ✗ Health check échoué" -ForegroundColor Red
    Write-Host "    Erreur: $($_.Exception.Message)" -ForegroundColor Red
    $errors += "Health check backend échoué - $($_.Exception.Message)"
}

# ========================================
# 4. TEST DES ENDPOINTS API CRITIQUES
# ========================================
Write-Host ""
Write-Host "4. TEST DES ENDPOINTS API CRITIQUES" -ForegroundColor Yellow
Write-Host "====================================" -ForegroundColor Yellow

$endpoints = @(
    @{name = "Concours"; url = "http://localhost:8080/api/concours" },
    @{name = "Centres"; url = "http://localhost:8080/api/centres" },
    @{name = "Spécialités"; url = "http://localhost:8080/api/specialites" },
    @{name = "API Home"; url = "http://localhost:8080/api/" }
)

foreach ($endpoint in $endpoints) {
    Write-Host "Test de l'endpoint $($endpoint.name)..." -ForegroundColor White
    try {
        $response = Invoke-WebRequest $endpoint.url -UseBasicParsing -TimeoutSec 10 -ErrorAction Stop
        if ($response.StatusCode -eq 200) {
            Write-Host "  ✓ $($endpoint.name) OK - Status: $($response.StatusCode)" -ForegroundColor Green
            $data = $response.Content | ConvertFrom-Json
            if ($data -is [Array]) {
                Write-Host "    Nombre d'éléments: $($data.Count)" -ForegroundColor Cyan
            }
            elseif ($data.PSObject.Properties["statistics"]) {
                Write-Host "    Statistiques disponibles" -ForegroundColor Cyan
            }
            $successes += "Endpoint $($endpoint.name) fonctionnel"
        }
        else {
            Write-Host "  ⚠ $($endpoint.name) - Status inhabituel: $($response.StatusCode)" -ForegroundColor Yellow
            $warnings += "Endpoint $($endpoint.name) retourne status $($response.StatusCode)"
        }
    }
    catch {
        Write-Host "  ✗ $($endpoint.name) ECHEC" -ForegroundColor Red
        Write-Host "    Erreur: $($_.Exception.Message)" -ForegroundColor Red
        $errors += "Endpoint $($endpoint.name) inaccessible - $($_.Exception.Message)"
    }
}

# ========================================
# 5. VERIFICATION DE LA BASE DE DONNEES
# ========================================
Write-Host ""
Write-Host "5. VERIFICATION DE LA BASE DE DONNEES" -ForegroundColor Yellow
Write-Host "======================================" -ForegroundColor Yellow

# Vérification MySQL
Write-Host "Vérification du service MySQL..." -ForegroundColor White
$mysqlService = Get-Service -Name "MySQL*" -ErrorAction SilentlyContinue
if ($mysqlService) {
    foreach ($service in $mysqlService) {
        if ($service.Status -eq "Running") {
            Write-Host "  ✓ Service MySQL '$($service.Name)' en cours d'exécution" -ForegroundColor Green
            $successes += "Service MySQL actif"
        }
        else {
            Write-Host "  ✗ Service MySQL '$($service.Name)' arrêté (Status: $($service.Status))" -ForegroundColor Red
            $errors += "Service MySQL arrêté"
        }
    }
}
else {
    Write-Host "  ⚠ Aucun service MySQL trouvé (peut être installé différemment)" -ForegroundColor Yellow
    $warnings += "Service MySQL non détecté"
}

# Test de connexion à la base via l'API
Write-Host "Test de connexion à la base via l'API..." -ForegroundColor White
try {
    $response = Invoke-WebRequest "http://localhost:8080/api/health" -UseBasicParsing -TimeoutSec 5 -ErrorAction Stop
    $healthData = $response.Content | ConvertFrom-Json
    if ($healthData.database -eq "connected") {
        Write-Host "  ✓ Connexion à la base de données via l'API: OK" -ForegroundColor Green
        $successes += "Base de données accessible via l'API"
    }
    else {
        Write-Host "  ✗ Problème de connexion à la base de données" -ForegroundColor Red
        $errors += "Base de données non accessible"
    }
}
catch {
    Write-Host "  ✗ Impossible de tester la connexion DB via l'API" -ForegroundColor Red
    $errors += "Impossible de tester la connexion DB - $($_.Exception.Message)"
}

# ========================================
# 6. VERIFICATION DES FICHIERS DE CONFIGURATION
# ========================================
Write-Host ""
Write-Host "6. VERIFICATION DES FICHIERS DE CONFIGURATION" -ForegroundColor Yellow
Write-Host "===============================================" -ForegroundColor Yellow

# Application.properties
$appPropsPath = "backend\src\main\resources\application.properties"
Write-Host "Vérification de $appPropsPath..." -ForegroundColor White
if (Test-Path $appPropsPath) {
    Write-Host "  ✓ Fichier application.properties trouvé" -ForegroundColor Green
    $content = Get-Content $appPropsPath
    $dbUrl = $content | Select-String "spring.datasource.url"
    $dbUser = $content | Select-String "spring.datasource.username"
    if ($dbUrl) {
        Write-Host "    DB URL: $($dbUrl.ToString().Trim())" -ForegroundColor Cyan
    }
    if ($dbUser) {
        Write-Host "    DB User: $($dbUser.ToString().Trim())" -ForegroundColor Cyan
    }
    $successes += "Fichier de configuration trouvé"
}
else {
    Write-Host "  ✗ Fichier application.properties manquant" -ForegroundColor Red
    $errors += "Fichier application.properties manquant"
}

# Package.json frontend
$packageJsonPath = "frontend\package.json"
Write-Host "Vérification de $packageJsonPath..." -ForegroundColor White
if (Test-Path $packageJsonPath) {
    Write-Host "  ✓ Fichier package.json trouvé" -ForegroundColor Green
    $packageData = Get-Content $packageJsonPath | ConvertFrom-Json
    Write-Host "    Nom: $($packageData.name)" -ForegroundColor Cyan
    Write-Host "    Version: $($packageData.version)" -ForegroundColor Cyan
    $successes += "Package.json frontend trouvé"
}
else {
    Write-Host "  ✗ Fichier package.json manquant" -ForegroundColor Red
    $errors += "Package.json frontend manquant"
}

# ========================================
# 7. VERIFICATION DES DEPENDANCES
# ========================================
Write-Host ""
Write-Host "7. VERIFICATION DES DEPENDANCES" -ForegroundColor Yellow
Write-Host "================================" -ForegroundColor Yellow

# Node modules
Write-Host "Vérification des node_modules..." -ForegroundColor White
if (Test-Path "frontend\node_modules") {
    $nodeModulesCount = (Get-ChildItem "frontend\node_modules" -Directory).Count
    Write-Host "  ✓ Dossier node_modules trouvé ($nodeModulesCount packages)" -ForegroundColor Green
    $successes += "Node modules installés"
}
else {
    Write-Host "  ✗ Dossier node_modules manquant" -ForegroundColor Red
    $errors += "Node modules non installés"
}

# JAR backend
Write-Host "Vérification du JAR backend..." -ForegroundColor White
$jarPath = "backend\target\candidatureplus-0.0.1-SNAPSHOT.jar"
if (Test-Path $jarPath) {
    $jarInfo = Get-Item $jarPath
    Write-Host "  ✓ JAR backend trouvé" -ForegroundColor Green
    Write-Host "    Taille: $([math]::Round($jarInfo.Length/1MB, 2)) MB" -ForegroundColor Cyan
    Write-Host "    Modifié: $($jarInfo.LastWriteTime)" -ForegroundColor Cyan
    $successes += "JAR backend compilé"
}
else {
    Write-Host "  ✗ JAR backend manquant" -ForegroundColor Red
    $errors += "JAR backend non compile"
}

# ========================================
# 8. TEST DE CONNECTIVITE FRONTEND
# ========================================
Write-Host ""
Write-Host "8. TEST DE CONNECTIVITE FRONTEND" -ForegroundColor Yellow
Write-Host "=================================" -ForegroundColor Yellow

# Test du frontend
Write-Host "Test de connectivité vers le frontend..." -ForegroundColor White
try {
    $response = Invoke-WebRequest "http://localhost:3000" -UseBasicParsing -TimeoutSec 5 -ErrorAction Stop
    Write-Host "  ✓ Frontend accessible - Status: $($response.StatusCode)" -ForegroundColor Green
    $successes += "Frontend accessible"
}
catch {
    Write-Host "  ✗ Frontend inaccessible" -ForegroundColor Red
    Write-Host "    Erreur: $($_.Exception.Message)" -ForegroundColor Red
    $errors += "Frontend inaccessible - $($_.Exception.Message)"
}

# ========================================
# 9. VERIFICATION DES LOGS
# ========================================
Write-Host ""
Write-Host "9. VERIFICATION DES LOGS" -ForegroundColor Yellow
Write-Host "=========================" -ForegroundColor Yellow

# Recherche de fichiers de logs
Write-Host "Recherche de fichiers de logs..." -ForegroundColor White
$logFiles = @()
$logFiles += Get-ChildItem -Path "." -Recurse -Include "*.log" -ErrorAction SilentlyContinue
$logFiles += Get-ChildItem -Path "backend" -Recurse -Include "application.log", "spring.log" -ErrorAction SilentlyContinue

if ($logFiles.Count -gt 0) {
    Write-Host "  ✓ $($logFiles.Count) fichier(s) de logs trouvé(s)" -ForegroundColor Green
    foreach ($log in $logFiles) {
        Write-Host "    - $($log.FullName)" -ForegroundColor Cyan
    }
    $successes += "Fichiers de logs disponibles"
}
else {
    Write-Host "  ⚠ Aucun fichier de log trouvé" -ForegroundColor Yellow
    $warnings += "Aucun fichier de log disponible"
}

# ========================================
# 10. TEST SPECIFIQUE DU PROBLEME POSTES
# ========================================
Write-Host ""
Write-Host "10. TEST SPECIFIQUE DU PROBLEME POSTES" -ForegroundColor Yellow
Write-Host "=======================================" -ForegroundColor Yellow

Write-Host "Simulation de la requête PostesPage..." -ForegroundColor White
$postesEndpoints = @(
    "http://localhost:8080/api/concours",
    "http://localhost:8080/api/centres", 
    "http://localhost:8080/api/specialites"
)

$postesSuccess = $true
foreach ($endpoint in $postesEndpoints) {
    try {
        $response = Invoke-WebRequest $endpoint -UseBasicParsing -TimeoutSec 10 -ErrorAction Stop
        $data = $response.Content | ConvertFrom-Json
        $endpointName = $endpoint.Split('/')[-1]
        
        if ($data -is [Array] -and $data.Count -gt 0) {
            Write-Host "  ✓ ${endpointName}: $($data.Count) éléments trouvés" -ForegroundColor Green
            
            # Vérification des champs critiques
            $firstItem = $data[0]
            if ($firstItem.PSObject.Properties["actif"]) {
                $activeCount = ($data | Where-Object { $_.actif -eq $true }).Count
                Write-Host "    - Éléments actifs: $activeCount/$($data.Count)" -ForegroundColor Cyan
            }
            
            if ($endpointName -eq "concours") {
                foreach ($concours in $data) {
                    if ($concours.PSObject.Properties["dateDebutCandidature"] -and $concours.PSObject.Properties["dateFinCandidature"]) {
                        $debut = [DateTime]::Parse($concours.dateDebutCandidature)
                        $fin = [DateTime]::Parse($concours.dateFinCandidature)
                        $now = Get-Date
                        if ($debut -le $now -and $fin -ge $now -and $concours.actif) {
                            Write-Host "    - Concours '$($concours.nom)' ouvert pour candidatures" -ForegroundColor Green
                        }
                    }
                }
            }
            
        }
        elseif ($data -is [Array] -and $data.Count -eq 0) {
            Write-Host "  ⚠ ${endpointName}: Aucune donnée trouvée (tableau vide)" -ForegroundColor Yellow
            $warnings += "Endpoint $endpointName retourne un tableau vide"
            $postesSuccess = $false
        }
        else {
            Write-Host "  ⚠ ${endpointName}: Format de données inattendu" -ForegroundColor Yellow
            $warnings += "Endpoint $endpointName retourne un format inattendu"
            $postesSuccess = $false
        }
    }
    catch {
        Write-Host "  ✗ ${endpointName}: ECHEC" -ForegroundColor Red
        Write-Host "    Erreur: $($_.Exception.Message)" -ForegroundColor Red
        $errors += "Endpoint $endpointName échoué - $($_.Exception.Message)"
        $postesSuccess = $false
    }
}

if ($postesSuccess) {
    Write-Host "  ✓ Tous les endpoints requis pour PostesPage fonctionnent" -ForegroundColor Green
    $successes += "Endpoints PostesPage fonctionnels"
}
else {
    Write-Host "  ✗ Problème détecté avec les endpoints PostesPage" -ForegroundColor Red
    $errors += "Endpoints PostesPage défaillants"
}

# ========================================
# 11. VERIFICATION CORS ET SECURITE
# ========================================
Write-Host ""
Write-Host "11. VERIFICATION CORS ET SECURITE" -ForegroundColor Yellow
Write-Host "==================================" -ForegroundColor Yellow

Write-Host "Test des headers CORS..." -ForegroundColor White
try {
    $headers = @{
        'Origin'                         = 'http://localhost:3000'
        'Access-Control-Request-Method'  = 'GET'
        'Access-Control-Request-Headers' = 'Content-Type'
    }
    
    $response = Invoke-WebRequest "http://localhost:8080/api/concours" -Headers $headers -UseBasicParsing -ErrorAction Stop
    
    $corsHeaders = $response.Headers | Where-Object { $_.Key -like "*Access-Control*" }
    if ($corsHeaders) {
        Write-Host "  ✓ Headers CORS détectés" -ForegroundColor Green
        $successes += "CORS configuré"
    }
    else {
        Write-Host "  ⚠ Aucun header CORS détecté" -ForegroundColor Yellow
        $warnings += "Configuration CORS manquante ou incomplète"
    }
}
catch {
    Write-Host "  ✗ Test CORS échoué" -ForegroundColor Red
    $errors += "Test CORS échoué - $($_.Exception.Message)"
}

# ========================================
# RESUME DU DIAGNOSTIC
# ========================================
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "           RESUME DU DIAGNOSTIC" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

Write-Host ""
Write-Host "SUCCÈS ($($successes.Count)):" -ForegroundColor Green
foreach ($success in $successes) {
    Write-Host "  ✓ $success" -ForegroundColor Green
}

Write-Host ""
Write-Host "AVERTISSEMENTS ($($warnings.Count)):" -ForegroundColor Yellow
foreach ($warning in $warnings) {
    Write-Host "  ⚠ $warning" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "ERREURS ($($errors.Count)):" -ForegroundColor Red
foreach ($errorItem in $errors) {
    Write-Host "  ✗ $errorItem" -ForegroundColor Red
}

# ========================================
# RECOMMENDATIONS
# ========================================
Write-Host ""
Write-Host "RECOMMANDATIONS:" -ForegroundColor Cyan

if ($errors.Count -eq 0 -and $warnings.Count -eq 0) {
    Write-Host "  🎉 Tout semble fonctionner correctement!" -ForegroundColor Green
    Write-Host "  Si vous voyez encore l'erreur, vérifiez:" -ForegroundColor White
    Write-Host "    - La console du navigateur (F12)" -ForegroundColor White
    Write-Host "    - Les logs du terminal backend" -ForegroundColor White
    Write-Host "    - Actualisez la page (Ctrl+F5)" -ForegroundColor White
}
else {
    if ($errors -contains "Backend Spring Boot n'écoute pas sur le port 8080") {
        Write-Host "  🔧 Le backend n'est pas démarré. Lancez:" -ForegroundColor Yellow
        Write-Host "     cd backend" -ForegroundColor White
        Write-Host "     java -jar target/candidatureplus-0.0.1-SNAPSHOT.jar" -ForegroundColor White
    }
    
    if ($errors -contains "JAR backend non compile") {
        Write-Host "  Compilez le backend avec:" -ForegroundColor Yellow
        Write-Host "     cd backend" -ForegroundColor White
        Write-Host "     mvn clean package -DskipTests" -ForegroundColor White
    }
    
    if ($warnings -contains "Frontend React n'écoute pas sur le port 3000") {
        Write-Host "  🔧 Démarrez le frontend avec:" -ForegroundColor Yellow
        Write-Host "     cd frontend" -ForegroundColor White
        Write-Host "     npm start" -ForegroundColor White
    }
    
    if ($errors -contains "Node modules non installés") {
        Write-Host "  🔧 Installez les dépendances avec:" -ForegroundColor Yellow
        Write-Host "     cd frontend" -ForegroundColor White
        Write-Host "     npm install" -ForegroundColor White
    }
    
    if ($errors.Count -gt 0 -and ($errors | Where-Object { $_ -like "*Base de donnees*" })) {
        Write-Host "  🔧 Vérifiez MySQL et exécutez:" -ForegroundColor Yellow
        Write-Host "     - Démarrez MySQL" -ForegroundColor White
        Write-Host "     - Exécutez create_database.sql" -ForegroundColor White
        Write-Host "     - Exécutez insert_test_data.sql" -ForegroundColor White
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "        FIN DU DIAGNOSTIC" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

# Sauvegarder le rapport
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$reportPath = "diagnostic_report_$timestamp.txt"
$report = @"
RAPPORT DE DIAGNOSTIC - $(Get-Date)

SUCCES:
$(($successes | ForEach-Object { "  OK $_" }) -join "`n")

AVERTISSEMENTS:
$(($warnings | ForEach-Object { "  WARN $_" }) -join "`n")

ERREURS:
$(($errors | ForEach-Object { "  ERR $_" }) -join "`n")
"@

$report | Out-File -FilePath $reportPath -Encoding UTF8
Write-Host "Rapport sauvegarde dans le fichier: $reportPath" -ForegroundColor Cyan
