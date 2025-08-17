-- =====================================================
-- MIGRATION SIMPLIFIÉE CandidaturePlus v2.0
-- Ajout uniquement des éléments manquants
-- =====================================================

-- 1. NOUVELLES TABLES
-- ================================================

-- Spécialités par concours
CREATE TABLE IF NOT EXISTS ConcourSpecialite (
    id INT AUTO_INCREMENT PRIMARY KEY,
    concours_id INT NOT NULL,
    specialite_id INT NOT NULL,
    places_disponibles INT DEFAULT 50,
    date_creation TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (concours_id) REFERENCES Concours(id),
    FOREIGN KEY (specialite_id) REFERENCES Specialite(id),
    UNIQUE KEY unique_concours_specialite (concours_id, specialite_id)
);

-- Centres par concours
CREATE TABLE IF NOT EXISTS ConcoursCentre (
    id INT AUTO_INCREMENT PRIMARY KEY,
    concours_id INT NOT NULL,
    centre_id INT NOT NULL,
    places_disponibles INT DEFAULT 100,
    date_creation TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (concours_id) REFERENCES Concours(id),
    FOREIGN KEY (centre_id) REFERENCES Centre(id),
    UNIQUE KEY unique_concours_centre (concours_id, centre_id)
);

-- 2. AJOUT DE COLONNES MANQUANTES
-- ================================================

-- Vérifier et ajouter la colonne centres_assignes si elle n'existe pas
SET @column_exists = (
    SELECT COUNT(*)
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = 'candidature_plus'
    AND TABLE_NAME = 'Utilisateur'
    AND COLUMN_NAME = 'centres_assignes'
);

SET @sql = IF(@column_exists = 0, 
    'ALTER TABLE Utilisateur ADD COLUMN centres_assignes TEXT;', 
    'SELECT "Column centres_assignes already exists" as message;'
);

PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- 3. DONNÉES DE TEST
-- ================================================

-- Associer spécialités aux concours
INSERT IGNORE INTO ConcourSpecialite (concours_id, specialite_id, places_disponibles)
SELECT c.id, s.id, 25
FROM Concours c
CROSS JOIN Specialite s
WHERE c.actif = 1
LIMIT 10;

-- Associer centres aux concours
INSERT IGNORE INTO ConcoursCentre (concours_id, centre_id, places_disponibles)
SELECT c.id, ce.id, 50
FROM Concours c
CROSS JOIN Centre ce
WHERE c.actif = 1
LIMIT 15;

-- Mise à jour des gestionnaires avec centres assignés
UPDATE Utilisateur 
SET centres_assignes = '["1","2","3"]'
WHERE role = 'gestionnaire_local' AND centres_assignes IS NULL;

-- 4. MISE À JOUR DES CONCOURS ACTIFS
-- ================================================

-- S'assurer qu'il y a des concours actifs avec dates futures
UPDATE Concours 
SET 
    date_fin_candidature = DATE_ADD(CURDATE(), INTERVAL 30 DAY),
    actif = 1
WHERE date_fin_candidature < CURDATE();

-- =====================================================
-- MIGRATION TERMINÉE
-- =====================================================
