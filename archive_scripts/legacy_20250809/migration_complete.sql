-- =====================================================
-- MIGRATION COMPLÈTE CandidaturePlus v2.0
-- =====================================================
-- 1. AJOUT DE NOUVELLES COLONNES
-- ================================================
-- Candidat: Lieu de naissance
ALTER TABLE Candidat
ADD COLUMN lieu_naissance VARCHAR(100);

-- Candidature: Upload CV
ALTER TABLE Candidature
ADD COLUMN cv_fichier VARCHAR(255);

ALTER TABLE Candidature
ADD COLUMN cv_type VARCHAR(50);

ALTER TABLE Candidature
ADD COLUMN cv_taille_octets BIGINT;

-- Utilisateur: Association aux centres
ALTER TABLE Utilisateur
ADD COLUMN centres_assignes TEXT;

-- JSON des IDs centres
-- 2. NOUVELLES TABLES
-- ================================================
-- Spécialités par concours
CREATE TABLE
    IF NOT EXISTS ConcourSpecialite (
        id INT AUTO_INCREMENT PRIMARY KEY,
        concours_id INT NOT NULL,
        specialite_id INT NOT NULL,
        places_disponibles INT DEFAULT 50,
        date_creation TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (concours_id) REFERENCES Concours (id),
        FOREIGN KEY (specialite_id) REFERENCES Specialite (id),
        UNIQUE KEY unique_concours_specialite (concours_id, specialite_id)
    );

-- Centres par concours
CREATE TABLE
    IF NOT EXISTS ConcoursCentre (
        id INT AUTO_INCREMENT PRIMARY KEY,
        concours_id INT NOT NULL,
        centre_id INT NOT NULL,
        places_disponibles INT DEFAULT 100,
        date_creation TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (concours_id) REFERENCES Concours (id),
        FOREIGN KEY (centre_id) REFERENCES Centre (id),
        UNIQUE KEY unique_concours_centre (concours_id, centre_id)
    );

-- 3. DONNÉES DE TEST
-- ================================================
-- Villes du Maroc (lieu de naissance)
INSERT IGNORE INTO ville_maroc (nom)
VALUES
    ('Casablanca'),
    ('Rabat'),
    ('Fès'),
    ('Marrakech'),
    ('Agadir'),
    ('Tangier'),
    ('Meknès'),
    ('Oujda'),
    ('Kenitra'),
    ('Tétouan'),
    ('Safi'),
    ('Mohammedia'),
    ('Khouribga'),
    ('Beni Mellal'),
    ('El Jadida'),
    ('Nador'),
    ('Taza'),
    ('Settat'),
    ('Larache'),
    ('Khemisset');

-- Association concours-spécialités
INSERT INTO
    ConcourSpecialite (concours_id, specialite_id, places_disponibles)
VALUES
    -- Attaché Administration (ID: 1)
    (1, 1, 30), -- Droit Public
    (1, 2, 20), -- Sciences Politiques  
    (1, 3, 25), -- Économie
    -- Inspecteur Finances (ID: 2)  
    (2, 3, 40), -- Économie
    (2, 4, 35), -- Gestion
    (2, 12, 25), -- Comptabilité
    -- Technicien Informatique (ID: 3)
    (3, 5, 50), -- Informatique
    (3, 13, 30), -- Réseaux
    (3, 14, 20);

-- Systèmes
-- Association concours-centres
INSERT INTO
    ConcoursCentre (concours_id, centre_id, places_disponibles)
VALUES
    -- Tous les concours dans tous les centres
    (1, 1, 40),
    (1, 2, 35),
    (1, 3, 30),
    (1, 4, 25),
    (1, 5, 20), -- Attaché Administration
    (2, 1, 35),
    (2, 2, 40),
    (2, 3, 25),
    (2, 4, 30),
    (2, 5, 15), -- Inspecteur Finances  
    (3, 1, 50),
    (3, 2, 45),
    (3, 3, 35),
    (3, 4, 30),
    (3, 5, 25);

-- Technicien Informatique
-- 4. MISE À JOUR DES GESTIONNAIRES
-- ================================================
-- Attribution centres aux gestionnaires locaux
UPDATE Utilisateur
SET
    centres_assignes = '[2]'
WHERE
    email = 'f.bennani@mf.gov.ma';

-- Rabat
UPDATE Utilisateur
SET
    centres_assignes = '[1]'
WHERE
    email = 'h.alami@mf.gov.ma';

-- Casablanca
-- Gestionnaires globaux : accès à tous les centres
UPDATE Utilisateur
SET
    centres_assignes = '[1,2,3,4,5]'
WHERE
    role = 'GestionnaireGlobal';

UPDATE Utilisateur
SET
    centres_assignes = '[1,2,3,4,5]'
WHERE
    role = 'Administrateur';

-- 5. NOUVELLES SPÉCIALITÉS
-- ================================================
INSERT IGNORE INTO Specialite (nom, domaine, actif)
VALUES
    (
        'Réseaux et Télécommunications',
        'Informatique',
        1
    ),
    ('Administration Systèmes', 'Informatique', 1),
    ('Marketing Digital', 'Commerce', 1),
    ('Ressources Humaines', 'Gestion', 1),
    ('Audit et Contrôle', 'Finance', 1),
    ('Communication', 'Sciences Sociales', 1);

-- 6. VÉRIFICATIONS
-- ================================================
-- Vérifier les contraintes
SELECT
    'Concours-Spécialités' as 'Table',
    COUNT(*) as 'Lignes'
FROM
    ConcourSpecialite
UNION ALL
SELECT
    'Concours-Centres',
    COUNT(*)
FROM
    ConcoursCentre
UNION ALL
SELECT
    'Utilisateurs avec centres',
    COUNT(*)
FROM
    Utilisateur
WHERE
    centres_assignes IS NOT NULL;

COMMIT;