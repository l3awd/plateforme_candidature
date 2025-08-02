-- =========================================
-- Données de test pour CandidaturePlus
-- Ce script insert les données nécessaires pour les tests
-- =========================================
USE candidature_plus;

-- =========================================
-- INSERTION DES CENTRES
-- =========================================
INSERT INTO
    Centre (nom, adresse, ville, telephone, email, actif)
VALUES
    (
        'Centre Rabat',
        '123 Avenue Mohammed V',
        'Rabat',
        '05377712345',
        'rabat@centres.ma',
        TRUE
    ),
    (
        'Centre Casablanca',
        '456 Boulevard Zerktouni',
        'Casablanca',
        '05227798765',
        'casablanca@centres.ma',
        TRUE
    ),
    (
        'Centre Marrakech',
        '789 Avenue Yacoub El Mansour',
        'Marrakech',
        '05247723456',
        'marrakech@centres.ma',
        TRUE
    ),
    (
        'Centre Fès',
        '321 Rue Atlas',
        'Fès',
        '05357734567',
        'fes@centres.ma',
        TRUE
    ),
    (
        'Centre Tanger',
        '654 Boulevard Pasteur',
        'Tanger',
        '05398876543',
        'tanger@centres.ma',
        TRUE
    );

-- =========================================
-- INSERTION DES SPÉCIALITÉS
-- =========================================
INSERT INTO
    Specialite (nom, code, description, actif)
VALUES
    (
        'Informatique',
        'INFO',
        'Technologies de l''information et développement',
        TRUE
    ),
    (
        'Génie Civil',
        'GC',
        'Construction et travaux publics',
        TRUE
    ),
    (
        'Électronique',
        'ELEC',
        'Systèmes électroniques et télécommunications',
        TRUE
    ),
    (
        'Mécanique',
        'MECA',
        'Génie mécanique et industriel',
        TRUE
    ),
    (
        'Finance',
        'FIN',
        'Gestion financière et comptabilité',
        TRUE
    ),
    (
        'Marketing',
        'MKT',
        'Marketing et communication',
        TRUE
    ),
    (
        'Ressources Humaines',
        'RH',
        'Gestion des ressources humaines',
        TRUE
    ),
    ('Droit', 'DROIT', 'Sciences juridiques', TRUE),
    (
        'Administration',
        'ADMIN',
        'Administration publique',
        TRUE
    ),
    (
        'Comptabilité',
        'COMPTA',
        'Comptabilité et audit',
        TRUE
    );

-- =========================================
-- INSERTION DES CONCOURS
-- =========================================
INSERT INTO
    Concours (
        nom,
        description,
        date_debut_candidature,
        date_fin_candidature,
        date_examen,
        conditions_participation,
        documents_requis,
        fiche_concours_url,
        actif
    )
VALUES
    (
        'Concours Techniciens 2025',
        'Recrutement de techniciens spécialisés dans diverses spécialités pour la fonction publique',
        '2025-02-01',
        '2025-03-15',
        '2025-04-20',
        'Diplôme de technicien ou équivalent. Âge: 18-35 ans. Nationalité marocaine.',
        'CIN, CV, Diplôme, Relevé de notes, Photo d''identité',
        '/documents/fiches/technicien-2025.pdf',
        TRUE
    ),
    (
        'Concours Attachés Administration 2025',
        'Recrutement d''attachés d''administration pour les services centraux',
        '2025-01-15',
        '2025-02-28',
        '2025-03-25',
        'Licence ou équivalent. Âge: 21-40 ans. Expérience souhaitée.',
        'CIN, CV, Diplôme, Relevé de notes, Photo, Certificat de travail',
        '/documents/fiches/attache-administration-2025.pdf',
        TRUE
    ),
    (
        'Concours Inspecteurs Finances 2025',
        'Recrutement d''inspecteurs des finances publiques',
        '2025-03-01',
        '2025-04-15',
        '2025-05-20',
        'Master en Finance/Économie. Âge: 23-45 ans. Excellent niveau en français et arabe.',
        'CIN, CV, Diplôme Master, Relevés de notes, Photo, Certificats de langue',
        '/documents/fiches/inspecteur-finances-2025.pdf',
        TRUE
    );

-- =========================================
-- LIAISON CONCOURS-SPÉCIALITÉS
-- =========================================
INSERT INTO
    Concours_Specialite (concours_id, specialite_id, nombre_places)
VALUES
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
    (3, 10, 15);

-- Comptabilité
-- =========================================
-- LIAISON CENTRE-SPÉCIALITÉS (Places disponibles)
-- =========================================
INSERT INTO
    Centre_Specialite (
        centre_id,
        specialite_id,
        concours_id,
        nombre_places_disponibles,
        places_occupees
    )
