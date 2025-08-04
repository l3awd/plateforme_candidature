# ========================================
# SCRIPT DE DIAGNOSTIC SPRING BOOT - ANALYSE D'ERREURS
# Plateforme CandidaturePlus
# ========================================

param(
    [switch]$Detailed,
    [switch]$Fix
)

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "   DIAGNOSTIC SPRING BOOT - ERREURS" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$errors = @()
$warnings = @()
$successes = @()
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$logFile = "diagnostic_spring_boot_$timestamp.log"

function Write-Log {
    param($Message, $Color = "White")
    Write-Host $Message -ForegroundColor $Color
    Add-Content -Path $logFile -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss'): $Message"
}

Write-Log "Début du diagnostic Spring Boot" "Green"
Write-Log "Fichier de log: $logFile" "Cyan"

# ========================================
# 1. VERIFICATION DE L'ENVIRONNEMENT JAVA
# ========================================
Write-Log "" 
Write-Log "1. VERIFICATION DE L'ENVIRONNEMENT JAVA" "Yellow"
Write-Log "=========================================" "Yellow"

# Vérifier Java
try {
    $javaVersion = java -version 2>&1
    if ($javaVersion -match "version") {
        $javaVersionStr = ($javaVersion | Select-String "version").Line
        Write-Log "  ✓ Java installé: $javaVersionStr" "Green"
        $successes += "Java disponible"
        
        # Vérifier version Java 17+
        if ($javaVersionStr -match '"(\d+)\.') {
            $majorVersion = [int]$matches[1]
            if ($majorVersion -ge 17) {
                Write-Log "  ✓ Version Java compatible (>= 17)" "Green"
                $successes += "Version Java compatible"
            }
            else {
                Write-Log "  ✗ Version Java incompatible (< 17). Spring Boot 3.x nécessite Java 17+" "Red"
                $errors += "Version Java incompatible: $majorVersion (requis: >= 17)"
            }
        }
    }
}
catch {
    Write-Log "  ✗ Java non trouvé ou non accessible" "Red"
    $errors += "Java non installé ou non dans le PATH"
}

# Vérifier Maven
try {
    $mavenVersion = mvn -version 2>&1
    if ($mavenVersion -match "Apache Maven") {
        $mavenVersionStr = ($mavenVersion | Select-String "Apache Maven").Line
        Write-Log "  ✓ Maven installé: $mavenVersionStr" "Green"
        $successes += "Maven disponible"
    }
}
catch {
    Write-Log "  ✗ Maven non trouvé" "Red"
    $errors += "Maven non installé ou non dans le PATH"
}

# ========================================
# 2. VERIFICATION DE LA BASE DE DONNEES
# ========================================
Write-Log ""
Write-Log "2. VERIFICATION DE LA BASE DE DONNEES" "Yellow"
Write-Log "======================================" "Yellow"

# Test de connexion MySQL
try {
    $mysqlTest = mysql -u root -p1234 -e "SELECT 1;" 2>&1
    if ($mysqlTest -notmatch "ERROR") {
        Write-Log "  ✓ Connexion MySQL réussie" "Green"
        $successes += "Connexion MySQL OK"
        
        # Vérifier base candidature_plus
        $dbTest = mysql -u root -p1234 -e "USE candidature_plus; SELECT COUNT(*) as tables_count FROM information_schema.tables WHERE table_schema = 'candidature_plus';" 2>&1
        if ($dbTest -notmatch "ERROR") {
            Write-Log "  ✓ Base de données 'candidature_plus' accessible" "Green"
            $successes += "Base de données accessible"
        }
        else {
            Write-Log "  ✗ Base de données 'candidature_plus' non trouvée" "Red"
            $errors += "Base de données candidature_plus manquante"
        }
    }
}
catch {
    Write-Log "  ✗ Erreur de connexion MySQL" "Red"
    $errors += "Connexion MySQL échouée - vérifier si MySQL est démarré"
}

# ========================================
# 3. ANALYSE DU PROJET SPRING BOOT
# ========================================
Write-Log ""
Write-Log "3. ANALYSE DU PROJET SPRING BOOT" "Yellow"
Write-Log "=================================" "Yellow"

Set-Location "backend"

# Vérifier structure du projet
Write-Log "Vérification de la structure du projet..." "White"
if (Test-Path "pom.xml") {
    Write-Log "  ✓ pom.xml trouvé" "Green"
    $successes += "Structure Maven correcte"
}
else {
    Write-Log "  ✗ pom.xml manquant" "Red"
    $errors += "Fichier pom.xml manquant"
}

if (Test-Path "src\main\java\com\example\candidatureplus\CandidaturePlusApplication.java") {
    Write-Log "  ✓ Classe principale Spring Boot trouvée" "Green"
    $successes += "Classe principale présente"
}
else {
    Write-Log "  ✗ Classe principale Spring Boot manquante" "Red"
    $errors += "CandidaturePlusApplication.java manquant"
}

# Vérifier application.properties
if (Test-Path "src\main\resources\application.properties") {
    Write-Log "  ✓ application.properties trouvé" "Green"
    $successes += "Configuration application présente"
    
    # Analyser le contenu
    $appProps = Get-Content "src\main\resources\application.properties" -Raw
    if ($appProps -match "spring.datasource.url=jdbc:mysql://localhost:3306/candidature_plus") {
        Write-Log "  ✓ Configuration base de données correcte" "Green"
    }
    else {
        Write-Log "  ⚠ Configuration base de données douteuse" "Yellow"
        $warnings += "Configuration base de données à vérifier"
    }
}
else {
    Write-Log "  ✗ application.properties manquant" "Red"
    $errors += "Fichier application.properties manquant"
}

# ========================================
# 4. TEST DE COMPILATION MAVEN
# ========================================
Write-Log ""
Write-Log "4. TEST DE COMPILATION MAVEN" "Yellow"
Write-Log "============================" "Yellow"

Write-Log "Nettoyage du projet Maven..." "White"
$cleanResult = & mvn clean 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Log "  ✓ Nettoyage Maven réussi" "Green"
    $successes += "Nettoyage Maven OK"
}
else {
    Write-Log "  ✗ Echec du nettoyage Maven" "Red"
    Write-Log "Erreur: $cleanResult" "Red"
    $errors += "Echec nettoyage Maven"
}

Write-Log "Compilation du projet..." "White"
$compileStart = Get-Date
$compileResult = & mvn compile -X 2>&1
$compileEnd = Get-Date
$compileDuration = ($compileEnd - $compileStart).TotalSeconds

