# CandidaturePlus

## Plateforme de gestion des candidatures aux concours

### Fonctionnalités Candidats Disponibles

#### 🎯 Pour les candidats (sans authentification)

1. **Formulaire de candidature amélioré** - `/candidature`

   - Soumission en plusieurs étapes avec interface intuitive
   - Champ "Civilité" professionnel (Monsieur/Madame)
   - Sélection de ville avec autocomplete parmi les villes du Maroc
   - Placeholders informatifs pour guider la saisie
   - Validation en temps réel des données
   - Génération automatique d'un numéro unique

2. **Suivi de candidature** - `/suivi`

   - Recherche par numéro unique
   - Historique détaillé des événements
   - Informations sur l'état de la candidature
   - Détails du concours et centre d'examen

3. **Recherche de postes avec téléchargement** - `/postes`
   - Liste des concours ouverts (sans accents pour meilleur affichage)
   - Filtrage par concours, centre et spécialité
   - **NOUVEAU** : Téléchargement de fiches détaillées pour chaque concours
   - Informations détaillées sur chaque concours
   - Candidature directe depuis la page

#### 👨‍💼 Pour les gestionnaires (avec authentification)

- **Tableau de bord** - `/dashboard`
- **Connexion gestionnaire** - `/login`

## Initialisation de l'environnement

### Base de données

1. Créez une base de données MySQL nommée `candidature_plus`
2. Exécutez le script de création : `create_database.sql`
3. Insérez les données de test : `insert_test_data.bat` ou `insert_test_data.sql`

### Backend

1. Naviguez dans le dossier `backend`
2. Exécutez `mvn clean install` pour installer les dépendances Maven
3. Configurez la base de données MySQL dans `application.properties`
4. Démarrez avec `mvn spring-boot:run`

### Frontend

1. Naviguez dans le dossier `frontend`
2. Exécutez `npm install` pour installer les dépendances Node.js
3. Lancez le serveur de développement avec `npm start`

## Nouvelles fonctionnalités (Dernières modifications)

### 🆕 Améliorations du formulaire de candidature

- **Civilité professionnelle** : Remplacement de "Genre" par "Civilité" (Monsieur/Madame)
- **Interface améliorée** : Ajout de placeholders informatifs sur tous les champs
- **Sélection de ville optimisée** : Autocomplete parmi les villes du Maroc (suppression du champ adresse)
- **Validation renforcée** : Contraintes sur les années et meilleurs messages d'erreur

### 📁 Système de fiches de concours

- **Téléchargement de fiches** : Chaque concours dispose d'une fiche PDF téléchargeable
- **API de documents** : Endpoint `/api/documents/fiches/{filename}` pour servir les fichiers
- **Accès multiple** : Boutons de téléchargement sur les cartes de concours et dans les détails

### 🔤 Optimisation de l'affichage

- **Suppression des accents** : Tous les textes de concours sans accents pour un meilleur affichage
- **Compatibilité étendue** : Amélioration de l'affichage sur tous les navigateurs et systèmes

### 📊 Nouvelles fonctionnalités (batch août 2025)

- **Pré-upload documents** : Ajout de la possibilité de pré-upload des documents (CIN, CV, Diplôme) avant la création de la candidature via un champ temporaire `cin_temp`
- **Champ `candidature_id` nullable** : Dans la table `Document`, le champ `candidature_id` est rendu nullable pour permettre le pré-upload
- **Quotas centre/spécialité** : Suivi des `places_occupees` et calcul du numéro de place pour les quotas par centre et spécialité
- **Statistiques multi-axes** : Nouvel endpoint `/api/candidatures/statistiques/multi` pour des statistiques détaillées sur 14 jours, occupation des quotas, et complétude des documents
- **Statistiques avancées** : Endpoint `/api/candidatures/statistiques/avancees` pour des statistiques par gestionnaire, spécialité, et ville centre
- **UI candidature améliorée** : Les étapes sont bloquées tant que le CIN (étape 0) et le CV (étape 1) ne sont pas pré-uploadés; le diplôme est requis avant la soumission finale
- **Centres inaccessibles désactivés** : Les centres d'examen inaccessibles sont affichés en désactivés
- **Notifications email désactivées** : Le système de notifications par email est désactivé (stub seulement)

## Endpoints principaux ajoutés

- **Pré-upload documents** : `POST /api/documents/pre-upload` (multipart) pour le CIN, le type de document (CIN|CV|Diplome), et le fichier
- **Statistiques multi-axes** : `GET /api/candidatures/statistiques/multi?concoursId=`
- **CRUD quotas** : `/api/concours/{concoursId}/centre-specialite` pour la gestion des quotas

## Mapping Exigences -> Implémentations (Août 2025)

