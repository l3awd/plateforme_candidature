-- =========================================
-- Données de test pour CandidaturePlus
-- Ce script insert les données nécessaires pour les tests
-- =========================================

USE candidature_plus;

-- =========================================
-- INSERTION DES CENTRES
-- =========================================
INSERT INTO Centre (nom, adresse, ville, telephone, email, actif) VALUES
('Centre Rabat', '123 Avenue Mohammed V', 'Rabat', '05377712345', 'rabat@centres.ma', TRUE),
('Centre Casablanca', '456 Boulevard Zerktouni', 'Casablanca', '05227798765', 'casablanca@centres.ma', TRUE),
('Centre Marrakech', '789 Avenue Yacoub El Mansour', 'Marrakech', '05247723456', 'marrakech@centres.ma', TRUE),
('Centre Fès', '321 Rue Atlas', 'Fès', '05357734567', 'fes@centres.ma', TRUE),
('Centre Tanger', '654 Boulevard Pasteur', 'Tanger', '05398876543', 'tanger@centres.ma', TRUE);

-- =========================================
-- INSERTION DES SPÉCIALITÉS
-- =========================================
INSERT INTO Specialite (nom, code, description, actif) VALUES
('Informatique', 'INFO', 'Technologies de l''information et développement', TRUE),
('Génie Civil', 'GC', 'Construction et travaux publics', TRUE),
('Électronique', 'ELEC', 'Systèmes électroniques et télécommunications', TRUE),
('Mécanique', 'MECA', 'Génie mécanique et industriel', TRUE),
('Finance', 'FIN', 'Gestion financière et comptabilité', TRUE),
('Marketing', 'MKT', 'Marketing et communication', TRUE),
('Ressources Humaines', 'RH', 'Gestion des ressources humaines', TRUE),
('Droit', 'DROIT', 'Sciences juridiques', TRUE),
('Administration', 'ADMIN', 'Administration publique', TRUE),
('Comptabilité', 'COMPTA', 'Comptabilité et audit', TRUE);

-- =========================================
-- INSERTION DES CONCOURS
-- =========================================
INSERT INTO Concours (nom, description, date_debut_candidature, date_fin_candidature, date_examen, conditions_participation, documents_requis, fiche_concours_url, actif) VALUES
('Concours Techniciens 2025', 'Recrutement de techniciens spécialisés dans diverses spécialités pour la fonction publique', '2025-02-01', '2025-03-15', '2025-04-20', 'Diplôme de technicien ou équivalent. Âge: 18-35 ans. Nationalité marocaine.', 'CIN, CV, Diplôme, Relevé de notes, Photo d''identité', '/documents/fiches/technicien-2025.pdf', TRUE),
('Concours Attachés Administration 2025', 'Recrutement d''attachés d''administration pour les services centraux', '2025-01-15', '2025-02-28', '2025-03-25', 'Licence ou équivalent. Âge: 21-40 ans. Expérience souhaitée.', 'CIN, CV, Diplôme, Relevé de notes, Photo, Certificat de travail', '/documents/fiches/attache-administration-2025.pdf', TRUE),
('Concours Inspecteurs Finances 2025', 'Recrutement d''inspecteurs des finances publiques', '2025-03-01', '2025-04-15', '2025-05-20', 'Master en Finance/Économie. Âge: 23-45 ans. Excellent niveau en français et arabe.', 'CIN, CV, Diplôme Master, Relevés de notes, Photo, Certificats de langue', '/documents/fiches/inspecteur-finances-2025.pdf', TRUE);

-- =========================================
-- LIAISON CONCOURS-SPÉCIALITÉS
-- =========================================
INSERT INTO Concours_Specialite (concours_id, specialite_id, nombre_places) VALUES
-- Concours Techniciens
(1, 1, 50), -- Informatique
(1, 2, 30), -- Génie Civil  
(1, 3, 25), -- Électronique
(1, 4, 20), -- Mécanique
-- Concours Attachés
(2, 9, 40), -- Administration
(2, 6, 20), -- Marketing
(2, 7, 15), -- RH
(2, 8, 10), -- Droit
-- Concours Inspecteurs
(3, 5, 25), -- Finance
(3, 10, 15); -- Comptabilité