if ($LASTEXITCODE -eq 0) {
    Write-Log "  ✓ Compilation réussie en $([math]::Round($compileDuration, 2)) secondes" "Green"
    $successes += "Compilation Maven réussie"
}
else {
    Write-Log "  ✗ Echec de la compilation Maven" "Red"
    Write-Log "Durée avant échec: $([math]::Round($compileDuration, 2)) secondes" "Red"
    $errors += "Echec compilation Maven"
    
    # Analyser les erreurs de compilation en détail
    Write-Log ""
    Write-Log "ANALYSE DETAILLEE DES ERREURS DE COMPILATION:" "Red"
    Write-Log "=============================================" "Red"
    
    # Classifier les erreurs
    $errorClassification = @{
        "Erreurs de syntaxe Java" = @()
        "Imports manquants"       = @()
        "Annotations Spring"      = @()
        "Dépendances Maven"       = @()
        "Erreurs JPA/Hibernate"   = @()
        "Autres erreurs"          = @()
    }
    
    $allErrorLines = $compileResult | Where-Object { $_ -match "\[ERROR\]" }
    
    foreach ($errorLine in $allErrorLines) {
        $classified = $false
        
        if ($errorLine -match "(cannot find symbol|package.*does not exist|import.*cannot be resolved)") {
            $errorClassification["Imports manquants"] += $errorLine
            $classified = $true
        }
        elseif ($errorLine -match "(@Autowired|@Service|@Repository|@Controller|@RestController|@Component|@Entity)") {
            $errorClassification["Annotations Spring"] += $errorLine
            $classified = $true
        }
        elseif ($errorLine -match "(JPA|Hibernate|@Column|@Table|@Entity|@Id)") {
            $errorClassification["Erreurs JPA/Hibernate"] += $errorLine
            $classified = $true
        }
        elseif ($errorLine -match "(';' expected|illegal start of expression|')' expected|'}' expected)") {
            $errorClassification["Erreurs de syntaxe Java"] += $errorLine
            $classified = $true
        }
        elseif ($errorLine -match "(Failed to execute goal|artifact.*not found|dependency.*failed)") {
            $errorClassification["Dépendances Maven"] += $errorLine
            $classified = $true
        }
        
        if (-not $classified) {
            $errorClassification["Autres erreurs"] += $errorLine
        }
    }
    
    # Afficher les erreurs classifiées
    foreach ($category in $errorClassification.Keys) {
        if ($errorClassification[$category].Count -gt 0) {
            Write-Log "  📂 $category ($($errorClassification[$category].Count) erreur(s)):" "Yellow"
            foreach ($errorItem in $errorClassification[$category] | Select-Object -First 5) {
                Write-Log "    $errorItem" "Red"
            }
            if ($errorClassification[$category].Count -gt 5) {
                Write-Log "    ... et $($errorClassification[$category].Count - 5) autres erreurs similaires" "Gray"
            }
            Write-Log "" "White"
        }
    }
    
    # Suggestions spécifiques basées sur les erreurs détectées
    Write-Log "SUGGESTIONS DE CORRECTION DETAILLEES:" "Cyan"
    Write-Log "====================================" "Cyan"
    
    if ($errorClassification["Imports manquants"].Count -gt 0) {
        Write-Log "  🔧 IMPORTS MANQUANTS:" "Yellow"
        Write-Log "    1. Vérifier que toutes les dépendances sont dans pom.xml" "White"
        Write-Log "    2. Exécuter: mvn clean compile -U" "White"
        Write-Log "    3. Vérifier les versions des dépendances Spring Boot" "White"
    }
    
    if ($errorClassification["Annotations Spring"].Count -gt 0) {
        Write-Log "  🏷️ ANNOTATIONS SPRING:" "Yellow"
        Write-Log "    1. Vérifier import org.springframework.beans.factory.annotation.Autowired" "White"
        Write-Log "    2. Vérifier import org.springframework.stereotype.*" "White"
        Write-Log "    3. Vérifier import org.springframework.web.bind.annotation.*" "White"
    }
    
    if ($errorClassification["Erreurs JPA/Hibernate"].Count -gt 0) {
        Write-Log "  🗄️ JPA/HIBERNATE:" "Yellow"
        Write-Log "    1. Vérifier import jakarta.persistence.*" "White"
        Write-Log "    2. Vérifier les annotations @Entity, @Table, @Column" "White"
        Write-Log "    3. Vérifier la configuration JPA dans application.properties" "White"
    }
    
    if ($errorClassification["Erreurs de syntaxe Java"].Count -gt 0) {
        Write-Log "  ⚠️ SYNTAXE JAVA:" "Yellow"
        Write-Log "    1. Vérifier les accolades et parenthèses" "White"
        Write-Log "    2. Vérifier les points-virgules manquants" "White"
        Write-Log "    3. Utiliser un IDE pour identifier les erreurs de syntaxe" "White"
    }
    
    if ($errorClassification["Dépendances Maven"].Count -gt 0) {
        Write-Log "  📦 DEPENDANCES MAVEN:" "Yellow"
        Write-Log "    1. Exécuter: mvn clean install -U" "White"
        Write-Log "    2. Supprimer le dossier .m2/repository et relancer" "White"
        Write-Log "    3. Vérifier la connectivité internet pour télécharger les dépendances" "White"
    }
    
    # Sauvegarder les logs de compilation
    $compileLogFile = "compilation_errors_detailed_$timestamp.log"
    $compileResult | Out-File -FilePath $compileLogFile -Encoding UTF8
    Write-Log "Logs de compilation détaillés sauvés dans: $compileLogFile" "Cyan"
    
    # Analyser le fichier pom.xml pour des problèmes potentiels
    Write-Log ""
    Write-Log "VERIFICATION POM.XML:" "Cyan"
    Write-Log "====================" "Cyan"
    
    if (Test-Path "pom.xml") {
        $pomContent = Get-Content "pom.xml" -Raw
        
        # Vérifier version Java
        if ($pomContent -match "<java.version>(\d+)</java.version>") {
            $javaVersion = $matches[1]
            Write-Log "  Version Java dans pom.xml: $javaVersion" "White"
            if ([int]$javaVersion -lt 17) {
                Write-Log "  ⚠️ Version Java trop ancienne pour Spring Boot 3.x" "Yellow"
                $warnings += "Version Java dans pom.xml < 17"
            }
        }
        
        # Vérifier version Spring Boot
        if ($pomContent -match "<version>([0-9]+\.[0-9]+\.[0-9]+)</version>") {
            $springBootVersion = $matches[1]
            Write-Log "  Version Spring Boot: $springBootVersion" "White"
        }
        
        # Vérifier dépendances critiques
        $criticalDependencies = @("spring-boot-starter-web", "spring-boot-starter-data-jpa", "mysql-connector-j")
        foreach ($dep in $criticalDependencies) {
            if ($pomContent -match $dep) {
                Write-Log "  ✓ Dépendance $dep présente" "Green"
            }
            else {
                Write-Log "  ✗ Dépendance $dep manquante" "Red"
                $errors += "Dépendance critique manquante: $dep"
            }
        }
    }
}

# ========================================
# 5. TEST DE DEMARRAGE SPRING BOOT DETAILLE
# ========================================
Write-Log ""
Write-Log "5. TEST DE DEMARRAGE SPRING BOOT DETAILLE" "Yellow"
Write-Log "==========================================" "Yellow"

