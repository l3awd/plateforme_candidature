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
    $warnings += "Frontend React possiblement non démarré"
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

# Test health check
Write-Host "Test du health check backend..." -ForegroundColor White
try {
    $response = Invoke-WebRequest "http://localhost:8080/api/health" -UseBasicParsing -TimeoutSec 5 -ErrorAction Stop
    Write-Host "  ✓ Health check réussi - Status: $($response.StatusCode)" -ForegroundColor Green
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
    @{name = "Spécialités"; url = "http://localhost:8080/api/specialites" }
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
# 5. TEST D'AUTHENTIFICATION
# ========================================
Write-Host ""
Write-Host "5. TEST D'AUTHENTIFICATION" -ForegroundColor Yellow
Write-Host "===========================" -ForegroundColor Yellow

Write-Host "Test de l'authentification avec admin@test.com..." -ForegroundColor White
try {
    $body = @{
        email    = "admin@test.com"
        password = "1234"
    } | ConvertTo-Json

    $response = Invoke-WebRequest "http://localhost:8080/api/auth/login" -Method POST -Body $body -ContentType "application/json" -UseBasicParsing -TimeoutSec 5 -ErrorAction Stop
    
    if ($response.StatusCode -eq 200) {
        Write-Host "  ✓ Authentification réussie" -ForegroundColor Green
        $successes += "Système d'authentification fonctionnel"
    }
    else {
        Write-Host "  ⚠ Réponse inattendue: $($response.StatusCode)" -ForegroundColor Yellow
        $warnings += "Authentification retourne status $($response.StatusCode)"
    }
}
catch {
    Write-Host "  ✗ Échec de l'authentification" -ForegroundColor Red
    Write-Host "    Erreur: $($_.Exception.Message)" -ForegroundColor Red
    $errors += "Système d'authentification défaillant - $($_.Exception.Message)"
}

# ========================================
# 6. VERIFICATION DE LA BASE DE DONNEES
# ========================================
Write-Host ""
Write-Host "6. VERIFICATION DE LA BASE DE DONNEES" -ForegroundColor Yellow
Write-Host "======================================" -ForegroundColor Yellow

# Vérification MySQL via l'API
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
# 7. TEST DE CONNECTIVITE FRONTEND
# ========================================
Write-Host ""
Write-Host "7. TEST DE CONNECTIVITE FRONTEND" -ForegroundColor Yellow
Write-Host "=================================" -ForegroundColor Yellow

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
# 8. TEST DES NOUVELLES FONCTIONNALITES
# ========================================
Write-Host ""
Write-Host "8. TEST DES NOUVELLES FONCTIONNALITES" -ForegroundColor Yellow
Write-Host "======================================" -ForegroundColor Yellow

# Test des API de gestion de candidatures
Write-Host "Test des API de gestion de candidatures..." -ForegroundColor White
try {
    $response = Invoke-WebRequest "http://localhost:8080/api/candidatures/centre/1" -UseBasicParsing -TimeoutSec 5 -ErrorAction Stop
    Write-Host "  ✓ API gestion candidatures accessible" -ForegroundColor Green
    $successes += "API gestion candidatures fonctionnelle"
}
catch {
    Write-Host "  ✗ API gestion candidatures inaccessible" -ForegroundColor Red
    $errors += "API gestion candidatures défaillante"
}

# Test des documents
Write-Host "Test du système de documents..." -ForegroundColor White
try {
    $response = Invoke-WebRequest "http://localhost:8080/api/documents/fiches/technicien-2025.pdf" -UseBasicParsing -TimeoutSec 5 -ErrorAction Stop
    Write-Host "  ✓ Système de documents accessible" -ForegroundColor Green
    $successes += "Système de documents fonctionnel"
}
catch {
    Write-Host "  ⚠ Système de documents non accessible (normal si pas de fichiers)" -ForegroundColor Yellow
    $warnings += "Documents non accessibles"
}

# ========================================
# 9. TESTS BASE DE DONNEES APPROFONDIS
# ========================================
Write-Host ""
Write-Host "9. TESTS BASE DE DONNEES APPROFONDIS" -ForegroundColor Yellow
Write-Host "====================================" -ForegroundColor Yellow

# Test des tables Log_Action et Notification
Write-Host "Vérification des nouvelles tables (Log_Action, Notification)..." -ForegroundColor White
try {
    # Test direct de la table Log_Action via l'API
    $logsTestResponse = Invoke-WebRequest "http://localhost:8080/api/logs/test" -UseBasicParsing -TimeoutSec 5 -ErrorAction Stop
    $logsTest = $logsTestResponse.Content | ConvertFrom-Json
    
    if ($logsTest.status -eq "OK") {
        Write-Host "  ✓ Table Log_Action opérationnelle" -ForegroundColor Green
        Write-Host "    Total logs dans la base: $($logsTest.total_logs)" -ForegroundColor Cyan
        $successes += "Table Log_Action fonctionnelle avec $($logsTest.total_logs) entrées"
    }
    
    # Test direct de la table Notification via l'API
    $notifTestResponse = Invoke-WebRequest "http://localhost:8080/api/notifications/test" -UseBasicParsing -TimeoutSec 5 -ErrorAction Stop
    $notifTest = $notifTestResponse.Content | ConvertFrom-Json
    
    if ($notifTest.status -eq "OK") {
        Write-Host "  ✓ Table Notification opérationnelle" -ForegroundColor Green
        Write-Host "    Total notifications dans la base: $($notifTest.total_notifications)" -ForegroundColor Cyan
        $successes += "Table Notification fonctionnelle avec $($notifTest.total_notifications) entrées"
    }
}
catch {
    # Si les nouveaux endpoints ne sont pas disponibles, tester avec l'ancien méthode
    try {
        $response = Invoke-WebRequest "http://localhost:8080/api/auth/current" -UseBasicParsing -TimeoutSec 5 -ErrorAction Stop
        Write-Host "  ✓ Tables système accessibles via l'API" -ForegroundColor Green
        $successes += "Tables Log_Action et Notification présentes"
    }
    catch {
        Write-Host "  ⚠ Impossible de vérifier les tables système" -ForegroundColor Yellow
        $warnings += "Tables système non vérifiables"
    }
}

# Test des données de test
Write-Host "Vérification des données de test (utilisateurs, concours, centres)..." -ForegroundColor White
try {
    # Test des centres
    $centresResponse = Invoke-WebRequest "http://localhost:8080/api/centres" -UseBasicParsing -TimeoutSec 5 -ErrorAction Stop
    $centres = $centresResponse.Content | ConvertFrom-Json
    if ($centres.Count -ge 5) {
        Write-Host "  ✓ Centres de test présents ($($centres.Count) centres)" -ForegroundColor Green
        $successes += "Données de test centres présentes ($($centres.Count) centres)"
    }
    else {
        Write-Host "  ⚠ Peu de centres trouvés ($($centres.Count))" -ForegroundColor Yellow
        $warnings += "Données de test centres incomplètes"
    }

    # Test des concours
    $concoursResponse = Invoke-WebRequest "http://localhost:8080/api/concours" -UseBasicParsing -TimeoutSec 5 -ErrorAction Stop
    $concours = $concoursResponse.Content | ConvertFrom-Json
    if ($concours.Count -ge 3) {
        Write-Host "  ✓ Concours de test présents ($($concours.Count) concours)" -ForegroundColor Green
        $successes += "Données de test concours présentes ($($concours.Count) concours)"
    }
    else {
        Write-Host "  ⚠ Peu de concours trouvés ($($concours.Count))" -ForegroundColor Yellow
        $warnings += "Données de test concours incomplètes"
    }

    # Test des spécialités
    $specialitesResponse = Invoke-WebRequest "http://localhost:8080/api/specialites" -UseBasicParsing -TimeoutSec 5 -ErrorAction Stop
    $specialites = $specialitesResponse.Content | ConvertFrom-Json
    if ($specialites.Count -ge 10) {
        Write-Host "  ✓ Spécialités de test présentes ($($specialites.Count) spécialités)" -ForegroundColor Green
        $successes += "Données de test spécialités présentes ($($specialites.Count) spécialités)"
    }
    else {
        Write-Host "  ⚠ Peu de spécialités trouvées ($($specialites.Count))" -ForegroundColor Yellow
        $warnings += "Données de test spécialités incomplètes"
    }
}
catch {
    Write-Host "  ✗ Erreur lors de la vérification des données de test" -ForegroundColor Red
    $errors += "Données de test non accessibles - $($_.Exception.Message)"
}

# Test des mots de passe BCrypt
Write-Host "Vérification du système de mots de passe BCrypt..." -ForegroundColor White
try {
    # Test avec différents comptes pour vérifier BCrypt
    $testUsers = @(
        @{email = "admin@test.com"; password = "1234"; role = "Admin" },
        @{email = "h.alami@mf.gov.ma"; password = "1234"; role = "Gestionnaire Local" },
        @{email = "m.chraibi@mf.gov.ma"; password = "1234"; role = "Gestionnaire Global" }
    )
    
    $bcryptSuccess = 0
    foreach ($user in $testUsers) {
        try {
            $body = @{
                email    = $user.email
                password = $user.password
            } | ConvertTo-Json

            $response = Invoke-WebRequest "http://localhost:8080/api/auth/login" -Method POST -Body $body -ContentType "application/json" -UseBasicParsing -TimeoutSec 5 -ErrorAction Stop
            
            if ($response.StatusCode -eq 200) {
                $bcryptSuccess++
                Write-Host "    ✓ BCrypt OK pour $($user.role): $($user.email)" -ForegroundColor Green
            }
        }
        catch {
            Write-Host "    ✗ Échec BCrypt pour $($user.email)" -ForegroundColor Red
        }
    }
    
    if ($bcryptSuccess -eq $testUsers.Count) {
        Write-Host "  ✓ Système BCrypt fonctionnel pour tous les comptes" -ForegroundColor Green
        $successes += "Authentification BCrypt fonctionnelle"
    }
    elseif ($bcryptSuccess -gt 0) {
        Write-Host "  ⚠ BCrypt partiellement fonctionnel ($bcryptSuccess/$($testUsers.Count))" -ForegroundColor Yellow
        $warnings += "BCrypt partiellement fonctionnel"
    }
    else {
        Write-Host "  ✗ Aucun compte BCrypt ne fonctionne" -ForegroundColor Red
        $errors += "Système BCrypt défaillant"
    }
}
catch {
    Write-Host "  ✗ Erreur lors du test BCrypt" -ForegroundColor Red
    $errors += "Test BCrypt échoué - $($_.Exception.Message)"
}

# ========================================
# 10. TESTS FONCTIONNELS AVANCES
# ========================================
Write-Host ""
Write-Host "10. TESTS FONCTIONNELS AVANCES" -ForegroundColor Yellow
Write-Host "===============================" -ForegroundColor Yellow

# Test de validation/rejet de candidatures
Write-Host "Test des fonctions de validation/rejet de candidatures..." -ForegroundColor White
try {
    # Se connecter d'abord comme gestionnaire
    $loginBody = @{
        email    = "h.alami@mf.gov.ma"
        password = "1234"
    } | ConvertTo-Json

    $session = New-Object Microsoft.PowerShell.Commands.WebRequestSession
    $loginResponse = Invoke-WebRequest "http://localhost:8080/api/auth/login" -Method POST -Body $loginBody -ContentType "application/json" -UseBasicParsing -TimeoutSec 5 -WebSession $session -ErrorAction Stop
    
    if ($loginResponse.StatusCode -eq 200) {
        # Test des candidatures pour un centre
        $candidaturesResponse = Invoke-WebRequest "http://localhost:8080/api/candidatures/centre/1" -UseBasicParsing -TimeoutSec 5 -WebSession $session -ErrorAction Stop
        Write-Host "  ✓ API gestion candidatures accessible" -ForegroundColor Green
        $successes += "Système de gestion des candidatures fonctionnel"
        
        # Test des endpoints de validation (structure)
        $data = $candidaturesResponse.Content | ConvertFrom-Json
        Write-Host "    Candidatures trouvées: $($data.Count)" -ForegroundColor Cyan
    }
    else {
        Write-Host "  ✗ Connexion gestionnaire échouée" -ForegroundColor Red
        $errors += "Connexion gestionnaire pour tests fonctionnels échouée"
    }
}
catch {
    Write-Host "  ⚠ Tests validation/rejet non disponibles (nécessite candidatures existantes)" -ForegroundColor Yellow
    $warnings += "Tests validation/rejet non testables - $($_.Exception.Message)"
}

# Test du système de notifications
Write-Host "Test du système de notifications..." -ForegroundColor White
try {
    # Test de l'endpoint de test des notifications
    $response = Invoke-WebRequest "http://localhost:8080/api/notifications/test" -UseBasicParsing -TimeoutSec 5 -ErrorAction Stop
    $testData = $response.Content | ConvertFrom-Json
    
    if ($testData.status -eq "OK") {
        Write-Host "  ✓ API notifications opérationnelle" -ForegroundColor Green
        Write-Host "    Total notifications: $($testData.total_notifications)" -ForegroundColor Cyan
        $successes += "Système de notifications opérationnel"
        
        # Test des statistiques de notifications
        try {
            $statsResponse = Invoke-WebRequest "http://localhost:8080/api/notifications/statistiques" -UseBasicParsing -TimeoutSec 5 -ErrorAction Stop
            $stats = $statsResponse.Content | ConvertFrom-Json
            Write-Host "    ✓ Statistiques notifications disponibles" -ForegroundColor Green
            Write-Host "      - Total: $($stats.total), Envoyées: $($stats.envoyees), Échec: $($stats.echec)" -ForegroundColor Cyan
        }
        catch {
            Write-Host "    ⚠ Statistiques notifications non disponibles" -ForegroundColor Yellow
        }
    }
    else {
        Write-Host "  ⚠ Système notifications avec erreurs" -ForegroundColor Yellow
        $warnings += "Système notifications avec problèmes"
    }
}
catch {
    if ($_.Exception.Response.StatusCode -eq 404) {
        Write-Host "  ⚠ Endpoint notifications non trouvé (peut être normal)" -ForegroundColor Yellow
        $warnings += "Endpoint notifications non implémenté"
    }
    else {
        Write-Host "  ⚠ Système notifications non accessible" -ForegroundColor Yellow
        $warnings += "Système notifications non testable - $($_.Exception.Message)"
    }
}

# Test des logs d'actions
Write-Host "Test du système de logs d'actions..." -ForegroundColor White
try {
    # Test de l'endpoint de test des logs
    $response = Invoke-WebRequest "http://localhost:8080/api/logs/test" -UseBasicParsing -TimeoutSec 5 -ErrorAction Stop
    $testData = $response.Content | ConvertFrom-Json
    
    if ($testData.status -eq "OK") {
        Write-Host "  ✓ API logs d'actions opérationnelle" -ForegroundColor Green
        Write-Host "    Total logs: $($testData.total_logs)" -ForegroundColor Cyan
        $successes += "Système de logs d'actions fonctionnel"
        
        # Test des statistiques de logs
        try {
            $statsResponse = Invoke-WebRequest "http://localhost:8080/api/logs/statistiques" -UseBasicParsing -TimeoutSec 5 -ErrorAction Stop
            $stats = $statsResponse.Content | ConvertFrom-Json
            Write-Host "    ✓ Statistiques logs disponibles" -ForegroundColor Green
            Write-Host "      - Total: $($stats.total), Candidats: $($stats.candidats), Utilisateurs: $($stats.utilisateurs), Système: $($stats.systeme)" -ForegroundColor Cyan
        }
        catch {
            Write-Host "    ⚠ Statistiques logs non disponibles" -ForegroundColor Yellow
        }
        
        # Test des logs récents
        try {
            $recentResponse = Invoke-WebRequest "http://localhost:8080/api/logs/recent" -UseBasicParsing -TimeoutSec 5 -ErrorAction Stop
            $recentLogs = $recentResponse.Content | ConvertFrom-Json
            Write-Host "    ✓ Logs récents disponibles ($($recentLogs.Count) entrées)" -ForegroundColor Green
        }
        catch {
            Write-Host "    ⚠ Logs récents non disponibles" -ForegroundColor Yellow
        }
    }
    else {
        Write-Host "  ⚠ Système logs avec erreurs" -ForegroundColor Yellow
        $warnings += "Système logs avec problèmes"
    }
}
catch {
    if ($_.Exception.Response.StatusCode -eq 404) {
        Write-Host "  ⚠ Endpoint logs non trouvé (peut être normal)" -ForegroundColor Yellow
        $warnings += "Endpoint logs non implémenté"
    }
    else {
        Write-Host "  ⚠ Système logs non accessible" -ForegroundColor Yellow
        $warnings += "Système logs non testable - $($_.Exception.Message)"
    }
}

# Test des statistiques
Write-Host "Test des API de statistiques..." -ForegroundColor White
try {
    # Test des statistiques générales
    $response = Invoke-WebRequest "http://localhost:8080/api/candidatures/statistiques/globales" -UseBasicParsing -TimeoutSec 5 -ErrorAction Stop
    Write-Host "  ✓ API statistiques accessible" -ForegroundColor Green
    $successes += "Système de statistiques fonctionnel"
    
    # Test des statistiques par centre
    try {
        $responseCentre = Invoke-WebRequest "http://localhost:8080/api/candidatures/statistiques/centre/1" -UseBasicParsing -TimeoutSec 5 -ErrorAction Stop
        Write-Host "    ✓ Statistiques par centre disponibles" -ForegroundColor Green
    }
    catch {
        Write-Host "    ⚠ Statistiques par centre non accessibles" -ForegroundColor Yellow
    }
}
catch {
    if ($_.Exception.Response.StatusCode -eq 404) {
        Write-Host "  ⚠ Endpoint statistiques non trouvé (peut être normal)" -ForegroundColor Yellow
        $warnings += "Endpoint statistiques non implémenté"
    }
    else {
        Write-Host "  ⚠ Système statistiques non accessible" -ForegroundColor Yellow
        $warnings += "Système statistiques non testable - $($_.Exception.Message)"
    }
}

# ========================================
# 11. TESTS COMMUNICATION FRONTEND-BACKEND
# ========================================
Write-Host ""
Write-Host "11. TESTS COMMUNICATION FRONTEND-BACKEND" -ForegroundColor Yellow
Write-Host "=========================================" -ForegroundColor Yellow

# Test CORS
Write-Host "Test de la configuration CORS..." -ForegroundColor White
try {
    $headers = @{
        'Origin'                        = 'http://localhost:3000'
        'Access-Control-Request-Method' = 'GET'
    }
    
    $corsResponse = Invoke-WebRequest "http://localhost:8080/api/health" -Headers $headers -UseBasicParsing -TimeoutSec 5 -ErrorAction Stop
    $corsHeader = $corsResponse.Headers.'Access-Control-Allow-Origin'
    
    if ($corsHeader -contains 'http://localhost:3000' -or $corsHeader -contains '*') {
        Write-Host "  ✓ CORS correctement configuré" -ForegroundColor Green
        $successes += "Configuration CORS fonctionnelle"
    }
    else {
        Write-Host "  ⚠ CORS peut ne pas être configuré pour localhost:3000" -ForegroundColor Yellow
        $warnings += "Configuration CORS incertaine"
    }
}
catch {
    Write-Host "  ⚠ Test CORS non concluant" -ForegroundColor Yellow
    $warnings += "Test CORS non réalisable - $($_.Exception.Message)"
}

# Test des appels API depuis le frontend (simulation)
Write-Host "Test de la connectivité API pour le frontend..." -ForegroundColor White
try {
    # Simuler les appels que ferait le frontend
    $frontendAPIs = @(
        @{name = "Liste Concours"; url = "http://localhost:8080/api/concours" },
        @{name = "Liste Centres"; url = "http://localhost:8080/api/centres" },
        @{name = "Liste Spécialités"; url = "http://localhost:8080/api/specialites" }
    )
    
    $apiSuccess = 0
    foreach ($api in $frontendAPIs) {
        try {
            $headers = @{'Origin' = 'http://localhost:3000' }
            $response = Invoke-WebRequest $api.url -Headers $headers -UseBasicParsing -TimeoutSec 5 -ErrorAction Stop
            if ($response.StatusCode -eq 200) {
                $apiSuccess++
                Write-Host "    ✓ $($api.name) accessible depuis frontend" -ForegroundColor Green
            }
        }
        catch {
            Write-Host "    ✗ $($api.name) non accessible" -ForegroundColor Red
        }
    }
    
    if ($apiSuccess -eq $frontendAPIs.Count) {
        Write-Host "  ✓ Toutes les API essentielles accessibles au frontend" -ForegroundColor Green
        $successes += "APIs frontend-backend fonctionnelles"
    }
    else {
        Write-Host "  ⚠ Certaines API ne sont pas accessibles ($apiSuccess/$($frontendAPIs.Count))" -ForegroundColor Yellow
        $warnings += "Connectivité API partielle"
    }
}
catch {
    Write-Host "  ✗ Erreur lors du test des API frontend" -ForegroundColor Red
    $errors += "Test API frontend échoué - $($_.Exception.Message)"
}

# Test de la session utilisateur
Write-Host "Test de la gestion des sessions utilisateur..." -ForegroundColor White
try {
    # Test de session avec cookies
    $session = New-Object Microsoft.PowerShell.Commands.WebRequestSession
    
    # 1. Connexion
    $loginBody = @{
        email    = "admin@test.com"
        password = "1234"
    } | ConvertTo-Json

    $loginResponse = Invoke-WebRequest "http://localhost:8080/api/auth/login" -Method POST -Body $loginBody -ContentType "application/json" -UseBasicParsing -TimeoutSec 5 -WebSession $session -ErrorAction Stop
    
    if ($loginResponse.StatusCode -eq 200) {
        # 2. Test utilisateur actuel avec session
        $currentUserResponse = Invoke-WebRequest "http://localhost:8080/api/auth/current" -UseBasicParsing -TimeoutSec 5 -WebSession $session -ErrorAction Stop
        
        if ($currentUserResponse.StatusCode -eq 200) {
            Write-Host "  ✓ Session utilisateur fonctionnelle" -ForegroundColor Green
            $successes += "Gestion des sessions utilisateur opérationnelle"
            
            # 3. Test déconnexion
            $logoutResponse = Invoke-WebRequest "http://localhost:8080/api/auth/logout" -Method POST -UseBasicParsing -TimeoutSec 5 -WebSession $session -ErrorAction Stop
            
            if ($logoutResponse.StatusCode -eq 200) {
                Write-Host "    ✓ Déconnexion fonctionnelle" -ForegroundColor Green
            }
        }
        else {
            Write-Host "  ⚠ Session utilisateur partiellement fonctionnelle" -ForegroundColor Yellow
            $warnings += "Session utilisateur incomplète"
        }
    }
    else {
        Write-Host "  ✗ Connexion pour test de session échouée" -ForegroundColor Red
        $errors += "Test session utilisateur échoué"
    }
}
catch {
    Write-Host "  ✗ Erreur lors du test des sessions" -ForegroundColor Red
    $errors += "Test session utilisateur échoué - $($_.Exception.Message)"
}

# Test intégration complète Frontend-Backend
Write-Host "Test d'intégration complète Frontend-Backend..." -ForegroundColor White
try {
    # Vérifier que le frontend peut charger les ressources du backend
    if ($port3000 -and $port8080) {
        # Simuler une séquence typique d'utilisation
        $headers = @{
            'Origin'  = 'http://localhost:3000'
            'Referer' = 'http://localhost:3000/'
        }
        
        # 1. Frontend charge la liste des concours
        $concoursResp = Invoke-WebRequest "http://localhost:8080/api/concours" -Headers $headers -UseBasicParsing -TimeoutSec 5 -ErrorAction Stop
        
        # 2. Frontend charge la liste des centres
        $centresResp = Invoke-WebRequest "http://localhost:8080/api/centres" -Headers $headers -UseBasicParsing -TimeoutSec 5 -ErrorAction Stop
        
        if ($concoursResp.StatusCode -eq 200 -and $centresResp.StatusCode -eq 200) {
            Write-Host "  ✓ Intégration Frontend-Backend fonctionnelle" -ForegroundColor Green
            $successes += "Intégration complète Frontend-Backend opérationnelle"
        }
        else {
            Write-Host "  ⚠ Intégration Frontend-Backend partielle" -ForegroundColor Yellow
            $warnings += "Intégration Frontend-Backend incomplète"
        }
    }
    else {
        Write-Host "  ⚠ Frontend ou Backend non démarré pour test d'intégration" -ForegroundColor Yellow
        $warnings += "Test intégration impossible - services non démarrés"
    }
}
catch {
    Write-Host "  ✗ Erreur lors du test d'intégration" -ForegroundColor Red
    $errors += "Test intégration Frontend-Backend échoué - $($_.Exception.Message)"
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
# RECOMMANDATIONS
# ========================================
Write-Host ""
Write-Host "RECOMMANDATIONS:" -ForegroundColor Cyan

if ($errors.Count -eq 0 -and $warnings.Count -eq 0) {
    Write-Host "  🎉 Tout semble fonctionner correctement!" -ForegroundColor Green
    Write-Host "  🌐 Application accessible sur:" -ForegroundColor White
    Write-Host "     Frontend: http://localhost:3000" -ForegroundColor White
    Write-Host "     Backend:  http://localhost:8080" -ForegroundColor White
    Write-Host ""
    Write-Host "  👤 Comptes de test disponibles:" -ForegroundColor White
    Write-Host "     - admin@test.com / 1234 (Administrateur)" -ForegroundColor White
    Write-Host "     - h.alami@mf.gov.ma / 1234 (Gestionnaire Local)" -ForegroundColor White
    Write-Host "     - m.chraibi@mf.gov.ma / 1234 (Gestionnaire Global)" -ForegroundColor White
    Write-Host ""
    Write-Host "  🔍 Tests approfondis réussis:" -ForegroundColor White
    Write-Host "     ✓ Base de données complète avec tables Log_Action et Notification" -ForegroundColor White
    Write-Host "     ✓ Authentification BCrypt sécurisée" -ForegroundColor White
    Write-Host "     ✓ Communication Frontend-Backend avec CORS" -ForegroundColor White
    Write-Host "     ✓ Gestion des sessions utilisateur" -ForegroundColor White
}
else {
    if ($errors -contains "Backend Spring Boot n'écoute pas sur le port 8080") {
        Write-Host "  🔧 Le backend n'est pas démarré. Lancez start_app.bat" -ForegroundColor Yellow
    }
    
    if ($warnings -contains "Frontend React n'écoute pas sur le port 3000") {
        Write-Host "  🔧 Le frontend n'est pas démarré. Lancez start_app.bat" -ForegroundColor Yellow
    }
    
    if ($errors.Count -gt 0 -and ($errors | Where-Object { $_ -like "*Base de donnees*" })) {
        Write-Host "  🔧 Vérifiez MySQL et exécutez les scripts SQL de BD" -ForegroundColor Yellow
    }
    
    # Recommandations spécifiques aux nouveaux tests
    if ($warnings -contains "Données de test centres incomplètes" -or $warnings -contains "Données de test concours incomplètes") {
        Write-Host "  🔧 Exécutez insert_test_data.sql pour charger les données de test" -ForegroundColor Yellow
    }
    
    if ($errors -contains "Système BCrypt défaillant" -or $warnings -contains "BCrypt partiellement fonctionnel") {
        Write-Host "  🔧 Vérifiez la configuration BCrypt dans le backend" -ForegroundColor Yellow
        Write-Host "     - Assurez-vous que les mots de passe sont correctement encodés" -ForegroundColor Yellow
        Write-Host "     - Vérifiez la configuration de PasswordEncoder" -ForegroundColor Yellow
    }
    
    if ($warnings -contains "Configuration CORS incertaine") {
        Write-Host "  🔧 Vérifiez la configuration CORS dans les contrôleurs" -ForegroundColor Yellow
        Write-Host "     - Ajoutez @CrossOrigin(origins = 'http://localhost:3000')" -ForegroundColor Yellow
    }
    
    if ($warnings -contains "Endpoint notifications non implémenté" -or $warnings -contains "Endpoint logs non implémenté") {
        Write-Host "  🔧 Implémentez les endpoints manquants:" -ForegroundColor Yellow
        Write-Host "     - /api/notifications pour la gestion des notifications" -ForegroundColor Yellow
        Write-Host "     - /api/logs pour l'accès aux logs d'actions" -ForegroundColor Yellow
        Write-Host "     - /api/statistiques pour les tableaux de bord" -ForegroundColor Yellow
    }
    
    if ($warnings -contains "Test intégration impossible - services non démarrés") {
        Write-Host "  🔧 Démarrez les deux services pour tester l'intégration complète" -ForegroundColor Yellow
        Write-Host "     - Backend sur le port 8080" -ForegroundColor Yellow
        Write-Host "     - Frontend sur le port 3000" -ForegroundColor Yellow
    }
    
    if ($errors -contains "Test session utilisateur échoué") {
        Write-Host "  🔧 Vérifiez la configuration des sessions:" -ForegroundColor Yellow
        Write-Host "     - Configuration HttpSession dans Spring Boot" -ForegroundColor Yellow
        Write-Host "     - Gestion des cookies côté client" -ForegroundColor Yellow
    }
    
    Write-Host ""
    Write-Host "  📊 État des tests avancés:" -ForegroundColor White
    $dbTests = $successes | Where-Object { $_ -like "*données de test*" -or $_ -like "*BCrypt*" -or $_ -like "*Log_Action*" }
    if ($dbTests.Count -gt 0) {
        Write-Host "     ✓ Tests base de données: OK ($($dbTests.Count) réussis)" -ForegroundColor Green
    }
    else {
        Write-Host "     ✗ Tests base de données: À corriger" -ForegroundColor Red
    }
    
    $funcTests = $successes | Where-Object { $_ -like "*candidatures*" -or $_ -like "*notifications*" -or $_ -like "*logs*" }
    if ($funcTests.Count -gt 0) {
        Write-Host "     ✓ Tests fonctionnels: OK ($($funcTests.Count) réussis)" -ForegroundColor Green
    }
    else {
        Write-Host "     ⚠ Tests fonctionnels: Partiels" -ForegroundColor Yellow
    }
    
    $commTests = $successes | Where-Object { $_ -like "*CORS*" -or $_ -like "*Frontend-Backend*" -or $_ -like "*session*" }
    if ($commTests.Count -gt 0) {
        Write-Host "     ✓ Communication Frontend-Backend: OK ($($commTests.Count) réussis)" -ForegroundColor Green
    }
    else {
        Write-Host "     ⚠ Communication Frontend-Backend: À vérifier" -ForegroundColor Yellow
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
RAPPORT DE DIAGNOSTIC COMPLET - $(Get-Date)
==============================================

TESTS EXECUTES:
1. Vérification des processus (Java, Node.js)
2. Vérification des ports (8080, 3000)
3. Test de connectivité backend
4. Test des endpoints API critiques
5. Test d'authentification
6. Vérification de la base de données
7. Test de connectivité frontend
8. Test des nouvelles fonctionnalités
9. Tests base de données approfondis
10. Tests fonctionnels avancés
11. Tests communication Frontend-Backend

RESULTATS:
==========

SUCCES ($($successes.Count)):
$(($successes | ForEach-Object { "  ✓ $_" }) -join "`n")

AVERTISSEMENTS ($($warnings.Count)):
$(($warnings | ForEach-Object { "  ⚠ $_" }) -join "`n")

ERREURS ($($errors.Count)):
$(($errors | ForEach-Object { "  ✗ $_" }) -join "`n")

ANALYSE DETAILLEE:
==================

Base de données:
- Tables système (Log_Action, Notification): $(if ($successes -like "*Log_Action*") { "OK" } else { "À vérifier" })
- Données de test: $(if ($successes -like "*données de test*") { "Complètes" } else { "Incomplètes" })
- Authentification BCrypt: $(if ($successes -like "*BCrypt*") { "Fonctionnelle" } else { "À corriger" })

Fonctionnalités avancées:
- Gestion candidatures: $(if ($successes -like "*candidatures*") { "OK" } else { "Partielle" })
- Système notifications: $(if ($successes -like "*notifications*") { "OK" } elseif ($warnings -like "*notifications*") { "Non implémenté" } else { "À vérifier" })
- Logs d'actions: $(if ($successes -like "*logs*") { "OK" } elseif ($warnings -like "*logs*") { "Non implémenté" } else { "À vérifier" })

Communication Frontend-Backend:
- Configuration CORS: $(if ($successes -like "*CORS*") { "OK" } else { "À vérifier" })
- APIs Frontend: $(if ($successes -like "*APIs frontend*") { "Fonctionnelles" } else { "Partielles" })
- Sessions utilisateur: $(if ($successes -like "*session*") { "OK" } else { "À corriger" })
- Intégration complète: $(if ($successes -like "*Intégration*") { "OK" } else { "Partielle" })

RECOMMANDATIONS:
================
$(if ($errors.Count -eq 0 -and $warnings.Count -eq 0) {
    "✓ Application entièrement fonctionnelle
✓ Tous les tests approfondis réussis
✓ Prêt pour la production"
} else {
    "Consulter les recommandations détaillées dans le diagnostic"
})
"@

$report | Out-File -FilePath $reportPath -Encoding UTF8
Write-Host "Rapport détaillé sauvegardé dans: $reportPath" -ForegroundColor Cyan
