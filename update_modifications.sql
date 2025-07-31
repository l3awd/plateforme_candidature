-- Script de mise à jour pour les modifications du projet
-- Ce script applique toutes les modifications demandées
-- 1. Ajouter la colonne fiche_concours_url à la table Concours si elle n'existe pas
-- Vérifier et ajouter la colonne fiche_concours_url
SET @column_exists = (
    SELECT COUNT(*) 
    FROM INFORMATION_SCHEMA.COLUMNS 
    WHERE TABLE_SCHEMA = 'candidature_plus' 
    AND TABLE_NAME = 'Concours' 
    AND COLUMN_NAME = 'fiche_concours_url'
);

SET @sql = IF(@column_exists = 0, 
    'ALTER TABLE Concours ADD COLUMN fiche_concours_url VARCHAR(255)', 
    'SELECT "Column already exists" as message'
);

PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- 2. Mettre à jour les concours existants pour enlever les accents
UPDATE Concours
SET
    nom = 'Concours Attache d Administration - 2025',
    description = 'Recrutement d attaches d administration pour le Ministere de l Economie et des Finances',
    conditions_participation = 'Etre titulaire d un diplome de niveau Bac+3 minimum\nAge maximum: 30 ans\nNationalite marocaine',
    documents_requis = 'Copie legalisee du diplome\nCopie de la CIN\nCV detaille\nPhoto d identite\nCertificat de scolarite',
    fiche_concours_url = 'http://localhost:8080/api/documents/fiches/attache-administration-2025.pdf'
WHERE
    nom LIKE '%Attaché d%Administration%';

UPDATE Concours
SET
    nom = 'Concours Inspecteur des Finances - 2025',
    description = 'Recrutement d inspecteurs des finances pour le controle et l audit',
    conditions_participation = 'Etre titulaire d un diplome de niveau Bac+5 minimum\nSpecialisation en finance, economie ou comptabilite\nAge maximum: 32 ans',
    documents_requis = 'Copie legalisee du diplome\nCopie de la CIN\nCV detaille\nPhoto d identite\nReleve de notes du diplome\nCertificat medical',
    fiche_concours_url = 'http://localhost:8080/api/documents/fiches/inspecteur-finances-2025.pdf'
WHERE
    nom LIKE '%Inspecteur des Finances%';

UPDATE Concours
SET
    nom = 'Concours Technicien Specialise en Informatique - 2025',
    description = 'Recrutement de techniciens specialises en informatique et systemes d information',
    conditions_participation = 'Etre titulaire d un diplome de niveau Bac+2 minimum en informatique\nAge maximum: 28 ans',
    documents_requis = 'Copie legalisee du diplome\nCopie de la CIN\nCV detaille\nPhoto d identite\nCertificats de formation',
    fiche_concours_url = 'http://localhost:8080/api/documents/fiches/technicien-informatique-2025.pdf'
WHERE
    nom LIKE '%Technicien Spécialisé%';

-- 3. Mettre à jour les spécialités pour enlever les accents
UPDATE Specialite
SET
    nom = 'Genie Civil',
    description = 'Construction et travaux publics'
WHERE
    nom = 'Génie Civil';

UPDATE Specialite
SET
    nom = 'Electronique',
    description = 'Systemes electroniques et telecommunications'
WHERE
    nom = 'Électronique';

UPDATE Specialite
SET
    nom = 'Mecanique',
    description = 'Genie mecanique et industriel'
WHERE
    nom = 'Mécanique';

-- 4. Vérification des données mises à jour
SELECT
    'Concours mis à jour:' as message;

SELECT
    id,
    nom,
    fiche_concours_url
FROM
    Concours
WHERE
    actif = true;

SELECT
    'Specialites mises à jour:' as message;

SELECT
    id,
    nom,
    code
FROM
    Specialite
WHERE
    actif = true;