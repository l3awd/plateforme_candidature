-- Script de données de test pour CandidaturePlus
USE candidature_plus;

-- Insertion des centres
INSERT IGNORE INTO Centre (nom, adresse, ville, telephone, email, actif, date_creation) VALUES
('Centre Casablanca', 'Avenue Mohammed V, Quartier des Hopitaux', 'Casablanca', '0522-123456', 'casablanca@mf.gov.ma', true, NOW()),
('Centre Rabat', 'Avenue Allal Ben Abdellah', 'Rabat', '0537-654321', 'rabat@mf.gov.ma', true, NOW()),
('Centre Fès', 'Boulevard Hassan II', 'Fès', '0535-987654', 'fes@mf.gov.ma', true, NOW()),
('Centre Marrakech', 'Avenue Mohammed VI', 'Marrakech', '0524-111222', 'marrakech@mf.gov.ma', true, NOW()),
('Centre Agadir', 'Boulevard Mohamed Cheikh Saad', 'Agadir', '0528-333444', 'agadir@mf.gov.ma', true, NOW());

-- Insertion des spécialités
INSERT IGNORE INTO Specialite (nom, code, description, actif, date_creation) VALUES
('Économie et Gestion', 'ECON', 'Spécialité en économie, finance et gestion des entreprises', true, NOW()),
('Comptabilité et Finance', 'COMPTA', 'Spécialité en comptabilité, audit et finance', true, NOW()),
('Droit Public', 'DROIT_PUB', 'Spécialité en droit public et administratif', true, NOW()),
('Informatique de Gestion', 'INFO', 'Spécialité en informatique appliquée à la gestion', true, NOW()),
('Statistiques Appliquées', 'STAT', 'Spécialité en statistiques et analyse de données', true, NOW()),
('Relations Internationales', 'REL_INT', 'Spécialité en relations internationales et commerce', true, NOW());

-- Insertion des concours
INSERT IGNORE INTO Concours (nom, description, date_debut_candidature, date_fin_candidature, date_examen, conditions_participation, documents_requis, actif, date_creation) VALUES
('Concours Attaché d\'Administration - 2025', 
 'Recrutement d\'attachés d\'administration pour le Ministère de l\'Économie et des Finances', 
 '2025-01-15', '2025-03-15', '2025-04-20',
 'Être titulaire d\'un diplôme de niveau Bac+3 minimum\nÂge maximum: 30 ans\nNationalité marocaine',
 'Copie légalisée du diplôme\nCopie de la CIN\nCV détaillé\nPhoto d\'identité\nCertificat de scolarité',
 true, NOW()),

('Concours Inspecteur des Finances - 2025',
 'Recrutement d\'inspecteurs des finances pour le contrôle et l\'audit',
 '2025-02-01', '2025-04-01', '2025-05-10',
 'Être titulaire d\'un diplôme de niveau Bac+5 minimum\nSpécialisation en finance, économie ou comptabilité\nÂge maximum: 32 ans',
 'Copie légalisée du diplôme\nCopie de la CIN\nCV détaillé\nPhoto d\'identité\nRelevé de notes du diplôme\nCertificat médical',
 true, NOW()),

('Concours Technicien Spécialisé en Informatique - 2025',
 'Recrutement de techniciens spécialisés en informatique et systèmes d\'information',
 '2025-01-20', '2025-03-20', '2025-04-25',
 'Être titulaire d\'un diplôme de niveau Bac+2 minimum en informatique\nÂge maximum: 28 ans',
 'Copie légalisée du diplôme\nCopie de la CIN\nCV détaillé\nPhoto d\'identité\nCertificats de formation',
 true, NOW());

-- Insertion des utilisateurs gestionnaires
INSERT IGNORE INTO Utilisateur (nom, prenom, email, mot_de_passe, role, centre_id, actif, date_creation) VALUES
('Alami', 'Hassan', 'h.alami@mf.gov.ma', '$2a$10$zK5Z5Z5Z5Z5Z5Z5Z5Z5Z5Z', 'GestionnaireLocal', 1, true, NOW()),
('Bennani', 'Fatima', 'f.bennani@mf.gov.ma', '$2a$10$zK5Z5Z5Z5Z5Z5Z5Z5Z5Z5Z', 'GestionnaireLocal', 2, true, NOW()),
('Chraibi', 'Mohamed', 'm.chraibi@mf.gov.ma', '$2a$10$zK5Z5Z5Z5Z5Z5Z5Z5Z5Z5Z', 'GestionnaireGlobal', null, true, NOW()),
('Talbi', 'Aicha', 'a.talbi@mf.gov.ma', '$2a$10$zK5Z5Z5Z5Z5Z5Z5Z5Z5Z5Z', 'Administrateur', null, true, NOW());

