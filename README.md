# CandidaturePlus

## Plateforme de gestion des candidatures aux concours

### Fonctionnalités Candidats Disponibles

#### 🎯 Pour les candidats (sans authentification)
1. **Formulaire de candidature** - `/candidature`
   - Soumission en plusieurs étapes
   - Informations personnelles et formation
   - Choix du concours, spécialité et centre
   - Génération automatique d'un numéro unique

2. **Suivi de candidature** - `/suivi`
   - Recherche par numéro unique
   - Historique détaillé des événements
   - Informations sur l'état de la candidature
   - Détails du concours et centre d'examen

3. **Recherche de postes** - `/postes`
   - Liste des concours ouverts
   - Filtrage par concours, centre et spécialité
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

## Données de test disponibles

### Candidats de test pour le suivi
- **CAND-2025-000001** : Benali Youssef (candidature acceptée)
- **CAND-2025-000002** : Zahra Khadija (candidature rejetée)
- **CAND-2025-000003** : Idrissi Omar (en cours de validation)
- **CAND-2025-000004** : Rhazi Sanaa (soumise)
- **CAND-2025-000005** : Mansouri Rachid (confirmée)

### Concours disponibles
1. **Concours Attaché d'Administration - 2025**
   - Ouvert du 15/01/2025 au 15/03/2025
   - Examen le 20/04/2025
   - Spécialités : Économie, Comptabilité, Droit Public

2. **Concours Inspecteur des Finances - 2025**
   - Ouvert du 01/02/2025 au 01/04/2025
   - Examen le 10/05/2025
   - Spécialités : Comptabilité, Statistiques

3. **Concours Technicien Spécialisé en Informatique - 2025**
   - Ouvert du 20/01/2025 au 20/03/2025
   - Examen le 25/04/2025
   - Spécialité : Informatique de Gestion

### Centres d'examen
- Casablanca, Rabat, Fès, Marrakech, Agadir

### Gestionnaires de test
- **h.alami@mf.gov.ma** : Gestionnaire Local (Casablanca)
- **f.bennani@mf.gov.ma** : Gestionnaire Local (Rabat)
- **m.chraibi@mf.gov.ma** : Gestionnaire Global
- **a.talbi@mf.gov.ma** : Administrateur

## URLs de l'application

| Service | URL | Description |
|---------|-----|-------------|
| **Frontend** | http://localhost:3000 | Interface utilisateur React |
| **Backend API** | http://localhost:8080 | API REST Spring Boot |
| **Base de données** | localhost:3306 | MySQL Server |

## Technologies utilisées

### Front-end : React
- React : Interface utilisateur dynamique
- React Router : Gestion de la navigation
- Material-UI : Composants design moderne
- Formik + Yup : Gestion des formulaires et validation
- Axios : Consommation des API REST

### Back-end : Spring Boot
- Spring Boot : Framework robuste
- Spring Data JPA : Persistance et ORM
- Spring Security : Authentification et autorisation
- Spring Web : Services REST
- Lombok : Réduction du code boilerplate
- MySQL : Base de données relationnelle

## Architecture

L'application suit une architecture moderne avec :
- **Frontend React** : Interface utilisateur responsive
- **Backend Spring Boot** : API REST sécurisée
- **Base de données MySQL** : Stockage persistant
- **Architecture en couches** : Contrôleurs, Services, Repositories, Entités