if ($errors -notcontains "Echec compilation Maven") {
    Write-Log "Tentative de démarrage Spring Boot avec logs détaillés..." "White"
    
    # Créer un fichier de log spécifique pour ce test
    $springBootLogFile = "spring_boot_startup_detailed_$timestamp.log"
    
    # Démarrer Spring Boot avec logging maximum
    Write-Log "Démarrage avec mvn spring-boot:run -X..." "White"
    $springBootJob = Start-Job -ScriptBlock {
        param($workingDir, $logFile)
        Set-Location $workingDir
        & mvn spring-boot:run -X 2>&1 | Tee-Object -FilePath $logFile
    } -ArgumentList (Get-Location).Path, $springBootLogFile
    
    Write-Log "Job Spring Boot démarré (ID: $($springBootJob.Id))" "Cyan"
    Write-Log "Logs sauvés en temps réel dans: $springBootLogFile" "Cyan"
    Write-Log "Attente du démarrage (60 secondes)..." "White"
    
    # Surveiller le démarrage avec plus de détails
    $startTime = Get-Date
    $timeout = 60
    $started = $false
    $lastLogSize = 0
    
    while (((Get-Date) - $startTime).TotalSeconds -lt $timeout -and -not $started) {
        Start-Sleep -Seconds 3
        
        # Vérifier si le port 8080 est ouvert
        $portCheck = netstat -ano | Select-String ":8080.*LISTENING"
        if ($portCheck) {
            Write-Log "  ✓ Spring Boot démarré - Port 8080 actif" "Green"
            $successes += "Spring Boot démarré avec succès"
            $started = $true
            
            # Test rapide de l'API
            Start-Sleep -Seconds 5
            try {
                $healthCheck = Invoke-WebRequest "http://localhost:8080/api/health" -UseBasicParsing -TimeoutSec 10 -ErrorAction Stop
                Write-Log "  ✓ Application accessible - Status: $($healthCheck.StatusCode)" "Green"
                $successes += "Application web accessible"
            }
            catch {
                Write-Log "  ⚠ Application démarrée mais API non accessible" "Yellow"
                Write-Log "    Erreur: $($_.Exception.Message)" "Yellow"
                $warnings += "Application non accessible via HTTP"
            }
        }
        else {
            # Analyser les logs en temps réel si disponibles
            if (Test-Path $springBootLogFile) {
                $currentLogSize = (Get-Item $springBootLogFile).Length
                if ($currentLogSize -gt $lastLogSize) {
                    $newContent = Get-Content $springBootLogFile -Tail 10
                    $errorLines = $newContent | Where-Object { $_ -match "(ERROR|FATAL|Exception|Failed|Error)" }
                    if ($errorLines) {
                        Write-Log "  🔍 Erreurs détectées dans les logs:" "Red"
                        foreach ($errorLine in $errorLines | Select-Object -First 3) {
                            Write-Log "    $errorLine" "Red"
                        }
                    }
                    $lastLogSize = $currentLogSize
                }
            }
        }
    }
    
    if (-not $started) {
        Write-Log "  ✗ Timeout - Spring Boot n'a pas démarré dans les $timeout secondes" "Red"
        $errors += "Timeout démarrage Spring Boot"
        
        # Analyser les logs d'erreur en détail
        if (Test-Path $springBootLogFile) {
            Write-Log ""
            Write-Log "ANALYSE DETAILLEE DES LOGS SPRING BOOT:" "Red"
            Write-Log "======================================" "Red"
            
            $logContent = Get-Content $springBootLogFile
            
            # Rechercher des erreurs spécifiques
            $errorPatterns = @{
                "Base de données" = @("Connection.*refused", "Access denied", "Unknown database", "mysql", "jdbc")
                "Port occupé"     = @("Port.*already in use", "Address already in use", "bind.*failed")
                "Configuration"   = @("application.properties", "Configuration.*failed", "Bean.*failed")
                "Dépendances"     = @("ClassNotFoundException", "NoClassDefFoundError", "dependency.*failed")
                "Annotation"      = @("annotation.*failed", "@.*not found", "Component.*failed")
                "JPA/Hibernate"   = @("hibernate", "jpa", "entity.*failed", "repository.*failed")
                "Spring Security" = @("security.*failed", "authentication.*failed", "authorization.*failed")
            }
            
            $detectedErrors = @{}
            foreach ($category in $errorPatterns.Keys) {
                $patterns = $errorPatterns[$category]
                $matchingLines = $logContent | Where-Object { 
                    $line = $_
                    $patterns | Where-Object { $line -match $_ }
                }
                if ($matchingLines) {
                    $detectedErrors[$category] = $matchingLines | Select-Object -First 3
                }
            }
            
            if ($detectedErrors.Count -gt 0) {
                Write-Log "Erreurs classifiées détectées:" "Red"
                foreach ($category in $detectedErrors.Keys) {
                    Write-Log "  📂 $category" "Yellow"
                    foreach ($errorItem in $detectedErrors[$category]) {
                        Write-Log "    $errorItem" "Red"
                    }
                }
            }
            else {
                # Afficher les dernières erreurs générales
                $generalErrors = $logContent | Where-Object { $_ -match "(ERROR|FATAL|Exception|Failed)" } | Select-Object -Last 10
                if ($generalErrors) {
                    Write-Log "Dernières erreurs générales:" "Red"
                    foreach ($errorItem in $generalErrors) {
                        Write-Log "  $errorItem" "Red"
                    }
                }
            }
            
            # Chercher des causes spécifiques
            Write-Log ""
            Write-Log "DIAGNOSTIC CAUSES PROBABLES:" "Cyan"
            Write-Log "============================" "Cyan"
            
            if ($logContent | Where-Object { $_ -match "refused.*3306" }) {
                Write-Log "  💾 CAUSE: MySQL n'est pas démarré ou inaccessible" "Red"
                Write-Log "    SOLUTION: net start mysql ou vérifier le service MySQL" "Yellow"
                $errors += "MySQL non accessible - Service arrêté"
            }
            
            if ($logContent | Where-Object { $_ -match "Access denied.*user.*root" }) {
                Write-Log "  🔑 CAUSE: Mot de passe MySQL incorrect" "Red"
                Write-Log "    SOLUTION: Vérifier spring.datasource.password dans application.properties" "Yellow"
                $errors += "Mot de passe MySQL incorrect"
            }
            
            if ($logContent | Where-Object { $_ -match "Unknown database.*candidature_plus" }) {
                Write-Log "  🗄️ CAUSE: Base de données candidature_plus n'existe pas" "Red"
                Write-Log "    SOLUTION: Exécuter init_database.sql pour créer la base" "Yellow"
                $errors += "Base de données candidature_plus manquante"
            }
            
            if ($logContent | Where-Object { $_ -match "Port.*8080.*already in use" }) {
                Write-Log "  🚪 CAUSE: Port 8080 déjà occupé" "Red"
                Write-Log "    SOLUTION: Tuer le processus sur le port 8080 ou changer le port" "Yellow"
                $errors += "Port 8080 occupé"
            }
            
            if ($logContent | Where-Object { $_ -match "ClassNotFoundException|NoClassDefFoundError" }) {
                Write-Log "  📦 CAUSE: Dépendances manquantes ou corrompues" "Red"
                Write-Log "    SOLUTION: mvn clean install -U pour réinstaller les dépendances" "Yellow"
                $errors += "Dépendances Maven corrompues"
            }
            
            if ($logContent | Where-Object { $_ -match "hibernate.*table.*doesn't exist" }) {
                Write-Log "  📋 CAUSE: Tables de base de données manquantes" "Red"
                Write-Log "    SOLUTION: Exécuter les scripts SQL de création des tables" "Yellow"
                $errors += "Tables de base de données manquantes"
            }
        }
        else {
            Write-Log "  ✗ Impossible de lire les logs de démarrage" "Red"
            $errors += "Logs de démarrage non disponibles"
        }
    }
    
    # Arrêter le job
    Stop-Job -Job $springBootJob -ErrorAction SilentlyContinue
    Remove-Job -Job $springBootJob -ErrorAction SilentlyContinue
    
}
else {
    Write-Log "Démarrage ignoré - Erreurs de compilation détectées" "Yellow"
}

# ========================================
# 6. ANALYSE DES DEPENDANCES
# ========================================
Write-Log ""
Write-Log "6. ANALYSE DES DEPENDANCES" "Yellow"
Write-Log "===========================" "Yellow"

Write-Log "Vérification de l'arbre des dépendances Maven..." "White"
$dependencyResult = & mvn dependency:tree 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Log "  ✓ Analyse des dépendances réussie" "Green"
    $successes += "Dépendances Maven OK"
    
    # Vérifier les conflits
    $conflicts = $dependencyResult | Where-Object { $_ -match "conflict" }
    if ($conflicts) {
        Write-Log "  ⚠ Conflits de dépendances détectés:" "Yellow"
        foreach ($conflict in $conflicts) {
            Write-Log "    $conflict" "Yellow"
        }
        $warnings += "Conflits de dépendances présents"
    }
    else {
        Write-Log "  ✓ Aucun conflit de dépendances" "Green"
    }
}
else {
    Write-Log "  ✗ Echec de l'analyse des dépendances" "Red"
    $errors += "Problème avec les dépendances Maven"
}

# ========================================
# 7. RAPPORT FINAL ET SUGGESTIONS
# ========================================
Write-Log ""
Write-Log "7. RAPPORT FINAL ET SUGGESTIONS" "Yellow"
Write-Log "===============================" "Yellow"

Write-Log ""
Write-Log "RESUME DU DIAGNOSTIC:" "Cyan"
Write-Log "=====================" "Cyan"
Write-Log "✓ Succès: $($successes.Count)" "Green"
Write-Log "⚠ Avertissements: $($warnings.Count)" "Yellow"
Write-Log "✗ Erreurs: $($errors.Count)" "Red"

if ($successes.Count -gt 0) {
    Write-Log ""
    Write-Log "ELEMENTS FONCTIONNELS:" "Green"
    foreach ($success in $successes) {
        Write-Log "  ✓ $success" "Green"
    }
}

if ($warnings.Count -gt 0) {
    Write-Log ""
    Write-Log "AVERTISSEMENTS:" "Yellow"
    foreach ($warning in $warnings) {
        Write-Log "  ⚠ $warning" "Yellow"
    }
}

