# Changements de Base de Données - CandidaturePlus

## 📋 Résumé des Modifications

Avec l'implémentation des nouvelles fonctionnalités, plusieurs changements ont été apportés à la base de données pour supporter :

### 🔧 Fonctionnalités Ajoutées

- ✅ **Système d'authentification avec BCrypt**
- ✅ **Gestion des rôles et permissions**
- ✅ **Interface de gestion pour les gestionnaires**
- ✅ **Système de notifications par email**
- ✅ **Logs des actions utilisateurs**
- ✅ **Validation/Rejet de candidatures**
- ✅ **Réservation automatique des places**

## 🗃️ Nouvelles Tables

### 1. **Log_Action**

Table pour tracer toutes les actions des utilisateurs :

```sql
- id (INT, PRIMARY KEY)
- type_acteur (ENUM: Candidat, Utilisateur, Systeme)
- acteur_id (INT)
- action (VARCHAR(100))
- table_cible (VARCHAR(50))
- enregistrement_id (BIGINT)
- details (JSON)
- ip_adresse (VARCHAR(45))
- user_agent (TEXT)
- date_action (TIMESTAMP)
```

### 2. **Notification**

Table pour gérer les emails automatiques :

```sql
- id (INT, PRIMARY KEY)
- candidature_id (INT, FK)
- type_notification (ENUM)
- destinataire_email (VARCHAR(150))
- sujet (VARCHAR(255))
- contenu (TEXT)
- envoye (BOOLEAN)
- date_creation (TIMESTAMP)
- date_envoi (TIMESTAMP)
- tentatives (INT)
- erreur_envoi (TEXT)
```

## 🔄 Tables Modifiées

### 1. **Candidature**

- ✅ Enum `etat` mis à jour : `'Soumise', 'En_Cours_Validation', 'Validee', 'Rejetee', 'Confirmee'`
- ✅ Champ `numero_place` pour l'attribution automatique
- ✅ Champ `gestionnaire_id` pour tracer qui a traité la candidature

### 2. **Candidat**

- ✅ Champ `genre` ajouté (ENUM: Masculin, Feminin)
- ✅ Tous les champs requis vérifiés

### 3. **Utilisateur**

- ✅ Mots de passe convertis au format BCrypt
- ✅ Champ `derniere_connexion` utilisé

### 4. **Centre_Specialite**

- ✅ Champ `places_occupees` ajouté pour suivre les réservations

## 📊 Index Ajoutés

Pour améliorer les performances :

```sql
- idx_candidature_etat
- idx_candidature_centre_etat
- idx_candidature_date_soumission
- idx_log_action_date
- idx_log_action_acteur
- idx_notification_candidature
- idx_notification_envoye
```

## 🔐 Sécurité

### Mots de Passe BCrypt

Tous les mots de passe sont maintenant encodés avec BCrypt (force 12) :

- **Mot de passe original** : `1234`
- **Hash BCrypt** : `$2a$12$5QvwYVxQ0KgO3AhT1vbIZeN8JKU.6FWRGkOsXEtpKqxKoVmzLcNgq`

### Comptes de Test

| Email               | Rôle                | Centre   | Mot de Passe |
| ------------------- | ------------------- | -------- | ------------ |
| h.alami@mf.gov.ma   | Gestionnaire Local  | Centre 1 | 1234         |
| f.bennani@mf.gov.ma | Gestionnaire Local  | Centre 2 | 1234         |
| m.chraibi@mf.gov.ma | Gestionnaire Global | Tous     | 1234         |
| a.talbi@mf.gov.ma   | Administrateur      | Tous     | 1234         |
| admin@test.com      | Admin Test          | Tous     | 1234         |

## 🚀 Scripts de Mise à Jour

### Fichiers Créés

1. **`update_database_complete.sql`** - Script complet de mise à jour
2. **`verify_database.bat`** - Vérification de l'état de la BD
3. **`reset_database.bat`** - Réinitialisation complète

### Commandes d'Application

#### Mise à jour automatique (recommandée)

```bash
./start_complete_application.bat
```

#### Mise à jour manuelle

```bash
mysql -u root -p1234 candidature_plus < update_database_complete.sql
```

#### Vérification

```bash
./verify_database.bat
```

#### Réinitialisation complète

```bash
./reset_database.bat
```

## ⚠️ Points d'Attention

### 1. **Données Existantes**

- Les candidatures existantes conservent leur état
- Les mots de passe sont automatiquement convertis
- Aucune perte de données n'est prévue

### 2. **Compatibilité**

- Compatible avec MySQL 8.0+
- Les contraintes FK sont préservées
- Les index sont ajoutés sans conflit

### 3. **Performance**

- Les nouveaux index améliorent les requêtes
- Le système de logs est optimisé
- Les notifications sont asynchrones

## 🔍 Vérifications Post-Mise à Jour

Après l'application des scripts, vérifiez :

1. **Tables créées** : Log_Action, Notification
2. **Mots de passe** : Format BCrypt
3. **Enum Candidature** : Nouvelles valeurs
4. **Index** : Créés correctement
5. **Comptes test** : Fonctionnels

## 📞 En Cas de Problème

1. **Vérifiez les logs** : Table Log_Action
2. **Réinitialisez** : Utilisez `reset_database.bat`
3. **Vérifiez la connectivité** : MySQL accessible
4. **Consultez les erreurs** : Messages dans les scripts

---

_Ces changements sont nécessaires pour supporter toutes les nouvelles fonctionnalités implémentées selon les diagrammes UML fournis._
