# 🏗️ Plateforme Candidature Plus - Structure Organisée

## 🚀 Démarrage Rapide

### Pour commencer immédiatement :

```bash
# Démarrage complet de l'application
quick_start.bat

# Arrêt complet de l'application
quick_stop.bat
```

## 📁 Structure du Projet

```
plateforme_candidature/
├── 🔥 QUOTIDIEN/              # Scripts d'usage quotidien
│   ├── start_app.bat          # Démarrage application complète
│   ├── stop_app.bat           # Arrêt application complète
│   └── check_system.bat       # Vérification système rapide
│
├── 📊 BASE_DONNEES/           # Gestion base de données
│   ├── init_database.sql      # Initialisation base
│   ├── insert_test_data.sql   # Données de test
│   ├── clean_test_data.sql    # Nettoyage données test
│   └── update_db.sql          # Mises à jour schema
│
├── 🔧 MAINTENANCE/            # Scripts de maintenance
│   ├── apply_changes.bat      # Application changements
│   └── diagnostic_app.ps1     # Diagnostic avancé
│
├── 📖 DOCUMENTATION/          # Guides et documentation
│   ├── README.md              # Documentation principale
│   ├── GUIDE_SCRIPTS_ORGANISE.md  # Guide des scripts
│   ├── CHANGEMENTS_BASE_DONNEES.md # Historique DB
│   └── NOUVELLES_FONCTIONNALITES.md # Nouvelles features
│
├── backend/                   # Application Spring Boot
├── frontend/                  # Application React
├── UML/                       # Diagrammes UML
│
├── quick_start.bat           # 🚀 Démarrage rapide
├── quick_stop.bat            # 🛑 Arrêt rapide
└── reorganiser_scripts.bat   # 🗂️ Réorganisation
```

## 🎯 Flux de Travail Recommandé

### 🌅 Début de journée

1. `quick_start.bat` - Démarrage rapide
2. Ou `QUOTIDIEN\check_system.bat` puis `QUOTIDIEN\start_app.bat`

### 💻 Développement

1. **Modifications code** ➜ `MAINTENANCE\apply_changes.bat`
2. **Reset données** ➜ `BASE_DONNEES\clean_test_data.sql` + `BASE_DONNEES\insert_test_data.sql`
3. **Problème** ➜ `MAINTENANCE\diagnostic_app.ps1`

### 🌙 Fin de journée

1. `quick_stop.bat` - Arrêt rapide

## 📍 URLs d'Accès

| Service            | URL                                   | Description                 |
| ------------------ | ------------------------------------- | --------------------------- |
| 🌐 **Frontend**    | http://localhost:3000                 | Interface utilisateur React |
| 🔧 **Backend API** | http://localhost:8080                 | API REST Spring Boot        |
| 📊 **API Docs**    | http://localhost:8080/swagger-ui.html | Documentation API           |

## 🎨 Pages Disponibles

| Route                   | Composant                   | Description                         |
| ----------------------- | --------------------------- | ----------------------------------- |
| `/`                     | HomePage                    | Page d'accueil                      |
| `/login`                | LoginPageNew                | Connexion utilisateur               |
| `/postes`               | PostesPage                  | Liste des postes (version simple)   |
| `/postes-complete`      | PostesPageComplete          | Liste des postes (version complète) |
| `/postes-moderne`       | PostesPageModerne           | Liste des postes (design moderne)   |
| `/candidature`          | CandidaturePage             | Formulaire candidature              |
| `/suivi`                | SuiviCandidaturePage        | Suivi des candidatures              |
| `/dashboard`            | Dashboard                   | Tableau de bord                     |
| `/gestion-candidatures` | GestionCandidaturesComplete | Gestion des candidatures            |

## 🛠️ Prérequis Techniques

- ☕ **Java 11+** - Backend Spring Boot
- 📦 **Maven 3.6+** - Gestion dépendances Java
- 🟢 **Node.js 16+** - Frontend React
- 📦 **npm 8+** - Gestion dépendances JavaScript
- 🗄️ **MySQL 8.0+** - Base de données

## 🆘 Résolution de Problèmes

### ❌ Port déjà utilisé

```bash
# Arrêter tous les processus
quick_stop.bat
# Puis redémarrer
quick_start.bat
```

### 🔧 Erreur de compilation

```bash
MAINTENANCE\apply_changes.bat
```

### 🔍 Diagnostic avancé

```powershell
MAINTENANCE\diagnostic_app.ps1
```

### 🗄️ Problème base de données

```sql
-- Réinitialisation complète
SOURCE BASE_DONNEES/init_database.sql;
SOURCE BASE_DONNEES/insert_test_data.sql;
```

## 📞 Support

1. **Consulter** `DOCUMENTATION/GUIDE_SCRIPTS_ORGANISE.md`
2. **Exécuter** `MAINTENANCE/diagnostic_app.ps1`
3. **Vérifier** les logs dans `backend/logs/`

---

_Dernière mise à jour : $(Get-Date)_

# CandidaturePlus

## Scripts Principaux (Structure Normalisée)

🥇 Première Installation (une seule fois)

- `init_database.sql`
- `insert_test_data.sql`
- `start_app.bat`

🔄 Utilisation Quotidienne

- `start_app.bat`
- `stop_app.bat`

🛠️ Après Modifications du Code

- `apply_changes.bat`

🗄️ Après Modifications de la Base de Données

- `update_db.sql`
- `apply_changes.bat`

📊 Diagnostic

- `diagnostic_app.ps1`

## Scripts Archivés

Tous les autres scripts legacy ont été déplacés dans `archive_scripts/` pour éviter la confusion.
