# Scripts de Lancement - CandidaturePlus

## Scripts Disponibles

### 1. `start_application.bat` - Lancement Complet
**Utilisation :** Double-cliquez sur le fichier ou exécutez dans le terminal
```bash
.\start_application.bat
```

**Fonctionnalités :**
- ✅ Vérification automatique des prérequis (Java, Node.js, npm, Maven)
- ✅ Compilation du backend Spring Boot
- ✅ Installation des dépendances npm (si nécessaire)
- ✅ Lancement simultané du backend et frontend
- ✅ Ouverture automatique du navigateur sur http://localhost:3000

### 2. `start_application.ps1` - Version PowerShell
**Utilisation :** Exécutez dans PowerShell
```powershell
.\start_application.ps1
```

**Avantages :**
- Interface plus moderne avec couleurs
- Gestion d'erreurs améliorée
- Même fonctionnalités que la version .bat

### 3. `restart_quick.bat` - Redémarrage Rapide
**Utilisation :** Pour les développeurs
```bash
.\restart_quick.bat
```

**Fonctionnalités :**
- 🚀 Arrêt automatique des processus existants
- 🚀 Redémarrage rapide sans recompilation
- 🚀 Idéal pour les tests et le développement

### 4. `stop_application.bat` - Arrêt Propre
**Utilisation :** Pour arrêter l'application
```bash
.\stop_application.bat
```

**Fonctionnalités :**
- 🛑 Arrêt propre de tous les processus
- 🛑 Libération des ports 3000 et 8080
- 🛑 Fermeture des onglets du navigateur

## Prérequis Système

### Outils Requis
- **Java JDK 17+** - Pour le backend Spring Boot
- **Node.js 16+** - Pour le frontend React
- **Apache Maven 3.6+** - Pour la compilation du backend
- **npm** - Gestionnaire de packages (inclus avec Node.js)

### Vérification des Prérequis
Exécutez ces commandes pour vérifier votre installation :
```bash
java --version
node --version
npm --version
mvn --version
```

## URLs de l'Application

| Service | URL | Description |
|---------|-----|-------------|
| **Frontend** | http://localhost:3000 | Interface utilisateur React |
| **Backend API** | http://localhost:8080 | API REST Spring Boot |
| **Base de données** | localhost:3306 | MySQL Server |

## Identifiants de Connexion

| Utilisateur | Mot de passe | Rôle |
|-------------|--------------|------|
| `admin` | `1234` | Administrateur |

## Guide de Démarrage Rapide

### Première Utilisation
1. **Installer les prérequis** (Java, Node.js, Maven)
2. **Configurer MySQL** et exécuter `create_database.sql`
3. **Lancer l'application** avec `start_application.bat`
4. **Accéder à l'interface** sur http://localhost:3000
5. **Se connecter** avec admin/1234

### Utilisation Quotidienne
1. **Démarrage** → `start_application.bat`
2. **Redémarrage** → `restart_quick.bat`
3. **Arrêt** → `stop_application.bat`

## Dépannage

### Problèmes Courants

#### Port 8080 déjà utilisé
```bash
# Trouver le processus utilisant le port
netstat -ano | findstr :8080
# Arrêter le processus
taskkill /PID <PID> /F
```

#### Port 3000 déjà utilisé
```bash
# Trouver le processus utilisant le port
netstat -ano | findstr :3000
# Arrêter le processus
taskkill /PID <PID> /F
```

#### Erreur de compilation Maven
```bash
# Nettoyer et recompiler
cd backend
mvn clean install -DskipTests
```

#### Erreur npm
```bash
# Supprimer node_modules et réinstaller
cd frontend
rmdir /s node_modules
npm install
```

### Logs de Débogage

| Log | Emplacement | Description |
|-----|-------------|-------------|
| **Backend** | Console Spring Boot | Erreurs de démarrage, API |
| **Frontend** | Console npm | Erreurs React, compilation |
| **Base de données** | MySQL logs | Connexions, requêtes |

## Architecture de l'Application

```
CandidaturePlus/
├── backend/          # Spring Boot API (Port 8080)
│   ├── src/
│   ├── target/
│   └── pom.xml
├── frontend/         # React App (Port 3000)
│   ├── src/
│   ├── public/
│   └── package.json
├── create_database.sql
└── scripts/          # Scripts de lancement
    ├── start_application.bat
    ├── start_application.ps1
    ├── restart_quick.bat
    └── stop_application.bat
```

## Support

En cas de problème :
1. Vérifiez les prérequis système
2. Consultez les logs d'erreur
3. Redémarrez avec `restart_quick.bat`
4. En dernier recours, arrêtez tout avec `stop_application.bat` et relancez

---

*CandidaturePlus - Plateforme de Gestion des Candidatures*
