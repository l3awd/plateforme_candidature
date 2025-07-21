# CandidaturePlus

## Initialisation de l'environnement

### Backend
1. Naviguez dans le dossier `backend`.
2. Exécutez `mvn clean install` pour installer les dépendances Maven.
3. Configurez la base de données MySQL et mettez à jour `application.properties`.

### Frontend
1. Naviguez dans le dossier `frontend`.
2. Exécutez `npm install` pour installer les dépendances Node.js.
3. Lancez le serveur de développement avec `npm start`.

### Base de données
1. Créez une base de données MySQL nommée `candidatureplus`.
2. Flyway gérera les migrations automatiquement au démarrage du backend.

### Dépendances
- Backend : Spring Boot, MySQL, Flyway
- Frontend : React, Material-UI, Axios
