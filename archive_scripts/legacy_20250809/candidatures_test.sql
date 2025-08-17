-- =========================================
-- INSERTION DE CANDIDATURES DE TEST
-- =========================================
USE candidature_plus;

-- Insérer des candidats de test
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
    -- Candidat 1
    (
        'CAND-2025-001001',
        'Alami',
        'Youssef',
        'Monsieur',
        'ZX123456',
        '1995-03-15',
        'Casablanca',
        '123 Rue Mohammed V',
        'Casablanca',
        '20000',
        'y.alami@email.com',
        '0612345678',
        '0612345679',
        'Master',
        'Master en Droit Public',
        'Droit Public',
        'Université Mohammed V',
        2020,
        'Stage au Ministère de la Justice',
        1,
        NOW (),
        '127.0.0.1'
    ),
    -- Candidat 2
    (
        'CAND-2025-001002',
        'Benali',
        'Fatima',
        'Madame',
        'ZY789012',
        '1993-08-22',
        'Rabat',
        '456 Avenue Hassan II',
        'Rabat',
        '10000',
        'f.benali@email.com',
        '0623456789',
        '0623456780',
        'Master',
        'Master en Économie',
        'Sciences Économiques',
        'Université Mohammed V',
        2019,
        'Analyste financier chez BCP',
        1,
        NOW (),
        '127.0.0.1'
    ),
    -- Candidat 3
    (
        'CAND-2025-001003',
        'El Amrani',
        'Omar',
        'Monsieur',
        'ZZ345678',
        '1994-12-05',
        'Fès',
        '789 Bd Moulay Youssef',
        'Fès',
        '30000',
        'o.elamrani@email.com',
        '0634567890',
        '0634567891',
        'Licence',
        'Licence en Informatique',
        'Informatique',
        'Université Sidi Mohamed Ben Abdellah',
        2018,
        'Développeur web freelance',
        1,
        NOW (),
        '127.0.0.1'
    ),
    -- Candidat 4
    (
        'CAND-2025-001004',
        'Zahra',
        'Khadija',
        'Madame',
        'ZW901234',
        '1996-06-18',
        'Marrakech',
        '321 Rue de la Liberté',
        'Marrakech',
        '40000',
        'k.zahra@email.com',
        '0645678901',
        '0645678902',
        'Master',
        'Master en Gestion',
        'Management',
        'Université Cadi Ayyad',
        2021,
        'Contrôleuse de gestion',
        1,
        NOW (),
        '127.0.0.1'
    ),
    -- Candidat 5
    (
        'CAND-2025-001005',
        'Mansouri',
        'Rachid',
        'Monsieur',
        'ZV567890',
        '1992-11-30',
        'Agadir',
        '654 Avenue du Progrès',
        'Agadir',
        '80000',
        'r.mansouri@email.com',
        '0656789012',
        '0656789013',
        'Master',
        'Master en Sciences Politiques',
        'Relations Internationales',
        'Université Ibn Zohr',
        2017,
        'Chargé de mission ONG',
        1,
        NOW (),
        '127.0.0.1'
    ),
    -- Candidat 6
    (
        'CAND-2025-001006',
        'Idrissi',
        'Sanaa',
        'Madame',
        'ZU123456',
        '1995-09-12',
        'Tanger',
        '987 Rue Ibn Battuta',
        'Tanger',
        '90000',
        's.idrissi@email.com',
        '0667890123',
        '0667890124',
        'Doctorat',
        'Doctorat en Droit Privé',
        'Droit des Affaires',
        'Université Abdelmalek Essaadi',
        2022,
        'Avocate stagiaire',
        1,
        NOW (),
        '127.0.0.1'
    ),
    -- Candidat 7
    (
        'CAND-2025-001007',
        'Berrada',
        'Hassan',
        'Monsieur',
        'ZT789012',
        '1991-04-25',
        'Meknès',
        '135 Boulevard Mohamed VI',
        'Meknès',
        '50000',
        'h.berrada@email.com',
        '0678901234',
        '0678901235',
        'Master',
        'Master en Finance',
        'Finance et Banque',
        'Université Moulay Ismail',
        2016,
        'Analyste crédit BMCE',
        1,
        NOW (),
        '127.0.0.1'
    ),
    -- Candidat 8
    (
        'CAND-2025-001008',
        'Chraibi',
        'Nadia',
        'Madame',
        'ZS345678',
        '1994-07-08',
        'Oujda',
        '246 Rue Al Massira',
        'Oujda',
        '60000',
        'n.chraibi@email.com',
        '0689012345',
        '0689012346',
        'Master',
        'Master en Administration Publique',
        'Gestion Publique',
        'Université Mohammed Premier',
        2020,
        'Fonctionnaire commune',
        1,
        NOW (),
        '127.0.0.1'
    );