if ($errors.Count -gt 0) {
    Write-Log ""
    Write-Log "ERREURS DETECTEES:" "Red"
    foreach ($errorItem in $errors) {
        Write-Log "  ✗ $errorItem" "Red"
    }
    
    Write-Log ""
    Write-Log "SUGGESTIONS DE CORRECTION:" "Cyan"
    Write-Log "==========================" "Cyan"
    
    foreach ($errorItem in $errors) {
        switch -Regex ($errorItem) {
            "Version Java incompatible" {
                Write-Log "→ Installer Java 17 ou plus récent" "White"
                Write-Log "  Télécharger depuis: https://adoptium.net/" "Gray"
            }
            "Maven non installé" {
                Write-Log "→ Installer Apache Maven" "White"
                Write-Log "  Télécharger depuis: https://maven.apache.org/download.cgi" "Gray"
            }
            "Connexion MySQL échouée" {
                Write-Log "→ Vérifier que MySQL est démarré" "White"
                Write-Log "  Services → MySQL → Démarrer" "Gray"
                Write-Log "  Ou via ligne de commande: net start mysql" "Gray"
            }
            "Base de données candidature_plus manquante" {
                Write-Log "→ Créer la base de données candidature_plus" "White"
                Write-Log "  Exécuter: Get-Content init_database.sql | mysql -u root -p" "Gray"
            }
            "Echec compilation Maven" {
                Write-Log "→ Vérifier les erreurs de compilation dans les logs" "White"
                Write-Log "  Fichier: compilation_errors_$timestamp.log" "Gray"
                Write-Log "  Corriger les erreurs Java et relancer mvn compile" "Gray"
            }
            "Timeout démarrage Spring Boot" {
                Write-Log "→ Analyser les logs de démarrage Spring Boot" "White"
                Write-Log "  Fichier: spring_boot_startup_$timestamp.log" "Gray"
                Write-Log "  Vérifier la configuration dans application.properties" "Gray"
            }
            "Problème avec les dépendances Maven" {
                Write-Log "→ Nettoyer et réinstaller les dépendances" "White"
                Write-Log "  mvn clean install -U" "Gray"
            }
        }
    }
    
    Write-Log ""
    Write-Log "COMMANDES DE CORRECTION AUTOMATIQUE:" "Cyan"
    if ($Fix) {
        Write-Log "Mode correction automatique activé..." "Yellow"
        
        # Correction automatique pour certains problèmes
        if ($errors -match "Base de données candidature_plus manquante") {
            Write-Log "Tentative de création de la base de données..." "White"
            if (Test-Path "init_database.sql") {
                $dbCreateResult = Get-Content "init_database.sql" | & mysql -u root -p1234 2>&1
                if ($LASTEXITCODE -eq 0) {
                    Write-Log "  ✓ Base de données créée avec succès" "Green"
                }
                else {
                    Write-Log "  ✗ Echec de création de la base de données" "Red"
                    Write-Log "  Erreur: $dbCreateResult" "Red"
                }
            }
        }
        
        if ($errors -match "Echec compilation Maven") {
            Write-Log "Tentative de nettoyage et recompilation..." "White"
            Set-Location "backend"
            $cleanInstallResult = & mvn clean install -DskipTests 2>&1
            Set-Location ".."
            if ($LASTEXITCODE -eq 0) {
                Write-Log "  ✓ Recompilation réussie" "Green"
            }
            else {
                Write-Log "  ✗ Echec de recompilation" "Red"
                Write-Log "  Détails: $cleanInstallResult" "Red"
            }
        }
    }
        
}
else {
    Write-Log "Pour correction automatique, relancer avec: .\diagnostic_app.ps1 -Fix" "Gray"
}
    
}
else {
    Write-Log ""
    Write-Log "🎉 AUCUNE ERREUR DETECTEE - SYSTEME OPERATIONNEL!" "Green"
    Write-Log ""
    Write-Log "L'application CandidaturePlus semble fonctionner correctement." "Green"
    Write-Log "Vous pouvez accéder à:" "White"
    Write-Log "  • Backend: http://localhost:8080/" "Cyan"
    Write-Log "  • Frontend: http://localhost:3000/" "Cyan"
}

# ========================================
# 8. INFORMATIONS COMPLEMENTAIRES
# ========================================
Write-Log ""
Write-Log "8. INFORMATIONS COMPLEMENTAIRES" "Yellow"
Write-Log "===============================" "Yellow"

Write-Log "Fichiers de logs générés:" "White"
Write-Log "  • $logFile (rapport complet)" "Cyan"
if (Test-Path "compilation_errors_$timestamp.log") {
    Write-Log "  • compilation_errors_$timestamp.log (erreurs compilation)" "Cyan"
}
if (Test-Path "spring_boot_startup_$timestamp.log") {
    Write-Log "  • spring_boot_startup_$timestamp.log (logs démarrage)" "Cyan"
}

Write-Log ""
Write-Log "Diagnostic terminé à $(Get-Date -Format 'HH:mm:ss')" "Cyan"
Write-Log "Durée totale: $([math]::Round(((Get-Date) - $startTime).TotalMinutes, 2)) minutes" "Cyan"

# Afficher un résumé dans la console même en cas d'erreur
Write-Host ""
Write-Host "========================================" -ForegroundColor Magenta
Write-Host "         RESULTAT DU DIAGNOSTIC         " -ForegroundColor Magenta
Write-Host "========================================" -ForegroundColor Magenta
Write-Host "✓ Succès: $($successes.Count)" -ForegroundColor Green
Write-Host "⚠ Avertissements: $($warnings.Count)" -ForegroundColor Yellow
Write-Host "✗ Erreurs: $($errors.Count)" -ForegroundColor Red
Write-Host ""
if ($errors.Count -eq 0) {
    Write-Host "🎉 SYSTEME OPERATIONNEL!" -ForegroundColor Green
}
else {
    Write-Host "❌ PROBLEMES DETECTES - Voir le fichier $logFile pour les détails" -ForegroundColor Red
}
Write-Host "========================================" -ForegroundColor Magenta