VALUES
    -- Centre Rabat
    (1, 1, 1, 20, 0), -- Informatique Techniciens
    (1, 2, 1, 15, 0), -- Génie Civil Techniciens
    (1, 9, 2, 15, 0), -- Administration Attachés
    (1, 5, 3, 10, 0), -- Finance Inspecteurs
    -- Centre Casablanca  
    (2, 1, 1, 15, 0), -- Informatique Techniciens
    (2, 3, 1, 12, 0), -- Électronique Techniciens
    (2, 6, 2, 10, 0), -- Marketing Attachés
    (2, 5, 3, 8, 0), -- Finance Inspecteurs
    -- Centre Marrakech
    (3, 1, 1, 10, 0), -- Informatique Techniciens
    (3, 4, 1, 8, 0), -- Mécanique Techniciens
    (3, 7, 2, 8, 0), -- RH Attachés
    (3, 10, 3, 4, 0), -- Comptabilité Inspecteurs
    -- Centre Fès
    (4, 2, 1, 10, 0), -- Génie Civil Techniciens
    (4, 3, 1, 8, 0), -- Électronique Techniciens
    (4, 8, 2, 5, 0), -- Droit Attachés
    (4, 10, 3, 3, 0), -- Comptabilité Inspecteurs
    -- Centre Tanger
    (5, 1, 1, 5, 0), -- Informatique Techniciens
    (5, 4, 1, 12, 0), -- Mécanique Techniciens
    (5, 9, 2, 12, 0), -- Administration Attachés
    (5, 5, 3, 5, 0);

-- Finance Inspecteurs
-- =========================================
-- INSERTION DES UTILISATEURS (Gestionnaires)
-- =========================================
INSERT INTO
    Utilisateur (
        nom,
        prenom,
        email,
        mot_de_passe,
        role,
        centre_id,
        actif
    )
VALUES
    -- Gestionnaires Locaux
    (
        'Alami',
        'Hassan',
        'h.alami@mf.gov.ma',
        '$2a$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewRqGCaVeDqHOvfK',
        'GestionnaireLocal',
        1,
        TRUE
    ), -- 1234
    (
        'Bennani',
        'Fatima',
        'f.bennani@mf.gov.ma',
        '$2a$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewRqGCaVeDqHOvfK',
        'GestionnaireLocal',
        2,
        TRUE
    ), -- 1234
    (
        'Tazi',
        'Mohammed',
        'm.tazi@mf.gov.ma',
        '$2a$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewRqGCaVeDqHOvfK',
        'GestionnaireLocal',
        3,
        TRUE
    ), -- 1234
    (
        'Fassi',
        'Aicha',
        'a.fassi@mf.gov.ma',
        '$2a$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewRqGCaVeDqHOvfK',
        'GestionnaireLocal',
        4,
        TRUE
    ), -- 1234
    -- Gestionnaire Global
    (
        'Chraibi',
        'Mehdi',
        'm.chraibi@mf.gov.ma',
        '$2a$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewRqGCaVeDqHOvfK',
        'GestionnaireGlobal',
        NULL,
        TRUE
    ), -- 1234
    -- Administrateurs
    (
        'Talbi',
        'Abdelkarim',
        'a.talbi@mf.gov.ma',
        '$2a$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewRqGCaVeDqHOvfK',
        'Administrateur',
        NULL,
        TRUE
    ), -- 1234
    (
        'Admin',
        'Test',
        'admin@test.com',
        '$2a$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewRqGCaVeDqHOvfK',
        'Administrateur',
        NULL,
        TRUE
    );

-- 1234
-- =========================================
-- INSERTION DE CANDIDATS DE TEST
-- =========================================
INSERT INTO
    Candidat (
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
        conditions_acceptees
    )
