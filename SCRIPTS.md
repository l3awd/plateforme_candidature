# 🚀 Scripts CandidaturePlus - Guide Simplifié

## Scripts Disponibles

### 📊 Base de Données (MySQL) - Exécution Manuelle

1. **`init_database.sql`** - Création complète de la base de données

   - Supprime et recrée la base candidature_plus
   - **Usage :** `mysql -u root --password=1234 < init_database.sql`

2. **`insert_test_data.sql`** - Insertion des données de test

   - Ajoute centres, concours, utilisateurs de test
   - **Usage :** `mysql -u root --password=1234 < insert_test_data.sql`

3. **`update_db.sql`** - Mise à jour incrémentale
   - Applique les nouvelles fonctionnalités sans perdre les données
   - **Usage :** `mysql -u root --password=1234 candidature_plus < update_db.sql`

### 🖥️ Application (BAT)

4. **`start_app.bat`** - Lancement de l'application ✅

   - Lance backend Spring Boot + frontend React
   - **Usage :** Double-clic (LE SCRIPT QUI MARCHE)

5. **`stop_app.bat`** - Arrêt de l'application

   - Ferme tous les processus Java et Node.js
   - **Usage :** Double-clic

6. **`apply_changes.bat`** - Application des changements
   - Redémarre tout après modifications
   - **Usage :** Double-clic après changements code

### 📊 Diagnostic (PowerShell)

7. **`diagnostic_app.ps1`** - Diagnostic complet
   - Teste toutes les fonctionnalités (nouvelles incluses)
   - **Usage :** `powershell -ExecutionPolicy Bypass -File diagnostic_app.ps1`

## 🔄 Workflow

### Première installation

```bash
1. mysql -u root --password=1234 < init_database.sql
2. mysql -u root --password=1234 < insert_test_data.sql
3. Double-clic sur start_app.bat
```

### Après modifications de la base de données

```bash
1. mysql -u root --password=1234 candidature_plus < update_db.sql
2. Double-clic sur apply_changes.bat
```

### Après modifications du code uniquement

```bash
1. Double-clic sur apply_changes.bat
```

### Utilisation quotidienne

```bash
Démarrer: start_app.bat
Arrêter: stop_app.bat
Diagnostic: diagnostic_app.ps1
```

## 👤 Comptes de test

| Email               | Mot de passe | Rôle                |
| ------------------- | ------------ | ------------------- |
| admin@test.com      | 1234         | Administrateur      |
| h.alami@mf.gov.ma   | 1234         | Gestionnaire Local  |
| f.bennani@mf.gov.ma | 1234         | Gestionnaire Local  |
| m.chraibi@mf.gov.ma | 1234         | Gestionnaire Global |

## 🌐 URLs

- Frontend: http://localhost:3000
- Backend: http://localhost:8080

---

_Scripts nettoyés et optimisés - Plus de doublons !_