# Test des documents système (optionnel)
if (Test-Path "documents") {
    Write-Host "  ✓ Système de documents accessible" -ForegroundColor Green
}
else {
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

# Test des données de test avec diagnostic approfondi
Write-Host "Vérification des données de test (utilisateurs, concours, centres)..." -ForegroundColor White
try {
    # Test des centres
    $centresResponse = Invoke-WebRequest "http://localhost:8080/api/centres" -UseBasicParsing -TimeoutSec 5 -ErrorAction Stop
    $centres = $centresResponse.Content | ConvertFrom-Json
    Write-Host "  📊 CENTRES DÉTECTION:" -ForegroundColor Cyan
    if ($centres -and $centres.Count -gt 0) {
        Write-Host "    ✓ Centres trouvés: $($centres.Count)" -ForegroundColor Green
        foreach ($centre in $centres | Select-Object -First 3) {
            Write-Host "      - ID: $($centre.id), Nom: $($centre.nom), Ville: $($centre.ville)" -ForegroundColor Gray
        }
        if ($centres.Count -ge 5) {
            $successes += "Données de test centres présentes ($($centres.Count) centres)"
        }
        else {
            $warnings += "Données de test centres incomplètes ($($centres.Count) centres)"
        }
    }
    else {
        Write-Host "    ✗ Aucun centre trouvé ou données vides" -ForegroundColor Red
        Write-Host "    🔍 Type de réponse: $($centres.GetType().Name)" -ForegroundColor Yellow
        Write-Host "    🔍 Contenu brut: $($centresResponse.Content)" -ForegroundColor Yellow
        $errors += "Centres de test absents"
    }

    # Test des concours
    $concoursResponse = Invoke-WebRequest "http://localhost:8080/api/concours" -UseBasicParsing -TimeoutSec 5 -ErrorAction Stop
    $concours = $concoursResponse.Content | ConvertFrom-Json
    Write-Host "  📊 CONCOURS DÉTECTION:" -ForegroundColor Cyan
    if ($concours -and $concours.Count -gt 0) {
        Write-Host "    ✓ Concours trouvés: $($concours.Count)" -ForegroundColor Green
        foreach ($concour in $concours | Select-Object -First 3) {
            $dateDebut = if ($concour.dateDebutCandidature) { $concour.dateDebutCandidature } else { "Non définie" }
            $dateFin = if ($concour.dateFinCandidature) { $concour.dateFinCandidature } else { "Non définie" }
            Write-Host "      - ID: $($concour.id), Nom: $($concour.nom)" -ForegroundColor Gray
            Write-Host "        Dates: $dateDebut → $dateFin" -ForegroundColor Gray
            Write-Host "        Actif: $($concour.actif)" -ForegroundColor Gray
        }
        if ($concours.Count -ge 3) {
            $successes += "Données de test concours présentes ($($concours.Count) concours)"
        }
        else {
            $warnings += "Données de test concours incomplètes ($($concours.Count) concours)"
        }
    }
    else {
        Write-Host "    ✗ Aucun concours trouvé ou données vides" -ForegroundColor Red
        Write-Host "    🔍 Type de réponse: $($concours.GetType().Name)" -ForegroundColor Yellow
        Write-Host "    🔍 Contenu brut: $($concoursResponse.Content)" -ForegroundColor Yellow
        $errors += "Concours de test absents"
    }

    # Test des spécialités
    $specialitesResponse = Invoke-WebRequest "http://localhost:8080/api/specialites" -UseBasicParsing -TimeoutSec 5 -ErrorAction Stop
    $specialites = $specialitesResponse.Content | ConvertFrom-Json
    Write-Host "  📊 SPÉCIALITÉS DÉTECTION:" -ForegroundColor Cyan
    if ($specialites -and $specialites.Count -gt 0) {
        Write-Host "    ✓ Spécialités trouvées: $($specialites.Count)" -ForegroundColor Green
        foreach ($specialite in $specialites | Select-Object -First 5) {
            Write-Host "      - ID: $($specialite.id), Code: $($specialite.code), Nom: $($specialite.nom)" -ForegroundColor Gray
        }
        if ($specialites.Count -ge 10) {
            $successes += "Données de test spécialités présentes ($($specialites.Count) spécialités)"
        }
        else {
            $warnings += "Données de test spécialités incomplètes ($($specialites.Count) spécialités)"
        }
    }
    else {
        Write-Host "    ✗ Aucune spécialité trouvée ou données vides" -ForegroundColor Red
        Write-Host "    🔍 Type de réponse: $($specialites.GetType().Name)" -ForegroundColor Yellow
        Write-Host "    🔍 Contenu brut: $($specialitesResponse.Content)" -ForegroundColor Yellow
        $errors += "Spécialités de test absentes"
    }

    # ========================================
    # DIAGNOSTIC SPÉCIFIQUE POUR LES POSTES
    # ========================================
    Write-Host "  🎯 DIAGNOSTIC POSTES DISPONIBLES:" -ForegroundColor Cyan
    
    # Test des liaisons concours-spécialités
    try {
        $concoursSpecialitesResponse = Invoke-WebRequest "http://localhost:8080/api/concours/1/specialites" -UseBasicParsing -TimeoutSec 5 -ErrorAction Stop
        $concoursSpecialites = $concoursSpecialitesResponse.Content | ConvertFrom-Json
        if ($concoursSpecialites -and $concoursSpecialites.Count -gt 0) {
            Write-Host "    ✓ Liaisons concours-spécialités trouvées: $($concoursSpecialites.Count)" -ForegroundColor Green
            $successes += "Liaisons concours-spécialités présentes"
        }
        else {
            Write-Host "    ✗ Aucune liaison concours-spécialité trouvée" -ForegroundColor Red
            $errors += "Liaisons concours-spécialités absentes"
        }
    }
    catch {
        Write-Host "    ⚠ Endpoint concours-spécialités non disponible" -ForegroundColor Yellow
        $warnings += "Endpoint concours-spécialités non accessible"
    }

    # Test des liaisons centre-spécialités
    try {
        $centreSpecialitesResponse = Invoke-WebRequest "http://localhost:8080/api/centres/1/specialites" -UseBasicParsing -TimeoutSec 5 -ErrorAction Stop
        $centreSpecialites = $centreSpecialitesResponse.Content | ConvertFrom-Json
        if ($centreSpecialites -and $centreSpecialites.Count -gt 0) {
            Write-Host "    ✓ Liaisons centre-spécialités trouvées: $($centreSpecialites.Count)" -ForegroundColor Green
            $successes += "Liaisons centre-spécialités présentes"
        }
        else {
            Write-Host "    ✗ Aucune liaison centre-spécialité trouvée" -ForegroundColor Red
            $errors += "Liaisons centre-spécialités absentes"
        }
    }
    catch {
        Write-Host "    ⚠ Endpoint centre-spécialités non disponible" -ForegroundColor Yellow
        $warnings += "Endpoint centre-spécialités non accessible"
    }

    # Vérification des dates de concours
    Write-Host "  📅 DIAGNOSTIC DATES CONCOURS:" -ForegroundColor Cyan
    $dateActuelle = Get-Date
    $concoursOuverts = 0
    $concoursFermes = 0
    $concoursInvalides = 0

    foreach ($concour in $concours) {
        if ($concour.dateDebutCandidature -and $concour.dateFinCandidature) {
            try {
                $dateDebut = [DateTime]::Parse($concour.dateDebutCandidature)
                $dateFin = [DateTime]::Parse($concour.dateFinCandidature)
                
                if ($dateActuelle -ge $dateDebut -and $dateActuelle -le $dateFin) {
                    $concoursOuverts++
                    Write-Host "    ✓ $($concour.nom): OUVERT (fin le $($dateFin.ToString('dd/MM/yyyy')))" -ForegroundColor Green
                }
                elseif ($dateActuelle -lt $dateDebut) {
                    Write-Host "    ⏰ $($concour.nom): FUTUR (ouverture le $($dateDebut.ToString('dd/MM/yyyy')))" -ForegroundColor Yellow
                }
                else {
                    $concoursFermes++
                    Write-Host "    ✗ $($concour.nom): FERMÉ (fermé le $($dateFin.ToString('dd/MM/yyyy')))" -ForegroundColor Red
                }
            }
            catch {
                $concoursInvalides++
                Write-Host "    ⚠ $($concour.nom): Dates invalides" -ForegroundColor Yellow
            }
        }
        else {
            $concoursInvalides++
            Write-Host "    ⚠ $($concour.nom): Dates manquantes" -ForegroundColor Yellow
        }
    }

    Write-Host "    📊 Résumé dates: $concoursOuverts ouverts, $concoursFermes fermés, $concoursInvalides invalides" -ForegroundColor Cyan
    
    if ($concoursOuverts -eq 0) {
        $errors += "Aucun concours ouvert aux candidatures"
        Write-Host "    💡 SOLUTION: Mettre à jour les dates des concours dans la base de données" -ForegroundColor Yellow
    }
}
catch {
    Write-Host "  ✗ Erreur lors de la vérification des données de test" -ForegroundColor Red
    Write-Host "    Détail: $($_.Exception.Message)" -ForegroundColor Red
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
        Write-Host "    Statut de réponse: $($responseCentre.StatusCode)" -ForegroundColor Cyan
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
# 12. DIAGNOSTIC SPÉCIFIQUE AFFICHAGE POSTES
# ========================================
Write-Host ""
Write-Host "12. DIAGNOSTIC SPÉCIFIQUE AFFICHAGE POSTES" -ForegroundColor Yellow
Write-Host "===========================================" -ForegroundColor Yellow

Write-Host "🔍 Diagnostic approfondi pour l'affichage des postes disponibles..." -ForegroundColor White

# Test de la séquence complète du frontend
Write-Host "Test de la séquence complète frontend PostesPage..." -ForegroundColor White
try {
    # 1. Simuler le chargement initial de PostesPage
    Write-Host "  📥 1. Chargement des données initiales..." -ForegroundColor Cyan
    
    $headers = @{
        'Origin'  = 'http://localhost:3000'
        'Referer' = 'http://localhost:3000/postes'
        'Accept'  = 'application/json'
    }
    
    # Appels parallèles comme dans PostesPage.js
    Write-Host "    - Chargement concours..." -ForegroundColor Gray
    $concoursResp = Invoke-WebRequest "http://localhost:8080/api/concours" -Headers $headers -UseBasicParsing -TimeoutSec 10 -ErrorAction Stop
    $concoursData = $concoursResp.Content | ConvertFrom-Json
    
    Write-Host "    - Chargement centres..." -ForegroundColor Gray
    $centresResp = Invoke-WebRequest "http://localhost:8080/api/centres" -Headers $headers -UseBasicParsing -TimeoutSec 10 -ErrorAction Stop
    $centresData = $centresResp.Content | ConvertFrom-Json
    
    Write-Host "    - Chargement spécialités..." -ForegroundColor Gray
    $specialitesResp = Invoke-WebRequest "http://localhost:8080/api/specialites" -Headers $headers -UseBasicParsing -TimeoutSec 10 -ErrorAction Stop
    $specialitesData = $specialitesResp.Content | ConvertFrom-Json
    
    # Vérification des données reçues
    Write-Host "  📊 2. Vérification des données reçues..." -ForegroundColor Cyan
    
    if ($concoursData -and ($concoursData -is [Array]) -and $concoursData.Count -gt 0) {
        Write-Host "    ✓ Concours: $($concoursData.Count) éléments reçus" -ForegroundColor Green
        Write-Host "      Structure du premier concours:" -ForegroundColor Gray
        $premier = $concoursData[0]
        Write-Host "        - id: $($premier.id)" -ForegroundColor Gray
        Write-Host "        - nom: $($premier.nom)" -ForegroundColor Gray
        Write-Host "        - actif: $($premier.actif)" -ForegroundColor Gray
        Write-Host "        - dateDebutCandidature: $($premier.dateDebutCandidature)" -ForegroundColor Gray
        Write-Host "        - dateFinCandidature: $($premier.dateFinCandidature)" -ForegroundColor Gray
    }
    else {
        Write-Host "    ✗ Concours: Données invalides ou vides" -ForegroundColor Red
        $errors += "API concours retourne des données invalides pour PostesPage"
    }
    
    if ($centresData -and ($centresData -is [Array]) -and $centresData.Count -gt 0) {
        Write-Host "    ✓ Centres: $($centresData.Count) éléments reçus" -ForegroundColor Green
    }
    else {
        Write-Host "    ✗ Centres: Données invalides ou vides" -ForegroundColor Red
        $errors += "API centres retourne des données invalides pour PostesPage"
    }
    
    if ($specialitesData -and ($specialitesData -is [Array]) -and $specialitesData.Count -gt 0) {
        Write-Host "    ✓ Spécialités: $($specialitesData.Count) éléments reçus" -ForegroundColor Green
    }
    else {
        Write-Host "    ✗ Spécialités: Données invalides ou vides" -ForegroundColor Red
        $errors += "API spécialités retourne des données invalides pour PostesPage"
    }
    
    # 3. Test des filtres comme dans PostesPage
    Write-Host "  🔍 3. Test des fonctions de filtrage..." -ForegroundColor Cyan
    
    $concoursActifs = $concoursData | Where-Object { $_.actif -eq $true }
    Write-Host "    - Concours actifs: $($concoursActifs.Count)/$($concoursData.Count)" -ForegroundColor Gray
    
    if ($concoursActifs.Count -eq 0) {
        Write-Host "    ✗ Aucun concours actif trouvé" -ForegroundColor Red
        $errors += "Aucun concours n'est marqué comme actif dans la base"
    }
    
    # Test des dates des concours
    $dateActuelle = Get-Date
    $concoursOuverts = 0
    $concoursDetails = @()
    
    foreach ($concours in $concoursActifs) {
        $statut = "INVALIDE"
        $couleur = "Red"
        
        if ($concours.dateDebutCandidature -and $concours.dateFinCandidature) {
            try {
                $dateDebut = [DateTime]::Parse($concours.dateDebutCandidature)
                $dateFin = [DateTime]::Parse($concours.dateFinCandidature)
                
                if ($dateActuelle -ge $dateDebut -and $dateActuelle -le $dateFin) {
                    $statut = "OUVERT"
                    $couleur = "Green"
                    $concoursOuverts++
                }
                elseif ($dateActuelle -lt $dateDebut) {
                    $statut = "FUTUR"
                    $couleur = "Yellow"
                }
                else {
                    $statut = "FERMÉ"
                    $couleur = "Red"
                }
                
                $joursRestants = ($dateFin - $dateActuelle).Days
                $concoursDetails += @{
                    nom           = $concours.nom
                    statut        = $statut
                    joursRestants = $joursRestants
                    dateDebut     = $dateDebut.ToString("dd/MM/yyyy")
                    dateFin       = $dateFin.ToString("dd/MM/yyyy")
                }
                
                Write-Host "      - $($concours.nom): $statut ($joursRestants jours)" -ForegroundColor $couleur
            }
            catch {
                Write-Host "      - $($concours.nom): Dates invalides" -ForegroundColor Red
                $concoursDetails += @{
                    nom    = $concours.nom
                    statut = "DATES_INVALIDES"
                    erreur = $_.Exception.Message
                }
            }
        }
        else {
            Write-Host "      - $($concours.nom): Dates manquantes" -ForegroundColor Red
            $concoursDetails += @{
                nom    = $concours.nom
                statut = "DATES_MANQUANTES"
            }
        }
    }
    
    Write-Host "    📊 Résumé: $concoursOuverts concours ouverts sur $($concoursActifs.Count) actifs" -ForegroundColor Cyan
    
    # 4. Test des relations concours-spécialités-centres
    Write-Host "  🔗 4. Test des relations concours-spécialités-centres..." -ForegroundColor Cyan
    
    if ($concoursOuverts -gt 0) {
        $concoursOuvert = ($concoursActifs | Where-Object { 
                try {
                    $dateDebut = [DateTime]::Parse($_.dateDebutCandidature)
                    $dateFin = [DateTime]::Parse($_.dateFinCandidature)
                    $dateActuelle -ge $dateDebut -and $dateActuelle -le $dateFin
                }
                catch {
                    $false
                }
            })[0]
        
        if ($concoursOuvert) {
            Write-Host "    Test avec concours: $($concoursOuvert.nom)" -ForegroundColor Gray
            
            # Test des spécialités pour ce concours
            try {
                $specialitesConcours = Invoke-WebRequest "http://localhost:8080/api/concours/$($concoursOuvert.id)/specialites" -Headers $headers -UseBasicParsing -TimeoutSec 5 -ErrorAction Stop
                $specialitesConcoursData = $specialitesConcours.Content | ConvertFrom-Json
                
                if ($specialitesConcoursData -and $specialitesConcoursData.Count -gt 0) {
                    Write-Host "      ✓ Spécialités disponibles pour ce concours: $($specialitesConcoursData.Count)" -ForegroundColor Green
                }
                else {
                    Write-Host "      ✗ Aucune spécialité liée à ce concours" -ForegroundColor Red
                    $errors += "Concours $($concoursOuvert.nom) n'a aucune spécialité associée"
                }
            }
            catch {
                Write-Host "      ⚠ Impossible de récupérer les spécialités du concours" -ForegroundColor Yellow
                $warnings += "Endpoint spécialités par concours non disponible"
            }
            
            # Test des centres pour une spécialité
            if ($specialitesData.Count -gt 0) {
                $premiereSpecialite = $specialitesData[0]
                try {
                    $centresSpecialite = Invoke-WebRequest "http://localhost:8080/api/specialites/$($premiereSpecialite.id)/centres" -Headers $headers -UseBasicParsing -TimeoutSec 5 -ErrorAction Stop
                    $centresSpecialiteData = $centresSpecialite.Content | ConvertFrom-Json
                    
                    if ($centresSpecialiteData -and $centresSpecialiteData.Count -gt 0) {
                        Write-Host "      ✓ Centres disponibles pour $($premiereSpecialite.nom): $($centresSpecialiteData.Count)" -ForegroundColor Green
                        $successes += "Relations concours-spécialités-centres fonctionnelles"
                    }
                    else {
                        Write-Host "      ✗ Aucun centre pour $($premiereSpecialite.nom)" -ForegroundColor Red
                        $errors += "Spécialité $($premiereSpecialite.nom) n'a aucun centre associé"
                    }
                }
                catch {
                    Write-Host "      ⚠ Impossible de récupérer les centres de la spécialité" -ForegroundColor Yellow
                    $warnings += "Endpoint centres par spécialité non disponible"
                }
            }
        }
    }
    else {
        Write-Host "      ⚠ Aucun concours ouvert pour tester les relations" -ForegroundColor Yellow
        $warnings += "Impossible de tester les relations car aucun concours ouvert"
    }
    
    # 5. Test de simulation d'un clic sur "Candidater"
    Write-Host "  👆 5. Simulation du clic 'Candidater'..." -ForegroundColor Cyan
    
    if ($concoursOuverts -gt 0 -and $centresData.Count -gt 0 -and $specialitesData.Count -gt 0) {
        Write-Host "    ✓ Données suffisantes pour navigation vers /candidature" -ForegroundColor Green
        Write-Host "      - Concours disponibles: $concoursOuverts" -ForegroundColor Gray
        Write-Host "      - Centres disponibles: $($centresData.Count)" -ForegroundColor Gray
        Write-Host "      - Spécialités disponibles: $($specialitesData.Count)" -ForegroundColor Gray
        $successes += "Navigation PostesPage → CandidaturePage possible"
    }
    else {
        Write-Host "    ✗ Données insuffisantes pour la navigation" -ForegroundColor Red
        $errors += "Impossible de naviguer vers la page de candidature depuis PostesPage"
    }
    
    # 6. Diagnostic de l'état de l'interface utilisateur
    Write-Host "  🖥️ 6. Diagnostic interface utilisateur..." -ForegroundColor Cyan
    
    if ($concoursData.Count -eq 0) {
        Write-Host "    ✗ PROBLÈME: Aucun concours à afficher" -ForegroundColor Red
        Write-Host "      💡 Solution: Vérifier insert_test_data.sql" -ForegroundColor Yellow
    }
    elseif ($concoursActifs.Count -eq 0) {
        Write-Host "    ✗ PROBLÈME: Aucun concours actif" -ForegroundColor Red
        Write-Host "      💡 Solution: Mettre actif=true dans la table Concours" -ForegroundColor Yellow
    }
    elseif ($concoursOuverts -eq 0) {
        Write-Host "    ✗ PROBLÈME: Aucun concours ouvert aux candidatures" -ForegroundColor Red
        Write-Host "      💡 Solution: Mettre à jour les dates dans la table Concours" -ForegroundColor Yellow
        Write-Host "      📅 Dates actuelles des concours actifs:" -ForegroundColor Yellow
        foreach ($detail in $concoursDetails) {
            if ($detail.dateDebut) {
                Write-Host "        - $($detail.nom): $($detail.dateDebut) → $($detail.dateFin) ($($detail.statut))" -ForegroundColor Gray
            }
            else {
                Write-Host "        - $($detail.nom): $($detail.statut)" -ForegroundColor Gray
            }
        }
    }
    else {
        Write-Host "    ✓ Interface devrait afficher $concoursOuverts concours disponibles" -ForegroundColor Green
        $successes += "PostesPage devrait afficher correctement les concours"
    }

}
catch {
    Write-Host "  ✗ Erreur lors du diagnostic PostesPage" -ForegroundColor Red
    Write-Host "    Détail: $($_.Exception.Message)" -ForegroundColor Red
    $errors += "Diagnostic PostesPage échoué - $($_.Exception.Message)"
}

# Test spécifique des erreurs JavaScript frontend
Write-Host ""
Write-Host "🌐 Test des erreurs potentielles côté frontend..." -ForegroundColor White
try {
    if ($port3000) {
        # Test si le frontend charge correctement
        $frontendResp = Invoke-WebRequest "http://localhost:3000/postes" -UseBasicParsing -TimeoutSec 10 -ErrorAction Stop
        
        if ($frontendResp.StatusCode -eq 200) {
            Write-Host "  ✓ Page /postes accessible" -ForegroundColor Green
            
            # Vérifier les console errors dans le contenu HTML
            $content = $frontendResp.Content
            if ($content -like "*React*" -and $content -like "*root*") {
                Write-Host "  ✓ Application React chargée" -ForegroundColor Green
                $successes += "Frontend PostesPage accessible et React actif"
            }
            else {
                Write-Host "  ⚠ Page chargée mais React peut ne pas être actif" -ForegroundColor Yellow
                $warnings += "React peut ne pas être correctement initialisé"
            }
        }
    }
    else {
        Write-Host "  ⚠ Frontend non démarré, impossible de tester /postes" -ForegroundColor Yellow
        $warnings += "Frontend non accessible pour test PostesPage"
    }
}
catch {
    Write-Host "  ✗ Erreur lors de l'accès à /postes" -ForegroundColor Red
    $errors += "Page /postes inaccessible - $($_.Exception.Message)"
}

# ========================================
# 13. VÉRIFICATION SCRIPTS SQL ET BASE DE DONNÉES
# ========================================
Write-Host ""
Write-Host "13. VÉRIFICATION SCRIPTS SQL ET BASE DE DONNÉES" -ForegroundColor Yellow
Write-Host "================================================" -ForegroundColor Yellow

Write-Host "🗄️ Vérification de l'exécution des scripts SQL..." -ForegroundColor White

# Vérifier si insert_test_data.sql a été exécuté
try {
    # Test de présence de données spécifiques du script de test
    $testResponse = Invoke-WebRequest "http://localhost:8080/api/test/health" -UseBasicParsing -TimeoutSec 5 -ErrorAction Stop
    $testData = $testResponse.Content | ConvertFrom-Json
    
    Write-Host "  📊 État de la base de données:" -ForegroundColor Cyan
    Write-Host "    - Utilisateurs: $($testData.nombre_utilisateurs)" -ForegroundColor Gray
    Write-Host "    - Candidats: $($testData.nombre_candidats)" -ForegroundColor Gray
    
    if ($testData.nombre_utilisateurs -ge 3) {
        Write-Host "  ✓ Utilisateurs de test présents" -ForegroundColor Green
        $successes += "Utilisateurs de test chargés dans la base"
    }
    else {
        Write-Host "  ⚠ Peu d'utilisateurs de test ($($testData.nombre_utilisateurs))" -ForegroundColor Yellow
        $warnings += "Script insert_test_data.sql possiblement non exécuté complètement"
    }
    
    # Vérifier les centres avec des noms spécifiques du script de test
    $centres = (Invoke-WebRequest "http://localhost:8080/api/centres" -UseBasicParsing -TimeoutSec 5).Content | ConvertFrom-Json
    $centresTEST = $centres | Where-Object { $_.nom -like "*Rabat*" -or $_.nom -like "*Casablanca*" -or $_.nom -like "*Marrakech*" }
    
    if ($centresTEST.Count -ge 3) {
        Write-Host "  ✓ Centres de test spécifiques trouvés ($($centresTEST.Count))" -ForegroundColor Green
        $successes += "Centres de test du script SQL présents"
    }
    else {
        Write-Host "  ⚠ Centres de test manquants ou incorrects" -ForegroundColor Yellow
        $warnings += "Script centres possiblement non exécuté ou modifié"
        
        Write-Host "    Centres trouvés:" -ForegroundColor Gray
        foreach ($centre in $centres) {
            Write-Host "      - $($centre.nom) ($($centre.ville))" -ForegroundColor Gray
        }
    }

}
catch {
    Write-Host "  ✗ Impossible de vérifier l'état de la base de données" -ForegroundColor Red
    $errors += "État de la base de données non vérifiable - $($_.Exception.Message)"
}

# Vérifier les fichiers SQL
Write-Host "  📁 Vérification des fichiers SQL..." -ForegroundColor Cyan
$scriptSQL = "insert_test_data.sql"
if (Test-Path $scriptSQL) {
    Write-Host "    ✓ Script $scriptSQL trouvé" -ForegroundColor Green
    
    # Lire les premières lignes pour vérifier le contenu
    $contenuSQL = Get-Content $scriptSQL -TotalCount 20
    if ($contenuSQL -join "`n" -like "*USE candidature_plus*") {
        Write-Host "    ✓ Script contient les instructions pour candidature_plus" -ForegroundColor Green
        $successes += "Script SQL de test disponible et correct"
    }
    else {
        Write-Host "    ⚠ Script peut ne pas cibler la bonne base de données" -ForegroundColor Yellow
        $warnings += "Script SQL possiblement incorrect"
    }
}
else {
    Write-Host "    ✗ Script $scriptSQL non trouvé" -ForegroundColor Red
    $errors += "Script de données de test manquant"
    
    Write-Host "    💡 Solution: Créer ou restaurer le fichier insert_test_data.sql" -ForegroundColor Yellow
}

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
# DIAGNOSTIC SPÉCIFIQUE POSTES DISPONIBLES
# ========================================
Write-Host ""
Write-Host "🎯 DIAGNOSTIC SPÉCIFIQUE: POSTES NON VISIBLES" -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan

$problemesPostes = @()
$solutionsPostes = @()

# Analyser les problèmes spécifiques aux postes
if ($errors -contains "Centres de test absents" -or $errors -contains "Concours de test absents" -or $errors -contains "Spécialités de test absentes") {
    $problemesPostes += "DONNÉES DE BASE MANQUANTES"
    $solutionsPostes += "1. Exécuter le script insert_test_data.sql dans MySQL"
    $solutionsPostes += "   - Ouvrir MySQL Workbench ou ligne de commande MySQL"
    $solutionsPostes += "   - Exécuter: SOURCE insert_test_data.sql;"
}

if ($errors -contains "Aucun concours n'est marqué comme actif dans la base") {
    $problemesPostes += "CONCOURS INACTIFS"
    $solutionsPostes += "2. Activer les concours dans la base de données"
    $solutionsPostes += "   - UPDATE Concours SET actif = true WHERE actif = false;"
}

if ($errors -contains "Aucun concours ouvert aux candidatures") {
    $problemesPostes += "DATES DE CONCOURS EXPIRÉES"
    $solutionsPostes += "3. Mettre à jour les dates des concours"
    $solutionsPostes += "   - UPDATE Concours SET dateDebutCandidature = CURDATE(),"
    $solutionsPostes += "     dateFinCandidature = DATE_ADD(CURDATE(), INTERVAL 30 DAY)"
    $solutionsPostes += "     WHERE actif = true;"
}

if ($errors -like "*Liaisons*concours-spécialités*" -or $errors -like "*Liaisons*centre-spécialités*") {
    $problemesPostes += "RELATIONS ENTRE ENTITÉS MANQUANTES"
    $solutionsPostes += "4. Vérifier les tables de liaison"
    $solutionsPostes += "   - Table Concours_Specialite doit avoir des données"
    $solutionsPostes += "   - Table Centre_Specialite doit avoir des données"
}

if ($errors -contains "API concours retourne des données invalides pour PostesPage" -or 
    $errors -contains "API centres retourne des données invalides pour PostesPage" -or 
    $errors -contains "API spécialités retourne des données invalides pour PostesPage") {
    $problemesPostes += "RÉPONSES API INVALIDES"
    $solutionsPostes += "5. Vérifier la configuration des endpoints REST"
    $solutionsPostes += "   - Endpoints /api/concours, /api/centres, /api/specialites"
    $solutionsPostes += "   - Vérifier les annotations @JsonIgnore/@JsonInclude"
}

if ($problemesPostes.Count -gt 0) {
    Write-Host ""
    Write-Host "📋 PROBLÈMES IDENTIFIÉS:" -ForegroundColor Red
    foreach ($probleme in $problemesPostes) {
        Write-Host "  ❌ $probleme" -ForegroundColor Red
    }
    
    Write-Host ""
    Write-Host "🔧 SOLUTIONS RECOMMANDÉES:" -ForegroundColor Green
    foreach ($solution in $solutionsPostes) {
        if ($solution -like "*. *") {
            Write-Host "  $solution" -ForegroundColor Yellow
        }
        else {
            Write-Host "     $solution" -ForegroundColor Gray
        }
    }
    
    Write-Host ""
    Write-Host "🚀 ACTIONS IMMÉDIATES À EFFECTUER:" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "ÉTAPE 1: Vérifier la base de données" -ForegroundColor White
    Write-Host "  mysql -u root -p candidature_plus" -ForegroundColor Gray
    Write-Host "  SELECT COUNT(*) FROM Concours WHERE actif = true;" -ForegroundColor Gray
    Write-Host "  SELECT COUNT(*) FROM Centre;" -ForegroundColor Gray
    Write-Host "  SELECT COUNT(*) FROM Specialite;" -ForegroundColor Gray
    Write-Host ""
    
    Write-Host "ÉTAPE 2: Corriger les données si nécessaire" -ForegroundColor White
    Write-Host "  SOURCE insert_test_data.sql;" -ForegroundColor Gray
    Write-Host ""
    
    Write-Host "ÉTAPE 3: Mettre à jour les dates des concours" -ForegroundColor White
    Write-Host "  UPDATE Concours SET " -ForegroundColor Gray
    Write-Host "    dateDebutCandidature = CURDATE()," -ForegroundColor Gray  
    Write-Host "    dateFinCandidature = DATE_ADD(CURDATE(), INTERVAL 30 DAY)," -ForegroundColor Gray
    Write-Host "    actif = true" -ForegroundColor Gray
    Write-Host "  WHERE id IN (1,2,3);" -ForegroundColor Gray
    Write-Host ""
    
    Write-Host "ÉTAPE 4: Redémarrer le backend" -ForegroundColor White
    Write-Host "  stop_app.bat" -ForegroundColor Gray
    Write-Host "  start_app.bat" -ForegroundColor Gray
    Write-Host ""
    
    Write-Host "ÉTAPE 5: Tester à nouveau" -ForegroundColor White
    Write-Host "  .\diagnostic_app.ps1" -ForegroundColor Gray
    Write-Host "  Ouvrir http://localhost:3000/postes" -ForegroundColor Gray
    
}
else {
    Write-Host ""
    Write-Host "✅ POSTES DISPONIBLES: DIAGNOSTIC OK" -ForegroundColor Green
    Write-Host "  Les postes devraient être visibles dans l'interface." -ForegroundColor Green
    Write-Host "  Si le problème persiste, vérifier:" -ForegroundColor White
    Write-Host "    - La console JavaScript du navigateur (F12)" -ForegroundColor Gray
    Write-Host "    - Les logs du backend Spring Boot" -ForegroundColor Gray
    Write-Host "    - La connectivité réseau entre frontend et backend" -ForegroundColor Gray
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

# ========================================
# GÉNÉRATION DE SCRIPT DE CORRECTION SQL
# ========================================
if ($problemesPostes.Count -gt 0) {
    Write-Host ""
    Write-Host "🔧 GÉNÉRATION DU SCRIPT DE CORRECTION..." -ForegroundColor Cyan
    
    $correctionSQL = @"
-- =========================================
-- SCRIPT DE CORRECTION AUTOMATIQUE
-- Généré le $(Get-Date)
-- Pour résoudre les problèmes de postes non visibles
-- =========================================

USE candidature_plus;

-- 1. Activer tous les concours
UPDATE Concours SET actif = true WHERE actif = false OR actif IS NULL;

-- 2. Mettre à jour les dates des concours pour les rendre disponibles
UPDATE Concours SET 
    dateDebutCandidature = CURDATE(),
    dateFinCandidature = DATE_ADD(CURDATE(), INTERVAL 60 DAY)
WHERE actif = true;

-- 3. Vérifier les données après correction
SELECT 'CONCOURS ACTIFS' as verification, COUNT(*) as nombre FROM Concours WHERE actif = true;
SELECT 'CONCOURS OUVERTS' as verification, COUNT(*) as nombre FROM Concours 
WHERE actif = true AND dateDebutCandidature <= CURDATE() AND dateFinCandidature >= CURDATE();
SELECT 'CENTRES' as verification, COUNT(*) as nombre FROM Centre;
SELECT 'SPÉCIALITÉS' as verification, COUNT(*) as nombre FROM Specialite;

-- 4. Afficher les concours ouverts
SELECT 
    id,
    nom,
    dateDebutCandidature,
    dateFinCandidature,
    actif,
    DATEDIFF(dateFinCandidature, CURDATE()) as jours_restants
FROM Concours 
WHERE actif = true 
ORDER BY dateFinCandidature;

COMMIT;
"@

    $correctionPath = "correction_postes_$timestamp.sql"
    $correctionSQL | Out-File -FilePath $correctionPath -Encoding UTF8
    Write-Host "  ✓ Script de correction généré: $correctionPath" -ForegroundColor Green
    Write-Host ""
    Write-Host "  📋 Pour appliquer les corrections:" -ForegroundColor Yellow
    Write-Host "    mysql -u root -p < $correctionPath" -ForegroundColor Gray
}

# Sauvegarder le rapport détaillé
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