VALUES
    (
        'CAND1701234567890',
        'Benali',
        'Youssef',
        'Monsieur',
        'AB123456',
        '1995-03-15',
        'Casablanca',
        '25 Rue des Roses, Maarif',
        'Casablanca',
        '20000',
        'y.benali@gmail.com',
        '0661234567',
        '0522987654',
        'DUT',
        'DUT Informatique',
        'Informatique',
        'ISTA Casablanca',
        2018,
        'Stage de 6 mois chez ISTA',
        TRUE
    ),
    (
        'CAND1701234567891',
        'Alaoui',
        'Khadija',
        'Madame',
        'CD789012',
        '1993-07-22',
        'Rabat',
        '12 Avenue Moulay Hassan, Agdal',
        'Rabat',
        '10000',
        'k.alaoui@gmail.com',
        '0662345678',
        '0537876543',
        'Licence',
        'Licence Génie Civil',
        'Génie Civil',
        'EHTP Casablanca',
        2016,
        'Employée dans une PME pendant 3 ans',
        TRUE
    ),
    (
        'CAND1701234567892',
        'Ouali',
        'Ahmed',
        'Monsieur',
        'EF345678',
        '1992-11-08',
        'Fès',
        '8 Rue Ibn Sina, Ville Nouvelle',
        'Fès',
        '30000',
        'a.ouali@gmail.com',
        '0663456789',
        '0535765432',
        'Master',
        'Master Finance',
        'Finance',
        'FSJES Fès',
        2017,
        'Analyste financier junior pendant 2 ans',
        TRUE
    ),
    (
        'CAND1701234567893',
        'Radi',
        'Samira',
        'Madame',
        'GH901234',
        '1994-05-12',
        'Marrakech',
        '15 Boulevard Zerktouni, Gueliz',
        'Marrakech',
        '40000',
        's.radi@gmail.com',
        '0664567890',
        '0524654321',
        'DTS',
        'DTS Électronique',
        'Électronique',
        'ISTA Marrakech',
        2019,
        'Technicienne en électronique pendant 1 an',
        TRUE
    ),
    (
        'CAND1701234567894',
        'Ziani',
        'Omar',
        'Monsieur',
        'IJ567890',
        '1996-02-28',
        'Tanger',
        '22 Rue Al Mourabitoune, Centre ville',
        'Tanger',
        '90000',
        'o.ziani@gmail.com',
        '0665678901',
        '0539876543',
        'BTS',
        'BTS Mécanique',
        'Mécanique',
        'ISTA Tanger',
        2020,
        'Mécanicien spécialisé pendant 1 an',
        TRUE
    );

-- =========================================
-- INSERTION DE CANDIDATURES DE TEST
-- =========================================
INSERT INTO
    Candidature (
        candidat_id,
        concours_id,
        specialite_id,
        centre_id,
        etat,
        date_soumission,
        gestionnaire_id,
        numero_place
    )
VALUES
    (
        1,
        1,
        1,
        1,
        'Validee',
        '2025-01-20 10:30:00',
        1,
        1
    ), -- Youssef validé
    (
        2,
        1,
        2,
        1,
        'En_Cours_Validation',
        '2025-01-21 14:15:00',
        NULL,
        NULL
    ), -- Khadija en cours
    (
        3,
        3,
        5,
        1,
        'Soumise',
        '2025-01-22 09:45:00',
        NULL,
        NULL
    ), -- Ahmed soumis
    (
        4,
        1,
        3,
        2,
        'Rejetee',
        '2025-01-19 16:20:00',
        2,
        NULL
    ), -- Samira rejetée
    (
        5,
        1,
        4,
        5,
        'Confirmee',
        '2025-01-18 11:00:00',
        4,
        2
    );

-- Omar confirmé
-- =========================================
-- INSERTION DE NOTIFICATIONS DE TEST
-- =========================================
INSERT INTO
    Notification (
        type_destinataire,
        destinataire_id,
        type_notification,
        sujet,
        message,
        etat,
        date_envoi
    )
VALUES
    (
        'Candidat',
        1,
        'Email',
        'Candidature Validée',
        'Félicitations ! Votre candidature a été validée. Votre numéro de place est: 1',
        'Envoye',
        NOW ()
    ),
    (
        'Candidat',
        4,
        'Email',
        'Candidature Rejetée',
        'Nous regrettons de vous informer que votre candidature a été rejetée. Motif: Documents incomplets',
        'Envoye',
        NOW ()
    ),
    (
        'Candidat',
        5,
        'Email',
        'Candidature Confirmée',
        'Votre participation au concours est confirmée. Présentez-vous le jour J avec votre CIN.',
        'Envoye',
        NOW ()
    );

-- =========================================
-- INSERTION DE LOGS DE TEST
-- =========================================
INSERT INTO
    Log_Action (
        type_acteur,
        acteur_id,
        action,
        table_cible,
        enregistrement_id,
        details,
        ip_adresse,
        date_action
    )
VALUES
    (
        'Candidat',
        1,
        'NOUVELLE_CANDIDATURE',
        'Candidature',
        1,
        '{"concours_id": 1, "centre_id": 1}',
        '192.168.1.100',
        '2025-01-20 10:30:00'
    ),
    (
        'Utilisateur',
        1,
        'VALIDATION_CANDIDATURE',
        'Candidature',
        1,
        '{"ancien_etat": "Soumise", "nouvel_etat": "Validee"}',
        '192.168.1.50',
        '2025-01-20 15:00:00'
    ),
    (
        'Utilisateur',
        2,
        'REJET_CANDIDATURE',
        'Candidature',
        4,
        '{"ancien_etat": "Soumise", "nouvel_etat": "Rejetee", "motif": "Documents incomplets"}',
        '192.168.1.51',
        '2025-01-19 17:00:00'
    );

SELECT
    'Données de test insérées avec succès!' AS Status;

SELECT
    'Comptes disponibles:' AS Info;

SELECT
    CONCAT ('- ', email, ' (', role, ')') AS Comptes
FROM
    Utilisateur
WHERE
    actif = TRUE;