CREATE DATABASE IF NOT EXISTS candidature_plus;
USE candidature_plus;

-- Table Utilisateur
CREATE TABLE Utilisateur (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nom VARCHAR(100) NOT NULL,
    prenom VARCHAR(100) NOT NULL,
    email VARCHAR(150) UNIQUE NOT NULL,
    mot_de_passe VARCHAR(255) NOT NULL,
    role ENUM('Candidat', 'GestionnaireLocal', 'GestionnaireGlobal', 'Administrateur') NOT NULL,
    date_creation TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Table Centre
CREATE TABLE Centre (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nom VARCHAR(100) NOT NULL,
    adresse VARCHAR(255),
    date_creation TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Table Concours
CREATE TABLE Concours (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nom VARCHAR(100) NOT NULL,
    description TEXT,
    date_debut DATE NOT NULL,
    date_fin DATE NOT NULL,
    centre_id INT,
    FOREIGN KEY (centre_id) REFERENCES Centre(id) ON DELETE SET NULL
);

-- Table Candidat
CREATE TABLE Candidat (
    id INT AUTO_INCREMENT PRIMARY KEY,
    utilisateur_id INT NOT NULL,
    numero_unique VARCHAR(50) UNIQUE NOT NULL,
    FOREIGN KEY (utilisateur_id) REFERENCES Utilisateur(id) ON DELETE CASCADE
);

-- Table Candidature
CREATE TABLE Candidature (
    id INT AUTO_INCREMENT PRIMARY KEY,
    candidat_id INT NOT NULL,
    concours_id INT NOT NULL,
    etat ENUM('Soumise', 'Validée', 'Rejetée') DEFAULT 'Soumise',
    date_soumission TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (candidat_id) REFERENCES Candidat(id) ON DELETE CASCADE,
    FOREIGN KEY (concours_id) REFERENCES Concours(id) ON DELETE CASCADE
);

-- Table Notifications
CREATE TABLE Notification (
    id INT AUTO_INCREMENT PRIMARY KEY,
    utilisateur_id INT NOT NULL,
    message TEXT NOT NULL,
    date_envoi TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (utilisateur_id) REFERENCES Utilisateur(id) ON DELETE CASCADE
);

-- Table Statistiques (optionnelle pour reporting)
CREATE TABLE Statistique (
    id INT AUTO_INCREMENT PRIMARY KEY,
    type_statistique VARCHAR(100) NOT NULL,
    valeur INT NOT NULL,
    date_creation TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