-- =========================================
-- LIAISON CENTRE-SPÉCIALITÉS (Places disponibles)
-- =========================================
INSERT INTO Centre_Specialite (centre_id, specialite_id, concours_id, nombre_places_disponibles, places_occupees) VALUES
-- Centre Rabat
(1, 1, 1, 20, 0), -- Informatique Techniciens
(1, 2, 1, 15, 0), -- Génie Civil Techniciens
(1, 9, 2, 15, 0), -- Administration Attachés
(1, 5, 3, 10, 0), -- Finance Inspecteurs
-- Centre Casablanca  
(2, 1, 1, 15, 0), -- Informatique Techniciens
(2, 3, 1, 12, 0), -- Électronique Techniciens
(2, 6, 2, 10, 0), -- Marketing Attachés
(2, 5, 3, 8, 0),  -- Finance Inspecteurs
-- Centre Marrakech
(3, 1, 1, 10, 0), -- Informatique Techniciens
(3, 4, 1, 8, 0),  -- Mécanique Techniciens
(3, 7, 2, 8, 0),  -- RH Attachés
(3, 10, 3, 4, 0), -- Comptabilité Inspecteurs
-- Centre Fès
(4, 2, 1, 10, 0), -- Génie Civil Techniciens
(4, 3, 1, 8, 0),  -- Électronique Techniciens
(4, 8, 2, 5, 0),  -- Droit Attachés
(4, 10, 3, 3, 0), -- Comptabilité Inspecteurs
-- Centre Tanger
(5, 1, 1, 5, 0),  -- Informatique Techniciens
(5, 4, 1, 12, 0), -- Mécanique Techniciens
(5, 9, 2, 12, 0), -- Administration Attachés
(5, 5, 3, 5, 0);  -- Finance Inspecteurs

-- =========================================
-- INSERTION DES UTILISATEURS (Gestionnaires)
-- =========================================
INSERT INTO Utilisateur (nom, prenom, email, mot_de_passe, role, centre_id, actif) VALUES
-- Gestionnaires Locaux
('Alami', 'Hassan', 'h.alami@mf.gov.ma', '$2a$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewRqGCaVeDqHOvfK', 'GestionnaireLocal', 1, TRUE), -- 1234
('Bennani', 'Fatima', 'f.bennani@mf.gov.ma', '$2a$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewRqGCaVeDqHOvfK', 'GestionnaireLocal', 2, TRUE), -- 1234
('Tazi', 'Mohammed', 'm.tazi@mf.gov.ma', '$2a$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewRqGCaVeDqHOvfK', 'GestionnaireLocal', 3, TRUE), -- 1234
('Fassi', 'Aicha', 'a.fassi@mf.gov.ma', '$2a$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewRqGCaVeDqHOvfK', 'GestionnaireLocal', 4, TRUE), -- 1234
-- Gestionnaire Global
('Chraibi', 'Mehdi', 'm.chraibi@mf.gov.ma', '$2a$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewRqGCaVeDqHOvfK', 'GestionnaireGlobal', NULL, TRUE), -- 1234
-- Administrateurs
('Talbi', 'Abdelkarim', 'a.talbi@mf.gov.ma', '$2a$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewRqGCaVeDqHOvfK', 'Administrateur', NULL, TRUE), -- 1234
('Admin', 'Test', 'admin@test.com', '$2a$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewRqGCaVeDqHOvfK', 'Administrateur', NULL, TRUE); -- 1234

