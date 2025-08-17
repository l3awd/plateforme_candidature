# Modifications apportées au projet CandidaturePlus

## Résumé des changements demandés et implémentés

### 1. ✅ Modification du champ "Sexe/Genre" en terme plus professionnel

**Changement :** Remplacé "Genre" par "Civilité" avec les options "Monsieur" et "Madame"

**Fichiers modifiés :**

- `frontend/src/pages/CandidaturePage.js`
  - Label changé de "Genre _" vers "Civilité _"
  - Options changées de "Masculin/Féminin" vers "Monsieur/Madame"
  - Message de validation mis à jour
  - Récapitulatif mis à jour pour afficher la civilité correctement

### 2. ✅ Amélioration du formatage du formulaire

**Changements :**

- Ajout de placeholders informatifs sur tous les champs
- Amélioration des labels (ex: "CIN _" → "Numéro CIN _", "Email _" → "Adresse e-mail _")
- Réorganisation de la section formation pour un meilleur flow
- Réduction des lignes de l'expérience professionnelle (de 4 à 3)
- Ajout de contraintes sur l'année d'obtention (min: 1980, max: année courante)

**Fichiers modifiés :**

- `frontend/src/pages/CandidaturePage.js`

### 3. ✅ Suppression de l'adresse, conservation de la ville avec autocomplete

**Changements :**

- Suppression du champ adresse du formulaire
- Conservation du système d'autocomplete pour les villes du Maroc
- Amélioration du label : "Ville _" → "Ville de résidence _"
- Ajout d'un placeholder informatif

**Fichiers modifiés :**

- `frontend/src/pages/CandidaturePage.js`
- Le fichier `frontend/src/utils/villesMaroc.js` reste inchangé (déjà optimal)

### 4. ✅ Suppression des accents dans les concours + ajout de téléchargement de fiches

**Changements base de données :**

- Modification de la table `Concours` pour ajouter la colonne `fiche_concours_url`
- Mise à jour de tous les textes de concours pour supprimer les accents
- Ajout d'URLs de téléchargement pour chaque concours

**Changements backend :**

- Ajout de la propriété `ficheConcours` dans l'entité `Concours.java`
- Création du contrôleur `DocumentController.java` pour servir les fichiers PDF
- Ajout des fichiers PDF d'exemple dans `src/main/resources/static/documents/fiches/`

**Changements frontend :**

- Ajout du bouton "Télécharger Fiche" sur chaque carte de concours
- Ajout du bouton dans la boîte de dialogue des détails
- Import de l'icône `DownloadIcon`
- Logique de téléchargement automatique des fichiers

**Fichiers modifiés :**

- `create_database.sql`
- `insert_test_data.sql`
- `backend/src/main/java/com/example/candidatureplus/entity/Concours.java`
- `backend/src/main/java/com/example/candidatureplus/controller/DocumentController.java` (nouveau)
- `frontend/src/pages/PostesPage.js`

**Fichiers créés :**

- `backend/src/main/resources/static/documents/fiches/attache-administration-2025.pdf`
- `backend/src/main/resources/static/documents/fiches/inspecteur-finances-2025.pdf`
- `backend/src/main/resources/static/documents/fiches/technicien-informatique-2025.pdf`
- `frontend/public/documents/fiches/` (versions de sauvegarde)

## Scripts utilitaires créés

### `update_modifications.sql`

Script SQL pour appliquer toutes les modifications à une base de données existante :

- Ajout de la colonne `fiche_concours_url`
- Suppression des accents dans les concours et spécialités
- Ajout des URLs de téléchargement

### `apply_modifications.bat`

Script batch pour automatiser l'application de toutes les modifications :

- Exécution du script SQL
- Recompilation du backend
- Mise à jour des dépendances frontend

## Comment utiliser les nouvelles fonctionnalités

### 1. Pour les candidats

- Le formulaire est maintenant plus intuitif avec des placeholders
- Le champ civilité utilise "Monsieur/Madame" au lieu de "Masculin/Féminin"
- Plus besoin de saisir l'adresse complète, juste la ville
- L'autocomplete aide à sélectionner la ville parmi celles du Maroc

### 2. Téléchargement des fiches de concours

- Sur la page `/postes`, chaque concours affiche un bouton "Télécharger Fiche"
- Dans les détails du concours, un bouton permet aussi le téléchargement
- Les fiches contiennent toutes les informations importantes du concours
- Le téléchargement se fait via l'API backend : `GET /api/documents/fiches/{filename}`

### 3. Affichage sans accents

- Tous les noms de concours sont maintenant sans accents
- Cela résout les problèmes d'affichage sur certains systèmes
- Les descriptions et conditions sont également sans accents

## Tests à effectuer

1. **Formulaire de candidature :**

   - Vérifier l'affichage du champ "Civilité"
   - Tester l'autocomplete des villes
   - Vérifier les placeholders
   - Tester la validation du formulaire

2. **Téléchargement de fiches :**

   - Tester le téléchargement depuis la page des postes
   - Tester le téléchargement depuis les détails du concours
   - Vérifier que les fichiers PDF s'ouvrent correctement

3. **Affichage des concours :**
   - Vérifier l'absence d'accents dans tous les textes
   - Contrôler l'affichage correct sur différents navigateurs

## Structure des fichiers créés

```
plateforme_candidature/
├── update_modifications.sql           # Script de mise à jour BDD
├── apply_modifications.bat           # Script d'application automatique
├── backend/
│   └── src/main/
│       ├── java/.../controller/
│       │   └── DocumentController.java    # Nouveau contrôleur
│       ├── java/.../entity/
│       │   └── Concours.java              # Modifié
│       └── resources/static/documents/fiches/
│           ├── attache-administration-2025.pdf
│           ├── inspecteur-finances-2025.pdf
│           └── technicien-informatique-2025.pdf
└── frontend/
    ├── src/pages/
    │   ├── CandidaturePage.js             # Amélioré
    │   └── PostesPage.js                  # Modifié
    └── public/documents/fiches/           # Copies de sauvegarde
        ├── attache-administration-2025.pdf
        ├── inspecteur-finances-2025.pdf
        └── technicien-informatique-2025.pdf
```

## Compatibilité

- ✅ Toutes les fonctionnalités existantes sont préservées
- ✅ Les données existantes restent compatibles
- ✅ L'API REST reste rétrocompatible
- ✅ Aucune rupture dans le workflow utilisateur

Les modifications apportées améliorent significativement l'expérience utilisateur tout en maintenant la robustesse technique du projet.
