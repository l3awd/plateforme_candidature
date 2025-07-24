CREATE DATABASE IF NOT EXISTS candidature_plus;
USE candidature_plus;

-- Table Utilisateur (pour les gestionnaires et administrateurs uniquement)
CREATE TABLE Utilisateur (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nom VARCHAR(100) NOT NULL,
    prenom VARCHAR(100) NOT NULL,
    email VARCHAR(150) UNIQUE NOT NULL,
    mot_de_passe VARCHAR(255) NOT NULL,
    role ENUM('GestionnaireLocal', 'GestionnaireGlobal', 'Administrateur') NOT NULL,
    centre_id INT NULL, -- Pour les gestionnaires locaux seulement
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

-- Table de liaison Centre-Spécialités (centres disponibles pour chaque spécialité)
CREATE TABLE Centre_Specialite (
    id INT AUTO_INCREMENT PRIMARY KEY,
    centre_id INT NOT NULL,
    specialite_id INT NOT NULL,
    concours_id INT NOT NULL,
    nombre_places_disponibles INT DEFAULT 0,
    FOREIGN KEY (centre_id) REFERENCES Centre(id) ON DELETE CASCADE,
    FOREIGN KEY (specialite_id) REFERENCES Specialite(id) ON DELETE CASCADE,
    FOREIGN KEY (concours_id) REFERENCES Concours(id) ON DELETE CASCADE,
    UNIQUE KEY unique_centre_specialite_concours (centre_id, specialite_id, concours_id)
);

-- Table Candidat (sans compte utilisateur)
CREATE TABLE Candidat (
    id INT AUTO_INCREMENT PRIMARY KEY,
    numero_unique VARCHAR(50) UNIQUE NOT NULL,
    -- Informations personnelles
    nom VARCHAR(100) NOT NULL,
    prenom VARCHAR(100) NOT NULL,
    cin VARCHAR(20) UNIQUE NOT NULL,
    date_naissance DATE NOT NULL,
    lieu_naissance VARCHAR(100) NOT NULL,
    adresse TEXT NOT NULL,
    ville VARCHAR(100) NOT NULL,
    code_postal VARCHAR(10),
    -- Coordonnées
    email VARCHAR(150) NOT NULL,
    telephone VARCHAR(20) NOT NULL,
    telephone_urgence VARCHAR(20),
    -- Formation
    niveau_etudes VARCHAR(100) NOT NULL,
    diplome_principal VARCHAR(200) NOT NULL,
    specialite_diplome VARCHAR(200) NOT NULL,
    etablissement VARCHAR(200),
    annee_obtention YEAR,
    -- Expérience professionnelle
    experience_professionnelle TEXT,
    -- Métadonnées
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
    numero_place INT NULL, -- Numéro de place attribué
    FOREIGN KEY (candidat_id) REFERENCES Candidat(id) ON DELETE CASCADE,
    FOREIGN KEY (concours_id) REFERENCES Concours(id) ON DELETE CASCADE,
    FOREIGN KEY (specialite_id) REFERENCES Specialite(id) ON DELETE CASCADE,
    FOREIGN KEY (centre_id) REFERENCES Centre(id) ON DELETE CASCADE,
    FOREIGN KEY (gestionnaire_id) REFERENCES Utilisateur(id) ON DELETE SET NULL,
    UNIQUE KEY unique_candidat_concours (candidat_id, concours_id)
);

-- Table Documents (pour les fichiers téléchargés)
CREATE TABLE Document (
    id INT AUTO_INCREMENT PRIMARY KEY,
    candidature_id INT NOT NULL,
    type_document ENUM('CIN', 'CV', 'Diplome', 'Releve_Notes', 'Photo', 'Autre') NOT NULL,
    nom_fichier VARCHAR(255) NOT NULL,
    chemin_fichier VARCHAR(500) NOT NULL,
    taille_fichier BIGINT,
    type_mime VARCHAR(100),
    date_upload TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (candidature_id) REFERENCES Candidature(id) ON DELETE CASCADE
);

-- Table Notifications (pour candidats et utilisateurs)
CREATE TABLE Notification (
    id INT AUTO_INCREMENT PRIMARY KEY,
    type_destinataire ENUM('Candidat', 'Utilisateur') NOT NULL,
    destinataire_id INT NOT NULL, -- candidat_id ou utilisateur_id selon le type
    type_notification ENUM('Email', 'SMS', 'Systeme') NOT NULL,
    sujet VARCHAR(200),
    message TEXT NOT NULL,
    etat ENUM('En_Attente', 'Envoye', 'Echec') DEFAULT 'En_Attente',
    date_creation TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    date_envoi TIMESTAMP NULL,
    tentatives_envoi INT DEFAULT 0
);

-- Table Logs (pour traçabilité)
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

-- Ajout des contraintes de clés étrangères pour Utilisateur
ALTER TABLE Utilisateur ADD FOREIGN KEY (centre_id) REFERENCES Centre(id) ON DELETE SET NULL;

-- ==============================
-- DONNÉES D'EXEMPLE POUR TESTS
-- ==============================

-- Insertion des centres d'examen
INSERT INTO Centre (nom, adresse, ville, telephone, email) VALUES
('Centre Rabat', '123 Avenue Mohammed V', 'Rabat', '05377712345', 'rabat@centres.ma'),
('Centre Casablanca', '456 Boulevard Zerktouni', 'Casablanca', '05227798765', 'casablanca@centres.ma'),
('Centre Marrakech', '789 Avenue Yacoub El Mansour', 'Marrakech', '05247723456', 'marrakech@centres.ma'),
('Centre Fès', '321 Rue Atlas', 'Fès', '05357734567', 'fes@centres.ma');

-- Insertion des spécialités
INSERT INTO Specialite (nom, code, description) VALUES
('Informatique', 'INFO', 'Technologies de l''information et développement'),
('Génie Civil', 'GC', 'Construction et travaux publics'),
('Électronique', 'ELEC', 'Systèmes électroniques et télécommunications'),
('Mécanique', 'MECA', 'Génie mécanique et industriel'),
('Finance', 'FIN', 'Gestion financière et comptabilité'),
('Marketing', 'MKT', 'Marketing et communication'),
('Ressources Humaines', 'RH', 'Gestion des ressources humaines'),
('Droit', 'DROIT', 'Sciences juridiques');

-- Insertion d'un concours d'exemple
INSERT INTO Concours (nom, description, date_debut_candidature, date_fin_candidature, date_examen, conditions_participation, documents_requis) VALUES
('Concours Techniciens 2025', 
 'Concours de recrutement de techniciens dans diverses spécialités', 
 '2025-02-01', 
 '2025-03-15', 
 '2025-04-20',
 'Diplôme de technicien ou équivalent. Âge maximum: 35 ans.',
 'CIN, CV, Diplôme, Relevé de notes, Photo d''identité');

-- Association du concours avec les spécialités
INSERT INTO Concours_Specialite (concours_id, specialite_id, nombre_places) VALUES
(1, 1, 50), -- Informatique
(1, 2, 30), -- Génie Civil
(1, 3, 25), -- Électronique
(1, 4, 20); -- Mécanique

-- Attribution des spécialités aux centres
INSERT INTO Centre_Specialite (centre_id, specialite_id, concours_id, nombre_places_disponibles) VALUES
-- Centre Rabat
(1, 1, 1, 20), -- Informatique
(1, 2, 1, 15), -- Génie Civil
(1, 3, 1, 10), -- Électronique
-- Centre Casablanca
(2, 1, 1, 15), -- Informatique
(2, 2, 1, 10), -- Génie Civil
(2, 4, 1, 12), -- Mécanique
-- Centre Marrakech
(3, 1, 1, 10), -- Informatique
(3, 3, 1, 8),  -- Électronique
(3, 4, 1, 8),  -- Mécanique
-- Centre Fès
(4, 1, 1, 5),  -- Informatique
(4, 2, 1, 5),  -- Génie Civil
(4, 3, 1, 7);  -- Électronique

-- Création des comptes gestionnaires
INSERT INTO Utilisateur (nom, prenom, email, mot_de_passe, role, centre_id) VALUES
-- Administrateur
('Admin', 'Système', 'admin@plateforme.ma', '$2a$10$example.hash.password', 'Administrateur', NULL),
-- Gestionnaire Global
('Benali', 'Mohammed', 'global@plateforme.ma', '$2a$10$example.hash.password', 'GestionnaireGlobal', NULL),
-- Gestionnaires Locaux
('Alami', 'Fatima', 'rabat@plateforme.ma', '$2a$10$example.hash.password', 'GestionnaireLocal', 1),
('Tazi', 'Ahmed', 'casablanca@plateforme.ma', '$2a$10$example.hash.password', 'GestionnaireLocal', 2),
('Najib', 'Khadija', 'marrakech@plateforme.ma', '$2a$10$example.hash.password', 'GestionnaireLocal', 3),
('Chaoui', 'Youssef', 'fes@plateforme.ma', '$2a$10$example.hash.password', 'GestionnaireLocal', 4);

-- ==============================
-- VUES UTILES POUR L'APPLICATION
-- ==============================

-- Vue pour les candidatures avec toutes les informations
CREATE VIEW vue_candidatures_completes AS
SELECT 
    cand.id as candidature_id,
    cand.etat,
    cand.date_soumission,
    cand.date_traitement,
    cand.motif_rejet,
    cand.numero_place,
    -- Informations candidat
    c.numero_unique,
    c.nom,
    c.prenom,
    c.cin,
    c.email,
    c.telephone,
    c.niveau_etudes,
    c.diplome_principal,
    c.specialite_diplome,
    -- Informations concours
    co.nom as concours_nom,
    co.date_examen,
    -- Informations spécialité
    s.nom as specialite_nom,
    s.code as specialite_code,
    -- Informations centre
    ce.nom as centre_nom,
    ce.ville as centre_ville,
    -- Informations gestionnaire
    u.nom as gestionnaire_nom,
    u.prenom as gestionnaire_prenom
FROM Candidature cand
JOIN Candidat c ON cand.candidat_id = c.id
JOIN Concours co ON cand.concours_id = co.id
JOIN Specialite s ON cand.specialite_id = s.id
JOIN Centre ce ON cand.centre_id = ce.id
LEFT JOIN Utilisateur u ON cand.gestionnaire_id = u.id;

-- Vue pour les statistiques par centre et spécialité
CREATE VIEW vue_statistiques_centres AS
SELECT 
    ce.nom as centre_nom,
    s.nom as specialite_nom,
    co.nom as concours_nom,
    COUNT(cand.id) as total_candidatures,
    SUM(CASE WHEN cand.etat = 'Validee' THEN 1 ELSE 0 END) as candidatures_validees,
    SUM(CASE WHEN cand.etat = 'Rejetee' THEN 1 ELSE 0 END) as candidatures_rejetees,
    SUM(CASE WHEN cand.etat = 'Soumise' THEN 1 ELSE 0 END) as candidatures_en_attente,
    cs.nombre_places_disponibles
FROM Centre ce
JOIN Centre_Specialite cs ON ce.id = cs.centre_id
JOIN Specialite s ON cs.specialite_id = s.id
JOIN Concours co ON cs.concours_id = co.id
LEFT JOIN Candidature cand ON ce.id = cand.centre_id AND s.id = cand.specialite_id AND co.id = cand.concours_id
GROUP BY ce.id, s.id, co.id;