-- =========================================
-- INSERTION DE CANDIDATS DE TEST
-- =========================================
INSERT INTO Candidat (numero_unique, nom, prenom, genre, cin, date_naissance, lieu_naissance, ville, email, telephone, niveau_etudes, diplome_principal, specialite_diplome, etablissement, annee_obtention, conditions_acceptees) VALUES
('CAND1701234567890', 'Benali', 'Youssef', 'Monsieur', 'AB123456', '1995-03-15', 'Casablanca', 'Casablanca', 'y.benali@gmail.com', '0661234567', 'DUT', 'DUT Informatique', 'Informatique', 'ISTA Casablanca', 2018, TRUE),
('CAND1701234567891', 'Alaoui', 'Khadija', 'Madame', 'CD789012', '1993-07-22', 'Rabat', 'Rabat', 'k.alaoui@gmail.com', '0662345678', 'Licence', 'Licence Génie Civil', 'Génie Civil', 'EHTP Casablanca', 2016, TRUE),
('CAND1701234567892', 'Ouali', 'Ahmed', 'Monsieur', 'EF345678', '1992-11-08', 'Fès', 'Fès', 'a.ouali@gmail.com', '0663456789', 'Master', 'Master Finance', 'Finance', 'FSJES Fès', 2017, TRUE),
('CAND1701234567893', 'Radi', 'Samira', 'Madame', 'GH901234', '1994-05-12', 'Marrakech', 'Marrakech', 's.radi@gmail.com', '0664567890', 'DTS', 'DTS Électronique', 'Électronique', 'ISTA Marrakech', 2019, TRUE),
('CAND1701234567894', 'Ziani', 'Omar', 'Monsieur', 'IJ567890', '1996-02-28', 'Tanger', 'Tanger', 'o.ziani@gmail.com', '0665678901', 'BTS', 'BTS Mécanique', 'Mécanique', 'ISTA Tanger', 2020, TRUE);

-- =========================================
-- INSERTION DE CANDIDATURES DE TEST
-- =========================================
INSERT INTO Candidature (candidat_id, concours_id, specialite_id, centre_id, etat, date_soumission, gestionnaire_id, numero_place) VALUES
(1, 1, 1, 1, 'Validee', '2025-01-20 10:30:00', 1, 1),   -- Youssef validé
(2, 1, 2, 1, 'En_Cours_Validation', '2025-01-21 14:15:00', NULL, NULL), -- Khadija en cours
(3, 3, 5, 1, 'Soumise', '2025-01-22 09:45:00', NULL, NULL),  -- Ahmed soumis
(4, 1, 3, 2, 'Rejetee', '2025-01-19 16:20:00', 2, NULL),     -- Samira rejetée
(5, 1, 4, 5, 'Confirmee', '2025-01-18 11:00:00', 4, 2);     -- Omar confirmé

-- =========================================
-- INSERTION DE NOTIFICATIONS DE TEST
-- =========================================
INSERT INTO Notification (type_destinataire, destinataire_id, type_notification, sujet, message, etat, date_envoi) VALUES
('Candidat', 1, 'Email', 'Candidature Validée', 'Félicitations ! Votre candidature a été validée. Votre numéro de place est: 1', 'Envoye', NOW()),
('Candidat', 4, 'Email', 'Candidature Rejetée', 'Nous regrettons de vous informer que votre candidature a été rejetée. Motif: Documents incomplets', 'Envoye', NOW()),
('Candidat', 5, 'Email', 'Candidature Confirmée', 'Votre participation au concours est confirmée. Présentez-vous le jour J avec votre CIN.', 'Envoye', NOW());

-- =========================================
-- INSERTION DE LOGS DE TEST
-- =========================================
INSERT INTO Log_Action (type_acteur, acteur_id, action, table_cible, enregistrement_id, details, ip_adresse, date_action) VALUES
('Candidat', 1, 'NOUVELLE_CANDIDATURE', 'Candidature', 1, '{"concours_id": 1, "centre_id": 1}', '192.168.1.100', '2025-01-20 10:30:00'),
('Utilisateur', 1, 'VALIDATION_CANDIDATURE', 'Candidature', 1, '{"ancien_etat": "Soumise", "nouvel_etat": "Validee"}', '192.168.1.50', '2025-01-20 15:00:00'),
('Utilisateur', 2, 'REJET_CANDIDATURE', 'Candidature', 4, '{"ancien_etat": "Soumise", "nouvel_etat": "Rejetee", "motif": "Documents incomplets"}', '192.168.1.51', '2025-01-19 17:00:00');

