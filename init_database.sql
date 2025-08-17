-- =========================================
-- Script de création de base de données CandidaturePlus
-- Ce script supprime et recrée complètement la base de données
-- =========================================

-- Supprimer la base de données si elle existe
DROP DATABASE IF EXISTS candidature_plus;

-- Créer la nouvelle base de données
CREATE DATABASE candidature_plus CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE candidature_plus;

-- =========================================
-- CRÉATION DES TABLES
-- =========================================

-- Table Utilisateur (gestionnaires et administrateurs)
CREATE TABLE Utilisateur (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nom VARCHAR(100) NOT NULL,
    prenom VARCHAR(100) NOT NULL,
    email VARCHAR(150) UNIQUE NOT NULL,
    mot_de_passe VARCHAR(255) NOT NULL,
    role ENUM('GestionnaireLocal', 'GestionnaireGlobal', 'Administrateur') NOT NULL,
    centre_id INT NULL,
    actif BOOLEAN DEFAULT TRUE,
    date_creation TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    derniere_connexion TIMESTAMP NULL
);

-- Table Centre
CREATE TABLE Centre (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nom VARCHAR(100) NOT NULL,
    adresse VARCHAR(255),
    ville VARCHAR(100),
    telephone VARCHAR(20),
    email VARCHAR(150),
    actif BOOLEAN DEFAULT TRUE,
    date_creation TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Table Spécialité
CREATE TABLE Specialite (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nom VARCHAR(100) NOT NULL,
    code VARCHAR(20) UNIQUE NOT NULL,
    description TEXT,
    actif BOOLEAN DEFAULT TRUE,
    date_creation TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Table Concours
CREATE TABLE Concours (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nom VARCHAR(100) NOT NULL,
    description TEXT,
    date_debut_candidature DATE NOT NULL,
    date_fin_candidature DATE NOT NULL,
    date_examen DATE,
    conditions_participation TEXT,
    documents_requis TEXT,
    fiche_concours_url VARCHAR(255),
    actif BOOLEAN DEFAULT TRUE,
    date_creation TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Table de liaison Concours-Spécialités
CREATE TABLE Concours_Specialite (
    id INT AUTO_INCREMENT PRIMARY KEY,
    concours_id INT NOT NULL,
    specialite_id INT NOT NULL,
    nombre_places INT DEFAULT 0,
    FOREIGN KEY (concours_id) REFERENCES Concours(id) ON DELETE CASCADE,
    FOREIGN KEY (specialite_id) REFERENCES Specialite(id) ON DELETE CASCADE,
    UNIQUE KEY unique_concours_specialite (concours_id, specialite_id)
);

-- Table de liaison Centre-Spécialités
CREATE TABLE Centre_Specialite (
    id INT AUTO_INCREMENT PRIMARY KEY,
    centre_id INT NOT NULL,
    specialite_id INT NOT NULL,
    concours_id INT NOT NULL,
    nombre_places_disponibles INT DEFAULT 0,
    places_occupees INT DEFAULT 0,
    FOREIGN KEY (centre_id) REFERENCES Centre(id) ON DELETE CASCADE,
    FOREIGN KEY (specialite_id) REFERENCES Specialite(id) ON DELETE CASCADE,
    FOREIGN KEY (concours_id) REFERENCES Concours(id) ON DELETE CASCADE,
    UNIQUE KEY unique_centre_specialite_concours (centre_id, specialite_id, concours_id)
);

-- Table Candidat
CREATE TABLE Candidat (
    id INT AUTO_INCREMENT PRIMARY KEY,
    numero_unique VARCHAR(50) UNIQUE NOT NULL,
    nom VARCHAR(100) NOT NULL,
    prenom VARCHAR(100) NOT NULL,
    genre ENUM('Masculin', 'Feminin') NOT NULL,
    cin VARCHAR(20) UNIQUE NOT NULL,
    date_naissance DATE NOT NULL,
    lieu_naissance VARCHAR(100) NOT NULL,
    ville VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL,
    telephone VARCHAR(20) NOT NULL,
    telephone_urgence VARCHAR(20),
    niveau_etudes VARCHAR(100) NOT NULL,
    diplome_principal VARCHAR(200) NOT NULL,
    specialite_diplome VARCHAR(200) NOT NULL,
    etablissement VARCHAR(200),
    annee_obtention YEAR,
    experience_professionnelle TEXT,
    conditions_acceptees BOOLEAN DEFAULT FALSE,
    date_creation TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ip_creation VARCHAR(45)
);

-- Table Candidature
CREATE TABLE Candidature (
    id INT AUTO_INCREMENT PRIMARY KEY,
    candidat_id INT NOT NULL,
    concours_id INT NOT NULL,
    specialite_id INT NOT NULL,
    centre_id INT NOT NULL,
    etat ENUM('Soumise', 'En_Cours_Validation', 'Validee', 'Rejetee', 'Confirmee') DEFAULT 'Soumise',
    motif_rejet TEXT NULL,
    commentaire_gestionnaire TEXT NULL,
    date_soumission TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    date_traitement TIMESTAMP NULL,
    gestionnaire_id INT NULL,
    numero_place INT NULL,
    FOREIGN KEY (candidat_id) REFERENCES Candidat(id) ON DELETE CASCADE,
    FOREIGN KEY (concours_id) REFERENCES Concours(id) ON DELETE CASCADE,
    FOREIGN KEY (specialite_id) REFERENCES Specialite(id) ON DELETE CASCADE,
    FOREIGN KEY (centre_id) REFERENCES Centre(id) ON DELETE CASCADE,
    FOREIGN KEY (gestionnaire_id) REFERENCES Utilisateur(id) ON DELETE SET NULL,
    UNIQUE KEY unique_candidat_concours (candidat_id, concours_id)
);

-- Table Documents
CREATE TABLE Document (
    id INT AUTO_INCREMENT PRIMARY KEY,
    candidature_id INT NULL,
    cin_temp VARCHAR(20) NULL,
    type_document ENUM('CIN', 'CV', 'Diplome', 'Releve_Notes', 'Photo', 'Autre') NOT NULL,
    nom_fichier VARCHAR(255) NOT NULL,
    chemin_fichier VARCHAR(500) NOT NULL,
    taille_fichier BIGINT,
    type_mime VARCHAR(100),
    date_upload TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (candidature_id) REFERENCES Candidature(id) ON DELETE CASCADE
);

-- Table Notifications
CREATE TABLE Notification (
    id INT AUTO_INCREMENT PRIMARY KEY,
    type_destinataire ENUM('Candidat', 'Utilisateur') NOT NULL,
    destinataire_id INT NOT NULL,
    type_notification ENUM('Email', 'SMS', 'Systeme') NOT NULL,
    sujet VARCHAR(200),
    message TEXT NOT NULL,
    etat ENUM('En_Attente', 'Envoye', 'Echec') DEFAULT 'En_Attente',
    date_creation TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    date_envoi TIMESTAMP NULL,
    tentatives_envoi INT DEFAULT 0,
    erreur_envoi TEXT
);

-- Table Logs
CREATE TABLE Log_Action (
    id INT AUTO_INCREMENT PRIMARY KEY,
    type_acteur ENUM('Candidat', 'Utilisateur', 'Systeme') NOT NULL,
    acteur_id INT NULL,
    action VARCHAR(100) NOT NULL,
    table_cible VARCHAR(50),
    enregistrement_id INT,
    details JSON,
    ip_adresse VARCHAR(45),
    user_agent TEXT,
    date_action TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Table Statistiques
CREATE TABLE Statistique (
    id INT AUTO_INCREMENT PRIMARY KEY,
    type_statistique VARCHAR(100) NOT NULL,
    concours_id INT NULL,
    specialite_id INT NULL,
    centre_id INT NULL,
    valeur INT NOT NULL,
    details JSON,
    date_calcul TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (concours_id) REFERENCES Concours(id) ON DELETE CASCADE,
    FOREIGN KEY (specialite_id) REFERENCES Specialite(id) ON DELETE CASCADE,
    FOREIGN KEY (centre_id) REFERENCES Centre(id) ON DELETE CASCADE
);

-- Contraintes de clés étrangères
ALTER TABLE Utilisateur ADD FOREIGN KEY (centre_id) REFERENCES Centre(id) ON DELETE SET NULL;

-- =========================================
-- INDEX POUR PERFORMANCES
-- =========================================

-- Index pour la recherche de candidatures
CREATE INDEX idx_candidature_etat ON Candidature(etat);
CREATE INDEX idx_candidature_date ON Candidature(date_soumission);
CREATE INDEX idx_candidat_email ON Candidat(email);
CREATE INDEX idx_candidat_cin ON Candidat(cin);
CREATE INDEX idx_candidat_numero ON Candidat(numero_unique);

-- Index pour les logs
CREATE INDEX idx_log_date ON Log_Action(date_action);
CREATE INDEX idx_log_acteur ON Log_Action(type_acteur, acteur_id);

-- Index pour les notifications
CREATE INDEX idx_notification_etat ON Notification(etat);
CREATE INDEX idx_notification_destinataire ON Notification(type_destinataire, destinataire_id);

-- =========================================
-- TRIGGERS POUR L'AUDIT
-- =========================================

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
-- VIEWS POUR SIMPLIFIER LES REQUÊTES
-- =========================================

-- Vue pour les candidatures avec informations complètes
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

SELECT 'Base de données initialisée avec succès!' AS Status;