| Exigence                                           | Implémentation                                                                      | Endpoints / Fichiers clés                                                                                             |
| -------------------------------------------------- | ----------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------- |
| Pré‑upload documents (CIN, CV, Diplôme)            | Champ `cin_temp`, `candidature_id` nullable, rattachement post création             | `DocumentUploadController.preUpload`, `DocumentService.rattacherPreUploadedDocuments`, scripts DB `init_database.sql` |
| Soumission candidature + retour ID & numéro unique | Génération `numeroUnique`, retour `candidatureId`                                   | `CandidatureController.soumettreCandidate`                                                                            |
| Validation / Rejet avec quotas                     | Réservation place (décrément) + numéro place + rejet avec motif                     | `CandidatureService.validerCandidature`, `rejeterCandidature`, table `centre_specialite` champs quotas                |
| Quotas par centre/spécialité                       | Entité relation `CentreSpecialite` avec `placesOccupees`, `nombrePlacesDisponibles` | Requêtes dans `CandidatureService` / `ConcoursAssociationController`                                                  |
| Statistiques multi-axes                            | Timeline 14j, occupation quotas, complétude docs                                    | `GET /api/candidatures/statistiques/multi`                                                                            |
| Statistiques avancées                              | Par gestionnaire, spécialité, ville (scopées)                                       | `GET /api/candidatures/statistiques/avancees`                                                                         |
| KPIs synthèse & timeline 30j                       | Taux validation, % docs complets, occupation, timeline                              | `GET /api/candidatures/kpi/synthese`, `GET /api/candidatures/kpi/timeline30j`                                         |
| Accès restreint gestionnaire local                 | Filtrage backend centre unique                                                      | Méthodes `ensureCentreAccess`, variantes `...ForUser` dans `CandidatureService`                                       |
| Réponses API unifiées                              | Wrapper `ApiResponse<T>`                                                            | Tous contrôleurs unifiés (candidatures, auth, centres, concours, etc.)                                                |
| Export candidatures CSV                            | Génération dynamique filtrée                                                        | `GET /api/candidatures/export/csv`                                                                                    |
| Export quotas occupation CSV (optionnel)           | Occupation quotas concours/centre/spécialité                                        | `GET /api/candidatures/export/quotas-csv`                                                                             |
| État "Confirmee" après validation                  | Nouveau statut + endpoint confirmation                                              | Enum `Candidature.Etat`, `POST /api/candidatures/{id}/confirmer`                                                      |
| Centres grisées côté gestionnaire local            | Flag `accessible`                                                                   | `CentreController.getAllCentres`                                                                                      |
| Désactivation emails (stub)                        | Service notifications simplifié                                                     | `NotificationService` (stubs)                                                                                         |
| Scripts DB nettoyés & archivés                     | Scripts actifs / archive legacy datée                                               | Dossier `archive_scripts/legacy_20250809`                                                                             |
| Trace des actions gestionnaires                    | Logging actions (validation, rejet, confirmation)                                   | `LogActionService.logAction`                                                                                          |

## Nouveaux Endpoints (ajouts récents)

| Endpoint                              | Méthode | Description                                        |
| ------------------------------------- | ------- | -------------------------------------------------- |
| `/api/candidatures/{id}/confirmer`    | POST    | Confirme une candidature validée (état Confirmee)  |
| `/api/candidatures/export/quotas-csv` | GET     | Export CSV occupation quotas (gestionnaire global) |

## États de la candidature

`Soumise` -> `En_Cours_Validation` -> `Validee` -> `Confirmee` (nouveau) ou `Rejetee`.

La confirmation verrouille la place attribuée (aucun changement de quotas, statut final pour intégration externe).

## Guide Scripts (Final)

| Usage                                | Script                              | Notes                                |
| ------------------------------------ | ----------------------------------- | ------------------------------------ |
| Initialisation complète              | `init_database.sql`                 | Crée schéma + données de base        |
| Données de test                      | `insert_test_data.sql`              | Insère candidats / concours exemples |
| Mise à jour schéma incrémentale      | `update_db.sql`                     | Appliquer après pull code            |
| Lancement application                | `start_app.bat`                     | Démarre backend & (option) frontend  |
| Arrêt application                    | `stop_app.bat`                      | Stop services locaux                 |
| Appliquer changements code (rebuild) | `apply_changes.bat`                 | Clean & rebuild backend              |
| Diagnostic application               | `diagnostic_app.ps1`                | Vérifie services / ports             |
| Export / tests divers (legacy)       | `archive_scripts/legacy_20250809/*` | Référence historique                 |

## Notes de Sécurité

- Accès gestionnaire local strict au centre attribué.
- Statistiques & exports filtrés selon rôle.
- Mots de passe stockés en clair (demande spécifique) – à chiffrer en production.

## Prochaines Améliorations Potentielles

- Moyenne temps de traitement (soumission -> validation -> confirmation).
- Filtrage export quotas par centre/specialite.
- Tests automatisés (JUnit) pour transitions d'états.

# Plateforme Candidature Plus

## Structure Scripts (Nettoyée 2025-08-09)

Première installation:

- init_database.sql
- insert_test_data.sql
- start_app.bat

Utilisation quotidienne:

- start_app.bat
- stop_app.bat

Après modifications du code:

- apply_changes.bat

Après modifications de la base:

- update_db.sql (puis apply_changes.bat si recompilation nécessaire)

Diagnostic:

- diagnostic_app.ps1

Archive des anciens scripts: dossier `archive_scripts/legacy_20250809`