SELECT 'Données de test insérées avec succès!' AS Status;
SELECT 'Comptes disponibles:' AS Info;
SELECT CONCAT('- ', email, ' (', role, ')') AS Comptes FROM Utilisateur WHERE actif = TRUE;
        '0524-111222',
        'marrakech@mf.gov.ma',
        true,
        NOW ()
    ),
    (
        'Centre Agadir',
        'Boulevard Mohamed Cheikh Saad',
        'Agadir',
        '0528-333444',
        'agadir@mf.gov.ma',
        true,
        NOW ()
    );

-- Insertion des spécialités
INSERT IGNORE INTO Specialite (nom, code, description, actif, date_creation)
VALUES
    (
        'Economie et Gestion',
        'ECON',
        'Specialite en economie, finance et gestion des entreprises',
        true,
        NOW ()
    ),
    (
        'Comptabilite et Finance',
        'COMPTA',
        'Specialite en comptabilite, audit et finance',
        true,
        NOW ()
    ),
    (
        'Droit Public',
        'DROIT_PUB',
        'Specialite en droit public et administratif',
        true,
        NOW ()
    ),
    (
        'Informatique de Gestion',
        'INFO',
        'Specialite en informatique appliquee a la gestion',
        true,
        NOW ()
    ),
    (
        'Statistiques Appliquees',
        'STAT',
        'Specialite en statistiques et analyse de donnees',
        true,
        NOW ()
    ),
    (
        'Relations Internationales',
        'REL_INT',
        'Specialite en relations internationales et commerce',
        true,
        NOW ()
    );

-- Insertion des concours
INSERT IGNORE INTO Concours (
    nom,
    description,
    date_debut_candidature,
    date_fin_candidature,
    date_examen,
    conditions_participation,
    documents_requis,
    fiche_concours_url,
    actif,
    date_creation
)
VALUES
    (
        'Concours Attache d Administration - 2025',
        'Recrutement d attaches d administration pour le Ministere de l Economie et des Finances',
        '2025-07-01',
        '2025-08-31',
        '2025-09-15',
        'Etre titulaire d un diplome de niveau Bac+3 minimum\nAge maximum: 30 ans\nNationalite marocaine',
        'Copie legalisee du diplome\nCopie de la CIN\nCV detaille\nPhoto d identite\nCertificat de scolarite',
        'http://localhost:8080/api/documents/fiches/attache-administration-2025.pdf',
        true,
        NOW ()
    ),
    (
        'Concours Inspecteur des Finances - 2025',
        'Recrutement d inspecteurs des finances pour le controle et l audit',
        '2025-07-01',
        '2025-08-31',
        '2025-09-20',
        'Etre titulaire d un diplome de niveau Bac+5 minimum\nSpecialisation en finance, economie ou comptabilite\nAge maximum: 32 ans',
        'Copie legalisee du diplome\nCopie de la CIN\nCV detaille\nPhoto d identite\nReleve de notes du diplome\nCertificat medical',
        'http://localhost:8080/api/documents/fiches/inspecteur-finances-2025.pdf',
        true,
        NOW ()
    ),
    (
        'Concours Technicien Specialise en Informatique - 2025',
        'Recrutement de techniciens specialises en informatique et systemes d information',
        '2025-07-01',
        '2025-08-31',
        '2025-09-25',
        'Etre titulaire d un diplome de niveau Bac+2 minimum en informatique\nAge maximum: 28 ans',
        'Copie legalisee du diplome\nCopie de la CIN\nCV detaille\nPhoto d identite\nCertificats de formation',
        'http://localhost:8080/api/documents/fiches/technicien-informatique-2025.pdf',
        true,
        NOW ()
    );

