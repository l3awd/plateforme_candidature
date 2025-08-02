-- =========================================
-- Script de mise à jour de la base de données CandidaturePlus
-- Ce script applique les modifications nécessaires sans perdre les données
-- =========================================

USE candidature_plus;

-- =========================================
-- MISE À JOUR DE LA STRUCTURE
-- =========================================

-- Vérifier et ajouter le champ places_occupees si manquant
SET @sql = (
    SELECT IF(
        (SELECT COUNT(*) FROM information_schema.columns 
         WHERE table_schema = 'candidature_plus' 
         AND table_name = 'Centre_Specialite' 
         AND column_name = 'places_occupees') = 0,
        'ALTER TABLE Centre_Specialite ADD COLUMN places_occupees INT DEFAULT 0;',
        'SELECT "Colonne places_occupees déjà présente" as status;'
    )
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Vérifier et créer la table Log_Action si manquante
SET @sql = (
    SELECT IF(
        (SELECT COUNT(*) FROM information_schema.tables 
         WHERE table_schema = 'candidature_plus' 
         AND table_name = 'Log_Action') = 0,
        'CREATE TABLE Log_Action (
            id INT AUTO_INCREMENT PRIMARY KEY,
            type_acteur ENUM(''Candidat'', ''Utilisateur'', ''Systeme'') NOT NULL,
            acteur_id INT NULL,
            action VARCHAR(100) NOT NULL,
            table_cible VARCHAR(50),
            enregistrement_id INT,
            details JSON,
            ip_adresse VARCHAR(45),
            user_agent TEXT,
            date_action TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        );',
        'SELECT "Table Log_Action déjà présente" as status;'
    )
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Vérifier et créer la table Notification si manquante
SET @sql = (
    SELECT IF(
        (SELECT COUNT(*) FROM information_schema.tables 
         WHERE table_schema = 'candidature_plus' 
         AND table_name = 'Notification') = 0,
        'CREATE TABLE Notification (
            id INT AUTO_INCREMENT PRIMARY KEY,
            type_destinataire ENUM(''Candidat'', ''Utilisateur'') NOT NULL,
            destinataire_id INT NOT NULL,
            type_notification ENUM(''Email'', ''SMS'', ''Systeme'') NOT NULL,
            sujet VARCHAR(200),
            message TEXT NOT NULL,
            etat ENUM(''En_Attente'', ''Envoye'', ''Echec'') DEFAULT ''En_Attente'',
            date_creation TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            date_envoi TIMESTAMP NULL,
            tentatives_envoi INT DEFAULT 0,
            erreur_envoi TEXT
        );',
        'SELECT "Table Notification déjà présente" as status;'
    )
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Vérifier et mettre à jour l'ENUM de la table Candidature
SET @sql = (
    SELECT IF(
        (SELECT COLUMN_TYPE FROM information_schema.columns 
         WHERE table_schema = 'candidature_plus' 
         AND table_name = 'Candidature' 
         AND column_name = 'etat') LIKE '%Confirmee%',
        'SELECT "ENUM Candidature déjà à jour" as status;',
        'ALTER TABLE Candidature MODIFY COLUMN etat ENUM(''Soumise'', ''En_Cours_Validation'', ''Validee'', ''Rejetee'', ''Confirmee'') DEFAULT ''Soumise'';'
    )
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- =========================================
-- MISE À JOUR DES MOTS DE PASSE BCrypt
-- =========================================

-- Mettre à jour uniquement les mots de passe qui ne sont pas déjà au format BCrypt
UPDATE Utilisateur 
SET mot_de_passe = '$2a$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewRqGCaVeDqHOvfK'
WHERE mot_de_passe NOT LIKE '$2a$12$%';

-- =========================================
-- CRÉATION DES INDEX POUR PERFORMANCES (si manquants)
-- =========================================

-- Index pour candidatures
SET @sql = (
    SELECT IF(
        (SELECT COUNT(*) FROM information_schema.statistics 
         WHERE table_schema = 'candidature_plus' 
         AND table_name = 'Candidature' 
         AND index_name = 'idx_candidature_etat') = 0,
        'CREATE INDEX idx_candidature_etat ON Candidature(etat);',
        'SELECT "Index candidature_etat déjà présent" as status;'
    )
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @sql = (
    SELECT IF(
        (SELECT COUNT(*) FROM information_schema.statistics 
         WHERE table_schema = 'candidature_plus' 
         AND table_name = 'Candidature' 
         AND index_name = 'idx_candidature_date') = 0,
        'CREATE INDEX idx_candidature_date ON Candidature(date_soumission);',
        'SELECT "Index candidature_date déjà présent" as status;'
    )
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Index pour candidats
SET @sql = (
    SELECT IF(
        (SELECT COUNT(*) FROM information_schema.statistics 
         WHERE table_schema = 'candidature_plus' 
         AND table_name = 'Candidat' 
         AND index_name = 'idx_candidat_numero') = 0,
        'CREATE INDEX idx_candidat_numero ON Candidat(numero_unique);',
        'SELECT "Index candidat_numero déjà présent" as status;'
    )
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- =========================================
-- CRÉATION DES TRIGGERS (si manquants)
-- =========================================

-- Supprimer les triggers existants s'ils existent
DROP TRIGGER IF EXISTS tr_candidature_update;
DROP TRIGGER IF EXISTS tr_candidature_insert;

-- Recréer les triggers
DELIMITER $$

-- Trigger pour enregistrer les modifications de candidatures
CREATE TRIGGER tr_candidature_update
AFTER UPDATE ON Candidature
FOR EACH ROW
BEGIN
    IF OLD.etat != NEW.etat THEN
        INSERT INTO Log_Action (type_acteur, acteur_id, action, table_cible, enregistrement_id, details, date_action)
        VALUES ('Utilisateur', NEW.gestionnaire_id, 'CHANGEMENT_ETAT', 'Candidature', NEW.id, 
                JSON_OBJECT('ancien_etat', OLD.etat, 'nouvel_etat', NEW.etat, 'commentaire', NEW.commentaire_gestionnaire), NOW());
    END IF;
END$$

-- Trigger pour enregistrer les nouvelles candidatures  
CREATE TRIGGER tr_candidature_insert
AFTER INSERT ON Candidature
FOR EACH ROW
BEGIN
    INSERT INTO Log_Action (type_acteur, acteur_id, action, table_cible, enregistrement_id, details, date_action)
    VALUES ('Candidat', NEW.candidat_id, 'NOUVELLE_CANDIDATURE', 'Candidature', NEW.id,
            JSON_OBJECT('concours_id', NEW.concours_id, 'centre_id', NEW.centre_id), NOW());
END$$

DELIMITER ;

-- =========================================
-- CRÉATION DES VUES (si manquantes)
-- =========================================

-- Supprimer et recréer la vue des candidatures complètes
DROP VIEW IF EXISTS v_candidatures_completes;

CREATE VIEW v_candidatures_completes AS
SELECT 
    c.id,
    c.etat,
    c.date_soumission,
    c.date_traitement,
    c.numero_place,
    c.motif_rejet,
    c.commentaire_gestionnaire,
    cand.numero_unique,
    cand.nom,
    cand.prenom,
    cand.email,
    cand.cin,
    conc.nom AS concours_nom,
    spec.nom AS specialite_nom,
    cent.nom AS centre_nom,
    cent.ville AS centre_ville,
    u.nom AS gestionnaire_nom,
    u.prenom AS gestionnaire_prenom
FROM Candidature c
JOIN Candidat cand ON c.candidat_id = cand.id
JOIN Concours conc ON c.concours_id = conc.id
JOIN Specialite spec ON c.specialite_id = spec.id
JOIN Centre cent ON c.centre_id = cent.id
LEFT JOIN Utilisateur u ON c.gestionnaire_id = u.id;

-- Vue pour les statistiques par centre
DROP VIEW IF EXISTS v_statistiques_centre;

CREATE VIEW v_statistiques_centre AS
SELECT 
    cent.id AS centre_id,
    cent.nom AS centre_nom,
    cent.ville,
    COUNT(c.id) AS total_candidatures,
    COUNT(CASE WHEN c.etat = 'Soumise' THEN 1 END) AS candidatures_soumises,
    COUNT(CASE WHEN c.etat = 'En_Cours_Validation' THEN 1 END) AS candidatures_en_cours,
    COUNT(CASE WHEN c.etat = 'Validee' THEN 1 END) AS candidatures_validees,
    COUNT(CASE WHEN c.etat = 'Rejetee' THEN 1 END) AS candidatures_rejetees,
    COUNT(CASE WHEN c.etat = 'Confirmee' THEN 1 END) AS candidatures_confirmees
FROM Centre cent
LEFT JOIN Candidature c ON cent.id = c.centre_id
WHERE cent.actif = TRUE
GROUP BY cent.id, cent.nom, cent.ville;

-- =========================================
-- VÉRIFICATION FINALE
-- =========================================

SELECT 
    'Mise à jour appliquée avec succès!' AS status,
    NOW() AS date_mise_a_jour;

SELECT 
    'Vérification des tables:' AS verification;

SELECT 
    table_name AS 'Tables présentes',
    CASE 
        WHEN table_name IN ('Log_Action', 'Notification') THEN '✅ Nouvelle fonctionnalité'
        ELSE '✅ Table standard'
    END AS 'Status'
FROM information_schema.tables 
WHERE table_schema = 'candidature_plus'
ORDER BY table_name;