-- Insertion des candidats de test
INSERT IGNORE INTO Candidat (numero_unique, nom, prenom, cin, date_naissance, lieu_naissance, adresse, ville, code_postal, email, telephone, telephone_urgence, niveau_etudes, diplome_principal, specialite_diplome, etablissement, annee_obtention, experience_professionnelle, conditions_acceptees, date_creation, ip_creation) VALUES
('CAND-2025-000001', 'Benali', 'Youssef', 'CD123456', '1995-03-15', 'Casablanca', '25 Rue des Roses, Maarif', 'Casablanca', '20000', 'y.benali@email.com', '0661234567', '0522987654', 'Bac+5', 'Master en Finance', 'Finance et Comptabilité', 'ENCG Casablanca', 2020, 'Stage de 6 mois chez Attijariwafa Bank\nAssistant comptable pendant 2 ans', true, NOW(), '192.168.1.1'),

('CAND-2025-000002', 'Zahra', 'Khadija', 'EF789012', '1993-07-22', 'Rabat', '12 Avenue Moulay Hassan, Agdal', 'Rabat', '10000', 'k.zahra@email.com', '0662345678', '0537876543', 'Bac+3', 'Licence en Économie', 'Sciences Économiques', 'Université Mohammed V', 2018, 'Employée dans une PME pendant 3 ans\nFormation en gestion de projet', true, NOW(), '192.168.1.2'),

('CAND-2025-000003', 'Idrissi', 'Omar', 'GH345678', '1996-11-08', 'Fès', '8 Rue Ibn Sina, Ville Nouvelle', 'Fès', '30000', 'o.idrissi@email.com', '0663456789', '0535765432', 'Bac+5', 'Master en Informatique', 'Informatique de Gestion', 'FST Fès', 2021, 'Développeur junior pendant 1 an\nStage chez Orange Maroc', true, NOW(), '192.168.1.3'),

('CAND-2025-000004', 'Rhazi', 'Sanaa', 'IJ901234', '1994-05-30', 'Marrakech', '15 Boulevard Zerktouni, Gueliz', 'Marrakech', '40000', 's.rhazi@email.com', '0664567890', '0524654321', 'Bac+3', 'Licence en Droit', 'Droit Public', 'Université Cadi Ayyad', 2019, 'Assistante juridique pendant 2 ans\nStage au Tribunal de première instance', true, NOW(), '192.168.1.4'),

('CAND-2025-000005', 'Mansouri', 'Rachid', 'KL567890', '1992-12-03', 'Agadir', '22 Rue Al Mourabitoune, Centre ville', 'Agadir', '80000', 'r.mansouri@email.com', '0665678901', '0528543210', 'Bac+5', 'Master en Statistiques', 'Statistiques Appliquées', 'INSEA Rabat', 2017, 'Analyste de données chez HCP\nConsultant en statistiques', true, NOW(), '192.168.1.5');

-- Insertion des candidatures
INSERT IGNORE INTO Candidature (candidat_id, concours_id, specialite_id, centre_id, etat, motif_rejet, commentaire_gestionnaire, date_soumission, date_traitement, gestionnaire_id, numero_place) VALUES
-- Candidature acceptée
(1, 1, 2, 1, 'Validee', null, 'Excellent profil correspondant parfaitement aux exigences du poste', '2025-01-20 10:30:00', '2025-01-25 14:00:00', 1, 45),

-- Candidature rejetée
(2, 1, 1, 2, 'Rejetee', 'Spécialité du diplôme ne correspond pas exactement aux exigences du concours', 'Le profil est intéressant mais la spécialité en sciences économiques ne correspond pas aux besoins spécifiques en gestion d\'entreprise', '2025-01-22 09:15:00', '2025-01-26 11:30:00', 2, null),

-- Candidature en cours de validation
(3, 3, 4, 3, 'En_Cours_Validation', null, null, '2025-01-25 16:45:00', null, null, null),

-- Candidature soumise (pas encore traitée)
(4, 1, 3, 4, 'Soumise', null, null, '2025-01-26 08:20:00', null, null, null),

-- Candidature confirmée
(5, 2, 5, 1, 'Confirmee', null, 'Candidat hautement qualifié, profil parfait pour le poste d\'inspecteur', '2025-02-05 14:10:00', '2025-02-08 16:20:00', 3, 12);