-- Insertion des utilisateurs gestionnaires
INSERT IGNORE INTO Utilisateur (
    nom,
    prenom,
    email,
    mot_de_passe,
    role,
    centre_id,
    actif,
    date_creation
)
VALUES
    (
        'Alami',
        'Hassan',
        'h.alami@mf.gov.ma',
        '$2a$10$zK5Z5Z5Z5Z5Z5Z5Z5Z5Z5Z',
        'GestionnaireLocal',
        1,
        true,
        NOW ()
    ),
    (
        'Bennani',
        'Fatima',
        'f.bennani@mf.gov.ma',
        '$2a$10$zK5Z5Z5Z5Z5Z5Z5Z5Z5Z5Z',
        'GestionnaireLocal',
        2,
        true,
        NOW ()
    ),
    (
        'Chraibi',
        'Mohamed',
        'm.chraibi@mf.gov.ma',
        '$2a$10$zK5Z5Z5Z5Z5Z5Z5Z5Z5Z5Z',
        'GestionnaireGlobal',
        null,
        true,
        NOW ()
    ),
    (
        'Talbi',
        'Aicha',
        'a.talbi@mf.gov.ma',
        '$2a$10$zK5Z5Z5Z5Z5Z5Z5Z5Z5Z5Z',
        'Administrateur',
        null,
        true,
        NOW ()
    );

-- Insertion des candidats de test
INSERT IGNORE INTO Candidat (
    numero_unique,
    nom,
    prenom,
    genre,
    cin,
    date_naissance,
    lieu_naissance,
    adresse,
    ville,
    code_postal,
    email,
    telephone,
    telephone_urgence,
    niveau_etudes,
    diplome_principal,
    specialite_diplome,
    etablissement,
    annee_obtention,
    experience_professionnelle,
    conditions_acceptees,
    date_creation,
    ip_creation
)
VALUES
    (
        'CAND-2025-000001',
        'Benali',
        'Youssef',
        'Monsieur',
        'CD123456',
        '1995-03-15',
        'Casablanca',
        '25 Rue des Roses, Maarif',
        'Casablanca',
        '20000',
        'y.benali@email.com',
        '0661234567',
        '0522987654',
        'Bac+5',
        'Master en Finance',
        'Finance et Comptabilité',
        'ENCG Casablanca',
        2020,
        'Stage de 6 mois chez Attijariwafa Bank\nAssistant comptable pendant 2 ans',
        true,
        NOW (),
        '192.168.1.1'
    ),
    (
        'CAND-2025-000002',
        'Zahra',
        'Khadija',
        'Madame',
        'EF789012',
        '1993-07-22',
        'Rabat',
        '12 Avenue Moulay Hassan, Agdal',
        'Rabat',
        '10000',
        'k.zahra@email.com',
        '0662345678',
        '0537876543',
        'Bac+3',
        'Licence en Économie',
        'Sciences Économiques',
        'Université Mohammed V',
        2018,
        'Employée dans une PME pendant 3 ans\nFormation en gestion de projet',
        true,
        NOW (),
        '192.168.1.2'
    ),
    (
        'CAND-2025-000003',
        'Idrissi',
        'Omar',
        'Monsieur',
        'GH345678',
        '1996-11-08',
        'Fès',
        '8 Rue Ibn Sina, Ville Nouvelle',
        'Fès',
        '30000',
        'o.idrissi@email.com',
        '0663456789',
        '0535765432',
        'Bac+5',
        'Master en Informatique',
        'Informatique de Gestion',
        'FST Fès',
        2021,
        'Développeur junior pendant 1 an\nStage chez Orange Maroc',
        true,
        NOW (),
        '192.168.1.3'
    ),
    (
        'CAND-2025-000004',
        'Rhazi',
        'Sanaa',
        'Madame',
        'IJ901234',
        '1994-05-30',
        'Marrakech',
        '15 Boulevard Zerktouni, Gueliz',
        'Marrakech',
        '40000',
        's.rhazi@email.com',
        '0664567890',
        '0524654321',
        'Bac+3',
        'Licence en Droit',
        'Droit Public',
        'Université Cadi Ayyad',
        2019,
        'Assistante juridique pendant 2 ans\nStage au Tribunal de première instance',
        true,
        NOW (),
        '192.168.1.4'
    ),
    (
        'CAND-2025-000005',
        'Mansouri',
        'Rachid',
        'Monsieur',
        'KL567890',
        '1992-12-03',
        'Agadir',
        '22 Rue Al Mourabitoune, Centre ville',
        'Agadir',
        '80000',
        'r.mansouri@email.com',
        '0665678901',
        '0528543210',
        'Bac+5',
        'Master en Statistiques',
        'Statistiques Appliquées',
        'INSEA Rabat',
        2017,
        'Analyste de données chez HCP\nConsultant en statistiques',
        true,
        NOW (),
        '192.168.1.5'
    );

