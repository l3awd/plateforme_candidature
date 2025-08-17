-- =====================================================
-- INSERTION DE DONNÉES DE TEST POUR FONCTIONNALITÉS
-- =====================================================
-- 1. Insérer des candidatures de test pour chaque gestionnaire
-- =====================================================
INSERT INTO
    Candidature (
        candidat_id,
        concours_id,
        specialite_id,
        centre_id,
        etat,
        date_soumission,
        motif_rejet,
        commentaire_gestionnaire,
        gestionnaire_id,
        numero_place
    )
SELECT
    c.id,
    co.id,
    s.id,
    ce.id,
    CASE
        WHEN RAND () < 0.3 THEN 'Validee'
        WHEN RAND () < 0.6 THEN 'En_Cours_Validation'
        WHEN RAND () < 0.8 THEN 'Rejetee'
        ELSE 'Soumise'
    END,
    DATE_SUB (NOW (), INTERVAL FLOOR(RAND () * 30) DAY),
    CASE
        WHEN RAND () < 0.2 THEN 'Documents incomplets'
        ELSE NULL
    END,
    CASE
        WHEN RAND () < 0.3 THEN 'Candidature examinée avec attention'
        ELSE NULL
    END,
    u.id,
    CASE
        WHEN RAND () < 0.3 THEN FLOOR(RAND () * 100) + 1
        ELSE NULL
    END
FROM
    Candidat c
    CROSS JOIN Concours co
    CROSS JOIN Specialite s
    CROSS JOIN Centre ce
    CROSS JOIN Utilisateur u
WHERE
    c.id <= 15
    AND co.id <= 3
    AND s.id <= 5
    AND ce.id <= 3
    AND u.role = 'gestionnaire_local'
    AND RAND () < 0.4 -- 40% de chance de créer une candidature
LIMIT
    25;

-- 2. Mise à jour des concours avec des spécialités et centres
-- =====================================================
-- Assurer que les concours ont bien des associations
DELETE FROM ConcourSpecialite
WHERE
    concours_id IN (1, 2, 3);

DELETE FROM ConcoursCentre
WHERE
    concours_id IN (1, 2, 3);

-- Concours 1: Techniciens - Spécialités informatique/électronique
INSERT INTO
    ConcourSpecialite (concours_id, specialite_id, places_disponibles)
VALUES
    (1, 1, 30), -- Informatique
    (1, 2, 25), -- Électronique
    (1, 3, 20);

-- Mécanique
INSERT INTO
    ConcoursCentre (concours_id, centre_id, places_disponibles)
VALUES
    (1, 1, 40), -- Rabat
    (1, 2, 35), -- Casablanca
    (1, 3, 30);

-- Fès
-- Concours 2: Attachés Administration - Spécialités gestion/droit
INSERT INTO
    ConcourSpecialite (concours_id, specialite_id, places_disponibles)
VALUES
    (2, 4, 25), -- Gestion
    (2, 5, 20), -- Droit
    (2, 1, 15);

-- Informatique
INSERT INTO
    ConcoursCentre (concours_id, centre_id, places_disponibles)
VALUES
    (2, 1, 30), -- Rabat
    (2, 2, 25), -- Casablanca
    (2, 3, 20);

-- Fès
-- Concours 3: Inspecteurs Finances - Spécialités économie/gestion
INSERT INTO
    ConcourSpecialite (concours_id, specialite_id, places_disponibles)
VALUES
    (3, 4, 20), -- Gestion
    (3, 5, 15), -- Droit
    (3, 2, 10);

-- Électronique
INSERT INTO
    ConcoursCentre (concours_id, centre_id, places_disponibles)
VALUES
    (3, 1, 25), -- Rabat
    (3, 2, 20), -- Casablanca
    (3, 3, 15);

-- Fès
-- 3. Mise à jour des gestionnaires avec centres assignés
-- =====================================================
UPDATE Utilisateur
SET
    centres_assignes = JSON_ARRAY (1, 2)
WHERE
    role = 'gestionnaire_local'
    AND id = 1;

UPDATE Utilisateur
SET
    centres_assignes = JSON_ARRAY (2, 3)
WHERE
    role = 'gestionnaire_local'
    AND id > 1;

-- 4. Ajouter des fiches de concours
-- =====================================================
UPDATE Concours
SET
    fiche_concours_url = 'http://localhost:8080/documents/fiches/technicien-informatique-2025.pdf',
    conditions_participation = 'Diplôme Bac+2 minimum en informatique\nÂge maximum: 45 ans\nNationalité marocaine',
    documents_requis = 'CV\nCopie CIN\nCopie diplôme\nPhoto d''identité'
WHERE
    id = 1;

UPDATE Concours
SET
    fiche_concours_url = 'http://localhost:8080/documents/fiches/attache-administration-2025.pdf',
    conditions_participation = 'Diplôme Licence minimum\nÂge maximum: 40 ans\nNationalité marocaine',
    documents_requis = 'CV\nCopie CIN\nCopie diplôme\nPhoto d''identité\nCasier judiciaire'
WHERE
    id = 2;

UPDATE Concours
SET
    fiche_concours_url = 'http://localhost:8080/documents/fiches/inspecteur-finances-2025.pdf',
    conditions_participation = 'Diplôme Master en finances/économie\nÂge maximum: 35 ans\nExpérience minimum 3 ans',
    documents_requis = 'CV détaillé\nCopie CIN\nCopie diplôme\nAttestation de travail\nPhoto d''identité'
WHERE
    id = 3;

-- =====================================================
-- DONNÉES DE TEST INSÉRÉES AVEC SUCCÈS
-- =====================================================