-- Insérer des candidatures avec différents états (utiliser les IDs corrects des candidats créés)
INSERT IGNORE INTO Candidature (
    candidat_id,
    concours_id,
    specialite_id,
    centre_id,
    etat,
    date_soumission,
    date_traitement,
    gestionnaire_id,
    motif_rejet,
    commentaire_gestionnaire
)
VALUES
    -- Candidatures soumises (en attente) - utiliser les candidats 14-21
    (
        14,
        1,
        1,
        1,
        'Soumise',
        DATE_SUB (NOW (), INTERVAL 5 DAY),
        NULL,
        NULL,
        NULL,
        NULL
    ),
    (
        15,
        2,
        3,
        2,
        'Soumise',
        DATE_SUB (NOW (), INTERVAL 3 DAY),
        NULL,
        NULL,
        NULL,
        NULL
    ),
    (
        16,
        3,
        5,
        3,
        'Soumise',
        DATE_SUB (NOW (), INTERVAL 1 DAY),
        NULL,
        NULL,
        NULL,
        NULL
    ),
    -- Candidatures en cours de validation
    (
        17,
        1,
        2,
        1,
        'En_Cours_Validation',
        DATE_SUB (NOW (), INTERVAL 10 DAY),
        DATE_SUB (NOW (), INTERVAL 8 DAY),
        1,
        NULL,
        'Dossier en cours d\'examen'
    ),
    (
        18,
        2,
        3,
        2,
        'En_Cours_Validation',
        DATE_SUB (NOW (), INTERVAL 7 DAY),
        DATE_SUB (NOW (), INTERVAL 5 DAY),
        2,
        NULL,
        'Vérification des diplômes'
    ),
    -- Candidatures validées
    (
        19,
        1,
        1,
        1,
        'Validee',
        DATE_SUB (NOW (), INTERVAL 15 DAY),
        DATE_SUB (NOW (), INTERVAL 12 DAY),
        1,
        NULL,
        'Candidature excellente, profil adapté'
    ),
    (
        20,
        3,
        5,
        3,
        'Validee',
        DATE_SUB (NOW (), INTERVAL 20 DAY),
        DATE_SUB (NOW (), INTERVAL 18 DAY),
        3,
        NULL,
        'Bon profil technique'
    ),
    -- Candidature rejetée
    (
        21,
        2,
        4,
        2,
        'Rejetee',
        DATE_SUB (NOW (), INTERVAL 12 DAY),
        DATE_SUB (NOW (), INTERVAL 10 DAY),
        2,
        'Diplôme non conforme aux exigences',
        'Le diplôme en Administration Publique ne correspond pas à la spécialité Finance requise'
    );

-- Mettre à jour quelques gestionnaires avec des centres assignés
UPDATE Utilisateur
SET
    centres_assignes = JSON_ARRAY (1, 2)
WHERE
    email = 'h.alami@mf.gov.ma';

UPDATE Utilisateur
SET
    centres_assignes = JSON_ARRAY (2, 3)
WHERE
    email = 'f.bennani@mf.gov.ma';

UPDATE Utilisateur
SET
    centres_assignes = JSON_ARRAY (1, 2, 3, 4, 5)
WHERE
    role = 'gestionnaire_global'
    OR role = 'administrateur';

-- Insérer quelques notifications de test
INSERT IGNORE INTO Notification (
    candidat_id,
    type,
    titre,
    message,
    date_envoi,
    envoye
)
VALUES
    (
        14,
        'candidature_soumise',
        'Candidature reçue',
        'Votre candidature pour le concours Techniciens 2025 a été reçue avec succès.',
        DATE_SUB (NOW (), INTERVAL 5 DAY),
        1
    ),
    (
        19,
        'candidature_validee',
        'Candidature validée',
        'Félicitations ! Votre candidature pour le concours Techniciens 2025 a été validée.',
        DATE_SUB (NOW (), INTERVAL 12 DAY),
        1
    ),
    (
        21,
        'candidature_rejetee',
        'Candidature rejetée',
        'Nous regrettons de vous informer que votre candidature a été rejetée.',
        DATE_SUB (NOW (), INTERVAL 10 DAY),
        1
    );