-- Insertion des candidatures
INSERT IGNORE INTO Candidature (
    candidat_id,
    concours_id,
    specialite_id,
    centre_id,
    etat,
    motif_rejet,
    commentaire_gestionnaire,
    date_soumission,
    date_traitement,
    gestionnaire_id,
    numero_place
)
VALUES
    -- Candidature acceptée
    (
        1,
        1,
        2,
        1,
        'Validee',
        null,
        'Excellent profil correspondant parfaitement aux exigences du poste',
        '2025-01-20 10:30:00',
        '2025-01-25 14:00:00',
        1,
        45
    ),
    -- Candidature rejetée
    (
        2,
        1,
        1,
        2,
        'Rejetee',
        'Spécialité du diplôme ne correspond pas exactement aux exigences du concours',
        'Le profil est intéressant mais la spécialité en sciences économiques ne correspond pas aux besoins spécifiques en gestion d\'entreprise',
        '2025-01-22 09:15:00',
        '2025-01-26 11:30:00',
        2,
        null
    ),
    -- Candidature en cours de validation
    (
        3,
        3,
        4,
        3,
        'En_Cours_Validation',
        null,
        null,
        '2025-01-25 16:45:00',
        null,
        null,
        null
    ),
    -- Candidature soumise (pas encore traitée)
    (
        4,
        1,
        3,
        4,
        'Soumise',
        null,
        null,
        '2025-01-26 08:20:00',
        null,
        null,
        null
    ),
    -- Candidature confirmée
    (
        5,
        2,
        5,
        1,
        'Confirmee',
        null,
        'Candidat hautement qualifié, profil parfait pour le poste d\'inspecteur',
        '2025-02-05 14:10:00',
        '2025-02-08 16:20:00',
        3,
        12
    );

-- Insertion de Centre_Specialite (relation entre centres et spécialités pour chaque concours)
INSERT IGNORE INTO Centre_Specialite (
    centre_id,
    specialite_id,
    concours_id,
    nombre_places_disponibles
)
VALUES
    -- Pour le concours Attaché d'Administration
    (1, 1, 1, 50),
    (1, 2, 1, 30),
    (1, 3, 1, 20),
    (2, 1, 1, 40),
    (2, 2, 1, 25),
    (2, 3, 1, 15),
    (3, 1, 1, 35),
    (3, 2, 1, 20),
    (3, 3, 1, 10),
    (4, 1, 1, 30),
    (4, 2, 1, 15),
    (4, 3, 1, 8),
    (5, 1, 1, 25),
    (5, 2, 1, 12),
    (5, 3, 1, 5),
    -- Pour le concours Inspecteur des Finances
    (1, 2, 2, 20),
    (1, 5, 2, 15),
    (2, 2, 2, 18),
    (2, 5, 2, 12),
    (3, 2, 2, 15),
    (3, 5, 2, 10),
    (4, 2, 2, 12),
    (4, 5, 2, 8),
    (5, 2, 2, 10),
    (5, 5, 2, 6),
    -- Pour le concours Technicien Spécialisé en Informatique
    (1, 4, 3, 25),
    (2, 4, 3, 20),
    (3, 4, 3, 15),
    (4, 4, 3, 12),
    (5, 4, 3, 10);