-- Insertion de Centre_Specialite (relation entre centres et spécialités pour chaque concours)
INSERT IGNORE INTO Centre_Specialite (centre_id, specialite_id, concours_id, nombre_places_disponibles) VALUES
-- Pour le concours Attaché d'Administration
(1, 1, 1, 50), (1, 2, 1, 30), (1, 3, 1, 20),
(2, 1, 1, 40), (2, 2, 1, 25), (2, 3, 1, 15),
(3, 1, 1, 35), (3, 2, 1, 20), (3, 3, 1, 10),
(4, 1, 1, 30), (4, 2, 1, 15), (4, 3, 1, 8),
(5, 1, 1, 25), (5, 2, 1, 12), (5, 3, 1, 5),

-- Pour le concours Inspecteur des Finances
(1, 2, 2, 20), (1, 5, 2, 15),
(2, 2, 2, 18), (2, 5, 2, 12),
(3, 2, 2, 15), (3, 5, 2, 10),
(4, 2, 2, 12), (4, 5, 2, 8),
(5, 2, 2, 10), (5, 5, 2, 6),

-- Pour le concours Technicien Spécialisé en Informatique
(1, 4, 3, 25), (2, 4, 3, 20), (3, 4, 3, 15), (4, 4, 3, 12), (5, 4, 3, 10);

-- Insertion de quelques logs d'actions pour le suivi
INSERT IGNORE INTO Log_Action (type_acteur, acteur_id, action, table_cible, enregistrement_id, details, ip_adresse, user_agent, date_action) VALUES
('Candidat', 1, 'CREATION_CANDIDATURE', 'Candidature', 1, '{"concours": "Attaché d\'Administration", "specialite": "Comptabilité et Finance"}', '192.168.1.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)', '2025-01-20 10:30:00'),
('Utilisateur', 1, 'VALIDATION_CANDIDATURE', 'Candidature', 1, '{"decision": "ACCEPTE", "commentaire": "Excellent profil"}', '10.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)', '2025-01-25 14:00:00'),
('Candidat', 2, 'CREATION_CANDIDATURE', 'Candidature', 2, '{"concours": "Attaché d\'Administration", "specialite": "Économie et Gestion"}', '192.168.1.2', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)', '2025-01-22 09:15:00'),
('Utilisateur', 2, 'REJET_CANDIDATURE', 'Candidature', 2, '{"decision": "REJETE", "motif": "Spécialité non conforme"}', '10.0.0.2', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)', '2025-01-26 11:30:00'),
('Candidat', 3, 'CREATION_CANDIDATURE', 'Candidature', 3, '{"concours": "Technicien Spécialisé", "specialite": "Informatique de Gestion"}', '192.168.1.3', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)', '2025-01-25 16:45:00');

-- Insertion de quelques notifications
INSERT IGNORE INTO Notification (destinataire_id, type_destinataire, sujet, message, type_notification, etat, date_creation) VALUES
(1, 'Candidat', 'Candidature acceptée', 'Félicitations ! Votre candidature pour le concours d\'Attaché d\'Administration a été acceptée. Vous recevrez prochainement votre convocation.', 'Email', 'En_Attente', '2025-01-25 14:05:00'),
(2, 'Candidat', 'Candidature rejetée', 'Nous avons le regret de vous informer que votre candidature pour le concours d\'Attaché d\'Administration n\'a pas été retenue. Motif: Spécialité du diplôme ne correspond pas exactement aux exigences du concours.', 'Email', 'Envoye', '2025-01-26 11:35:00'),
(1, 'Utilisateur', 'Nouvelle candidature à traiter', 'Une nouvelle candidature a été soumise dans votre centre et nécessite votre attention.', 'Systeme', 'Envoye', '2025-01-26 08:25:00'),
(5, 'Candidat', 'Candidature confirmée', 'Excellente nouvelle ! Votre candidature pour le concours d\'Inspecteur des Finances a été confirmée. Toutes nos félicitations !', 'Email', 'En_Attente', '2025-02-08 16:25:00');

-- Création de quelques statistiques
INSERT IGNORE INTO Statistique (type_statistique, concours_id, specialite_id, centre_id, valeur, details, date_calcul) VALUES
('candidatures_soumises', 1, NULL, NULL, 5, '{"total": 5, "periode": "2025"}', NOW()),
('candidatures_validees', 1, NULL, NULL, 2, '{"total": 2, "periode": "2025"}', NOW()),
('candidatures_rejetees', 1, NULL, NULL, 1, '{"total": 1, "periode": "2025"}', NOW()),
('candidatures_en_attente', 1, NULL, NULL, 2, '{"total": 2, "periode": "2025"}', NOW()),
('concours_actifs', NULL, NULL, NULL, 3, '{"total": 3, "annee": "2025"}', NOW()),
('centres_actifs', NULL, NULL, NULL, 5, '{"total": 5}', NOW()),
('specialites_disponibles', NULL, NULL, NULL, 6, '{"total": 6}', NOW());
