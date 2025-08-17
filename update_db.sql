-- =========================================
-- Script de mise à jour de la base de données CandidaturePlus
-- Ce script applique les modifications nécessaires sans perdre les données
-- =========================================

USE candidature_plus;

-- =========================================
-- NETTOYAGE / MIGRATION LEGACY (doublons)
-- =========================================
-- Migration éventuelle des données depuis l'ancienne table mal nommée `ConcourSpecialite`
-- vers la table normalisée `Concours_Specialite`, puis suppression.
-- (Empêche la coexistence de deux structures représentant la même association.)
SET @sql = (
    SELECT IF(
        (SELECT COUNT(*) FROM information_schema.tables 
         WHERE table_schema = 'candidature_plus' 
           AND table_name = 'ConcourSpecialite') > 0,
        'INSERT IGNORE INTO Concours_Specialite (concours_id, specialite_id, nombre_places)\n            SELECT csp.concours_id, csp.specialite_id, COALESCE(csp.places_disponibles,0)\n            FROM ConcourSpecialite csp\n            LEFT JOIN Concours_Specialite cs ON cs.concours_id = csp.concours_id AND cs.specialite_id = csp.specialite_id;','SELECT "Table ConcourSpecialite absente (migration non nécessaire)" as status;'
    )
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- Suppression conditionnelle de la table legacy
SET @sql = (
    SELECT IF(
        (SELECT COUNT(*) FROM information_schema.tables 
         WHERE table_schema = 'candidature_plus' 
           AND table_name = 'ConcourSpecialite') > 0,
        'DROP TABLE ConcourSpecialite;','SELECT "Table ConcourSpecialite déjà absente" as status;'
    )
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- =========================================
-- MISE À JOUR DE LA STRUCTURE
-- =========================================

-- Harmoniser enum genre (Masculin/Feminin)
SET @sql = (
    SELECT IF(
        (SELECT COLUMN_TYPE FROM information_schema.columns WHERE table_schema='candidature_plus' AND table_name='Candidat' AND column_name='genre') LIKE '%Masculin%',
        'SELECT "Enum genre déjà correct" as status;',
        'ALTER TABLE Candidat MODIFY COLUMN genre ENUM(''Masculin'', ''Feminin'') NOT NULL;'
    )
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Vérifier et ajouter le champ places_occupees si manquant (compteur utilisé pour numéro de place)
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
-- NOUVELLES TABLES (Etape 2) - création sans FKs (ajoutées étape 3)
-- =========================================
-- Table pivot multi-centres pour les utilisateurs
SET @sql = (
    SELECT IF(
        (SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='candidature_plus' AND table_name='Utilisateur_Centre')=0,
        'CREATE TABLE Utilisateur_Centre (\n            id INT AUTO_INCREMENT PRIMARY KEY,\n            utilisateur_id INT NOT NULL,\n            centre_id INT NOT NULL,\n            actif BOOLEAN DEFAULT TRUE,\n            date_attribution TIMESTAMP DEFAULT CURRENT_TIMESTAMP,\n            UNIQUE KEY uk_utilisateur_centre (utilisateur_id, centre_id)\n        );',
        'SELECT "Table Utilisateur_Centre déjà présente" as status;'
    )
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- Table Parametre (configuration clé/valeur)
SET @sql = (
    SELECT IF(
        (SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='candidature_plus' AND table_name='Parametre')=0,
        'CREATE TABLE Parametre (\n            id INT AUTO_INCREMENT PRIMARY KEY,\n            cle VARCHAR(150) NOT NULL UNIQUE,\n            valeur TEXT NULL,\n            description VARCHAR(300) NULL,\n            actif BOOLEAN DEFAULT TRUE,\n            date_creation TIMESTAMP DEFAULT CURRENT_TIMESTAMP\n        );',
        'SELECT "Table Parametre déjà présente" as status;'
    )
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- Table Permission (catalogue des permissions fines)
SET @sql = (
    SELECT IF(
        (SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='candidature_plus' AND table_name='Permission')=0,
        'CREATE TABLE Permission (\n            id INT AUTO_INCREMENT PRIMARY KEY,\n            code VARCHAR(120) NOT NULL UNIQUE,\n            description VARCHAR(300) NULL,\n            actif BOOLEAN DEFAULT TRUE,\n            date_creation TIMESTAMP DEFAULT CURRENT_TIMESTAMP\n        );',
        'SELECT "Table Permission déjà présente" as status;'
    )
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- Table Role_Permission (association rôle -> permission)
SET @sql = (
    SELECT IF(
        (SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='candidature_plus' AND table_name='Role_Permission')=0,
        'CREATE TABLE Role_Permission (\n            id INT AUTO_INCREMENT PRIMARY KEY,\n            role ENUM(''GestionnaireLocal'',''GestionnaireGlobal'',''Administrateur'') NOT NULL,\n            permission_id INT NOT NULL,\n            date_attribution TIMESTAMP DEFAULT CURRENT_TIMESTAMP,\n            UNIQUE KEY uk_role_permission (role, permission_id)\n        );',
        'SELECT "Table Role_Permission déjà présente" as status;'
    )
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- Table Resultat_Concours (résultats et décisions)
SET @sql = (
    SELECT IF(
        (SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='candidature_plus' AND table_name='Resultat_Concours')=0,
        'CREATE TABLE Resultat_Concours (\n            id INT AUTO_INCREMENT PRIMARY KEY,\n            concours_id INT NOT NULL,\n            candidat_id INT NOT NULL,\n            specialite_id INT NULL,\n            centre_id INT NULL,\n            etat_resultat ENUM(''Admis'',''Liste_Attente'',''Non_Admis'') NOT NULL,\n            note DECIMAL(5,2) NULL,\n            rang INT NULL,\n            commentaire VARCHAR(300) NULL,\n            date_publication TIMESTAMP DEFAULT CURRENT_TIMESTAMP,\n            UNIQUE KEY uk_resultat_concours_candidat (concours_id, candidat_id)\n        );',
        'SELECT "Table Resultat_Concours déjà présente" as status;'
    )
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- Table Document_Audit (journalisation fine des documents)
SET @sql = (
    SELECT IF(
        (SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='candidature_plus' AND table_name='Document_Audit')=0,
        'CREATE TABLE Document_Audit (\n            id INT AUTO_INCREMENT PRIMARY KEY,\n            document_id INT NULL,\n            candidature_id INT NULL,\n            type_action ENUM(''UPLOAD'',''UPDATE'',''DELETE'',''ASSOCIER'',''DESASSOCIER'') NOT NULL,\n            type_document VARCHAR(40) NULL,\n            nom_fichier VARCHAR(255) NULL,\n            taille BIGINT NULL,\n            utilisateur_id INT NULL,\n            candidat_id INT NULL,\n            ip_adresse VARCHAR(45) NULL,\n            user_agent TEXT NULL,\n            date_action TIMESTAMP DEFAULT CURRENT_TIMESTAMP\n        );',
        'SELECT "Table Document_Audit déjà présente" as status;'
    )
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- =========================================
-- NOTE: Suppression de la mise à jour BCrypt (mots de passe conservés en clair selon exigences)
-- =========================================

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

DROP TRIGGER IF EXISTS tr_candidature_update;
DROP TRIGGER IF EXISTS tr_candidature_insert;

DELIMITER $$
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

-- Ajout colonne cin_temp pour pré-upload documents si manquante
SET @sql = (
    SELECT IF(
        (SELECT COUNT(*) FROM information_schema.columns 
         WHERE table_schema = 'candidature_plus' 
         AND table_name = 'Document' 
         AND column_name = 'cin_temp') = 0,
        'ALTER TABLE Document ADD COLUMN cin_temp VARCHAR(20) NULL AFTER candidature_id;',
        'SELECT "Colonne cin_temp déjà présente" as status;'
    )
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- Rendre candidature_id nullable dans Document pour pré-upload
SET @sql = (
    SELECT IF(
        (SELECT IS_NULLABLE FROM information_schema.columns WHERE table_schema='candidature_plus' AND table_name='Document' AND column_name='candidature_id')='YES',
        'SELECT "candidature_id déjà nullable" as status;',
        'ALTER TABLE Document MODIFY candidature_id INT NULL;'
    )
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- =========================================
-- ETAPE 3 : AJOUT DES CLES ETRANGERES & INDEX POUR LES NOUVELLES TABLES
-- =========================================
-- Utilisateur_Centre : FK utilisateur
SET @sql = (
    SELECT IF(
        (SELECT COUNT(*) FROM information_schema.table_constraints 
            WHERE table_schema='candidature_plus' AND table_name='Utilisateur_Centre' AND constraint_name='fk_uc_utilisateur') = 0,
        'ALTER TABLE Utilisateur_Centre ADD CONSTRAINT fk_uc_utilisateur FOREIGN KEY (utilisateur_id) REFERENCES Utilisateur(id) ON DELETE CASCADE;','SELECT "FK fk_uc_utilisateur déjà présente" as status;'
    )
); PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;
-- Utilisateur_Centre : FK centre
SET @sql = (
    SELECT IF(
        (SELECT COUNT(*) FROM information_schema.table_constraints 
            WHERE table_schema='candidature_plus' AND table_name='Utilisateur_Centre' AND constraint_name='fk_uc_centre') = 0,
        'ALTER TABLE Utilisateur_Centre ADD CONSTRAINT fk_uc_centre FOREIGN KEY (centre_id) REFERENCES Centre(id) ON DELETE CASCADE;','SELECT "FK fk_uc_centre déjà présente" as status;'
    )
); PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- Role_Permission : FK permission
SET @sql = (
    SELECT IF(
        (SELECT COUNT(*) FROM information_schema.table_constraints 
            WHERE table_schema='candidature_plus' AND table_name='Role_Permission' AND constraint_name='fk_rp_permission') = 0,
        'ALTER TABLE Role_Permission ADD CONSTRAINT fk_rp_permission FOREIGN KEY (permission_id) REFERENCES Permission(id) ON DELETE CASCADE;','SELECT "FK fk_rp_permission déjà présente" as status;'
    )
); PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- Resultat_Concours : FKs (concours, candidat, specialite, centre)
SET @sql = (
    SELECT IF((SELECT COUNT(*) FROM information_schema.table_constraints WHERE table_schema='candidature_plus' AND table_name='Resultat_Concours' AND constraint_name='fk_rc_concours')=0,
        'ALTER TABLE Resultat_Concours ADD CONSTRAINT fk_rc_concours FOREIGN KEY (concours_id) REFERENCES Concours(id) ON DELETE CASCADE;','SELECT "FK fk_rc_concours déjà présente" as status;')
); PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;
SET @sql = (
    SELECT IF((SELECT COUNT(*) FROM information_schema.table_constraints WHERE table_schema='candidature_plus' AND table_name='Resultat_Concours' AND constraint_name='fk_rc_candidat')=0,
        'ALTER TABLE Resultat_Concours ADD CONSTRAINT fk_rc_candidat FOREIGN KEY (candidat_id) REFERENCES Candidat(id) ON DELETE CASCADE;','SELECT "FK fk_rc_candidat déjà présente" as status;')
); PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;
SET @sql = (
    SELECT IF((SELECT COUNT(*) FROM information_schema.table_constraints WHERE table_schema='candidature_plus' AND table_name='Resultat_Concours' AND constraint_name='fk_rc_specialite')=0,
        'ALTER TABLE Resultat_Concours ADD CONSTRAINT fk_rc_specialite FOREIGN KEY (specialite_id) REFERENCES Specialite(id) ON DELETE SET NULL;','SELECT "FK fk_rc_specialite déjà présente" as status;')
); PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;
SET @sql = (
    SELECT IF((SELECT COUNT(*) FROM information_schema.table_constraints WHERE table_schema='candidature_plus' AND table_name='Resultat_Concours' AND constraint_name='fk_rc_centre')=0,
        'ALTER TABLE Resultat_Concours ADD CONSTRAINT fk_rc_centre FOREIGN KEY (centre_id) REFERENCES Centre(id) ON DELETE SET NULL;','SELECT "FK fk_rc_centre déjà présente" as status;')
); PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- Document_Audit : FKs (document, candidature, utilisateur, candidat)
SET @sql = (
    SELECT IF((SELECT COUNT(*) FROM information_schema.table_constraints WHERE table_schema='candidature_plus' AND table_name='Document_Audit' AND constraint_name='fk_da_document')=0,
        'ALTER TABLE Document_Audit ADD CONSTRAINT fk_da_document FOREIGN KEY (document_id) REFERENCES Document(id) ON DELETE SET NULL;','SELECT "FK fk_da_document déjà présente" as status;')
); PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;
SET @sql = (
    SELECT IF((SELECT COUNT(*) FROM information_schema.table_constraints WHERE table_schema='candidature_plus' AND table_name='Document_Audit' AND constraint_name='fk_da_candidature')=0,
        'ALTER TABLE Document_Audit ADD CONSTRAINT fk_da_candidature FOREIGN KEY (candidature_id) REFERENCES Candidature(id) ON DELETE SET NULL;','SELECT "FK fk_da_candidature déjà présente" as status;')
); PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;
SET @sql = (
    SELECT IF((SELECT COUNT(*) FROM information_schema.table_constraints WHERE table_schema='candidature_plus' AND table_name='Document_Audit' AND constraint_name='fk_da_utilisateur')=0,
        'ALTER TABLE Document_Audit ADD CONSTRAINT fk_da_utilisateur FOREIGN KEY (utilisateur_id) REFERENCES Utilisateur(id) ON DELETE SET NULL;','SELECT "FK fk_da_utilisateur déjà présente" as status;')
); PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;
SET @sql = (
    SELECT IF((SELECT COUNT(*) FROM information_schema.table_constraints WHERE table_schema='candidature_plus' AND table_name='Document_Audit' AND constraint_name='fk_da_candidat')=0,
        'ALTER TABLE Document_Audit ADD CONSTRAINT fk_da_candidat FOREIGN KEY (candidat_id) REFERENCES Candidat(id) ON DELETE SET NULL;','SELECT "FK fk_da_candidat déjà présente" as status;')
); PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- Index supplémentaires (idempotents)
SET @sql = (SELECT IF((SELECT COUNT(*) FROM information_schema.statistics WHERE table_schema='candidature_plus' AND table_name='Utilisateur_Centre' AND index_name='idx_uc_user')=0,
    'CREATE INDEX idx_uc_user ON Utilisateur_Centre(utilisateur_id);','SELECT "Index idx_uc_user déjà présent" as status;'));
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;
SET @sql = (SELECT IF((SELECT COUNT(*) FROM information_schema.statistics WHERE table_schema='candidature_plus' AND table_name='Utilisateur_Centre' AND index_name='idx_uc_centre')=0,
    'CREATE INDEX idx_uc_centre ON Utilisateur_Centre(centre_id);','SELECT "Index idx_uc_centre déjà présent" as status;'));
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;
SET @sql = (SELECT IF((SELECT COUNT(*) FROM information_schema.statistics WHERE table_schema='candidature_plus' AND table_name='Resultat_Concours' AND index_name='idx_rc_concours')=0,
    'CREATE INDEX idx_rc_concours ON Resultat_Concours(concours_id);','SELECT "Index idx_rc_concours déjà présent" as status;'));
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;
SET @sql = (SELECT IF((SELECT COUNT(*) FROM information_schema.statistics WHERE table_schema='candidature_plus' AND table_name='Resultat_Concours' AND index_name='idx_rc_candidat')=0,
    'CREATE INDEX idx_rc_candidat ON Resultat_Concours(candidat_id);','SELECT "Index idx_rc_candidat déjà présent" as status;'));
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;
SET @sql = (SELECT IF((SELECT COUNT(*) FROM information_schema.statistics WHERE table_schema='candidature_plus' AND table_name='Document_Audit' AND index_name='idx_da_document')=0,
    'CREATE INDEX idx_da_document ON Document_Audit(document_id);','SELECT "Index idx_da_document déjà présent" as status;'));
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;
SET @sql = (SELECT IF((SELECT COUNT(*) FROM information_schema.statistics WHERE table_schema='candidature_plus' AND table_name='Document_Audit' AND index_name='idx_da_candidature')=0,
    'CREATE INDEX idx_da_candidature ON Document_Audit(candidature_id);','SELECT "Index idx_da_candidature déjà présent" as status;'));
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;
-- Fin étape 3
-- =========================================
-- ETAPE 4 : TRIGGERS D'AUDIT DOCUMENTS (recréés idempotents)
-- =========================================
DROP TRIGGER IF EXISTS tr_document_insert;
DROP TRIGGER IF EXISTS tr_document_update;
DROP TRIGGER IF EXISTS tr_document_delete;
DELIMITER $$
CREATE TRIGGER tr_document_insert
AFTER INSERT ON Document
FOR EACH ROW
BEGIN
    INSERT INTO Document_Audit (document_id, candidature_id, type_action, type_document, nom_fichier, taille, utilisateur_id, candidat_id, ip_adresse, user_agent)
    VALUES (NEW.id, NEW.candidature_id, 'UPLOAD', NEW.type_document, NEW.nom_fichier, NEW.taille_fichier, NULL, NULL, NULL, NULL);
END$$
CREATE TRIGGER tr_document_update
AFTER UPDATE ON Document
FOR EACH ROW
BEGIN
    IF (OLD.candidature_id IS NULL AND NEW.candidature_id IS NOT NULL) THEN
        INSERT INTO Document_Audit (document_id, candidature_id, type_action, type_document, nom_fichier, taille)
        VALUES (NEW.id, NEW.candidature_id, 'ASSOCIER', NEW.type_document, NEW.nom_fichier, NEW.taille_fichier);
    ELSEIF (OLD.candidature_id IS NOT NULL AND NEW.candidature_id IS NULL) THEN
        INSERT INTO Document_Audit (document_id, candidature_id, type_action, type_document, nom_fichier, taille)
        VALUES (OLD.id, OLD.candidature_id, 'DESASSOCIER', OLD.type_document, OLD.nom_fichier, OLD.taille_fichier);
    ELSEIF (OLD.nom_fichier <> NEW.nom_fichier OR OLD.chemin_fichier <> NEW.chemin_fichier OR OLD.taille_fichier <> NEW.taille_fichier) THEN
        INSERT INTO Document_Audit (document_id, candidature_id, type_action, type_document, nom_fichier, taille)
        VALUES (NEW.id, NEW.candidature_id, 'UPDATE', NEW.type_document, NEW.nom_fichier, NEW.taille_fichier);
    END IF;
END$$
CREATE TRIGGER tr_document_delete
BEFORE DELETE ON Document
FOR EACH ROW
BEGIN
    INSERT INTO Document_Audit (document_id, candidature_id, type_action, type_document, nom_fichier, taille)
    VALUES (OLD.id, OLD.candidature_id, 'DELETE', OLD.type_document, OLD.nom_fichier, OLD.taille_fichier);
END$$
DELIMITER ;

-- =========================================
-- ETAPE 5 : BOOTSTRAP PERMISSIONS & PARAMETRES (idempotent)
-- =========================================
-- Permissions de base
INSERT IGNORE INTO Permission (code, description) VALUES
 ('CANDIDATURE_VALIDER','Valider une candidature'),
 ('CANDIDATURE_REJETER','Rejeter une candidature'),
 ('CANDIDATURE_CONFIRMER','Confirmer une candidature'),
 ('QUOTA_GERER','Gérer les quotas Centre/Specialité'),
 ('RESULTAT_PUBLIER','Publier les résultats concours'),
 ('PARAMETRE_GERER','Gérer les paramètres globaux'),
 ('UTILISATEUR_CENTRE_GERER','Gérer les rattachements multi-centres'),
 ('STATISTIQUES_VOIR','Consulter les statistiques'),
 ('EXPORT_CSV','Exporter les données en CSV'),
 ('DOCUMENT_AUDIT_VOIR','Consulter l’audit des documents');

-- Attribution aux rôles (INSERT SELECT avec NOT EXISTS)
-- GestionnaireLocal
INSERT INTO Role_Permission (role, permission_id)
SELECT 'GestionnaireLocal', p.id FROM Permission p
WHERE p.code IN ('CANDIDATURE_VALIDER','CANDIDATURE_REJETER','CANDIDATURE_CONFIRMER','STATISTIQUES_VOIR','EXPORT_CSV','DOCUMENT_AUDIT_VOIR')
AND NOT EXISTS (SELECT 1 FROM Role_Permission rp WHERE rp.role='GestionnaireLocal' AND rp.permission_id=p.id);
-- GestionnaireGlobal
INSERT INTO Role_Permission (role, permission_id)
SELECT 'GestionnaireGlobal', p.id FROM Permission p
WHERE p.code IN ('CANDIDATURE_VALIDER','CANDIDATURE_REJETER','CANDIDATURE_CONFIRMER','STATISTIQUES_VOIR','EXPORT_CSV','DOCUMENT_AUDIT_VOIR','QUOTA_GERER','RESULTAT_PUBLIER')
AND NOT EXISTS (SELECT 1 FROM Role_Permission rp WHERE rp.role='GestionnaireGlobal' AND rp.permission_id=p.id);
-- Administrateur (toutes)
INSERT INTO Role_Permission (role, permission_id)
SELECT 'Administrateur', p.id FROM Permission p
WHERE NOT EXISTS (SELECT 1 FROM Role_Permission rp WHERE rp.role='Administrateur' AND rp.permission_id=p.id);

-- Paramètres par défaut
INSERT INTO Parametre (cle, valeur, description)
SELECT 'candidature.confirmation.delai_jours','7','Délai (jours) pour confirmation après validation'
WHERE NOT EXISTS (SELECT 1 FROM Parametre WHERE cle='candidature.confirmation.delai_jours');
INSERT INTO Parametre (cle, valeur, description)
SELECT 'resultat.publication.active','false','Activation publication résultats'
WHERE NOT EXISTS (SELECT 1 FROM Parametre WHERE cle='resultat.publication.active');
INSERT INTO Parametre (cle, valeur, description)
SELECT 'quota.verification.strict','true','Vérification stricte des quotas lors validation'
WHERE NOT EXISTS (SELECT 1 FROM Parametre WHERE cle='quota.verification.strict');
-- Fin étapes 4 & 5
-- =========================================
-- VÉRIFICATION FINALE
-- =========================================
SELECT 'Mise à jour appliquée avec succès!' AS status, NOW() AS date_mise_a_jour;

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