-- Insertion de quelques logs d'actions pour le suivi
INSERT IGNORE INTO Log_Action (
    type_acteur,
    acteur_id,
    action,
    table_cible,
    enregistrement_id,
    details,
    ip_adresse,
    user_agent,
    date_action
)
VALUES
    (
        'Candidat',
        1,
        'CREATION_CANDIDATURE',
        'Candidature',
        1,
        '{"concours": "Attaché d\'Administration", "specialite": "Comptabilité et Finance"}',
        '192.168.1.1',
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64)',
        '2025-01-20 10:30:00'
    ),
    (
        'Utilisateur',
        1,
        'VALIDATION_CANDIDATURE',
        'Candidature',
        1,
        '{"decision": "ACCEPTE", "commentaire": "Excellent profil"}',
        '10.0.0.1',
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64)',
        '2025-01-25 14:00:00'
    ),
    (
        'Candidat',
        2,
        'CREATION_CANDIDATURE',
        'Candidature',
        2,
        '{"concours": "Attaché d\'Administration", "specialite": "Économie et Gestion"}',
        '192.168.1.2',
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64)',
        '2025-01-22 09:15:00'
    ),
    (
        'Utilisateur',
        2,
        'REJET_CANDIDATURE',
        'Candidature',
        2,
        '{"decision": "REJETE", "motif": "Spécialité non conforme"}',
        '10.0.0.2',
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64)',
        '2025-01-26 11:30:00'
    ),
    (
        'Candidat',
        3,
        'CREATION_CANDIDATURE',
        'Candidature',
        3,
        '{"concours": "Technicien Spécialisé", "specialite": "Informatique de Gestion"}',
        '192.168.1.3',
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64)',
        '2025-01-25 16:45:00'
    );

-- Insertion de quelques notifications
INSERT IGNORE INTO Notification (
    destinataire_id,
    type_destinataire,
    sujet,
    message,
    type_notification,
    etat,
    date_creation
)
VALUES
    (
        1,
        'Candidat',
        'Candidature acceptée',
        'Félicitations ! Votre candidature pour le concours d\'Attaché d\'Administration a été acceptée. Vous recevrez prochainement votre convocation.',
        'Email',
        'En_Attente',
        '2025-01-25 14:05:00'
    ),
    (
        2,
        'Candidat',
        'Candidature rejetée',
        'Nous avons le regret de vous informer que votre candidature pour le concours d\'Attaché d\'Administration n\'a pas été retenue. Motif: Spécialité du diplôme ne correspond pas exactement aux exigences du concours.',
        'Email',
        'Envoye',
        '2025-01-26 11:35:00'
    ),
    (
        1,
        'Utilisateur',
        'Nouvelle candidature à traiter',
        'Une nouvelle candidature a été soumise dans votre centre et nécessite votre attention.',
        'Systeme',
        'Envoye',
        '2025-01-26 08:25:00'
    ),
    (
        5,
        'Candidat',
        'Candidature confirmée',
        'Excellente nouvelle ! Votre candidature pour le concours d\'Inspecteur des Finances a été confirmée. Toutes nos félicitations !',
        'Email',
        'En_Attente',
        '2025-02-08 16:25:00'
    );

-- Création de quelques statistiques
INSERT IGNORE INTO Statistique (
    type_statistique,
    concours_id,
    specialite_id,
    centre_id,
    valeur,
    details,
    date_calcul
)
VALUES
    (
        'candidatures_soumises',
        1,
        NULL,
        NULL,
        5,
        '{"total": 5, "periode": "2025"}',
        NOW ()
    ),
    (
        'candidatures_validees',
        1,
        NULL,
        NULL,
        2,
        '{"total": 2, "periode": "2025"}',
        NOW ()
    ),
    (
        'candidatures_rejetees',
        1,
        NULL,
        NULL,
        1,
        '{"total": 1, "periode": "2025"}',
        NOW ()
    ),
    (
        'candidatures_en_attente',
        1,
        NULL,
        NULL,
        2,
        '{"total": 2, "periode": "2025"}',
        NOW ()
    ),
    (
        'concours_actifs',
        NULL,
        NULL,
        NULL,
        3,
        '{"total": 3, "annee": "2025"}',
        NOW ()
    ),
    (
        'centres_actifs',
        NULL,
        NULL,
        NULL,
        5,
        '{"total": 5}',
        NOW ()
    ),
    (
        'specialites_disponibles',
        NULL,
        NULL,
        NULL,
        6,
        '{"total": 6}',
        NOW ()
    );