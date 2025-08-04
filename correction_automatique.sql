-- =========================================
-- SCRIPT DE CORRECTION AUTOMATIQUE
-- Généré pour résoudre les problèmes de postes non visibles
-- =========================================
USE candidature_plus;

-- 1. Activer tous les concours
UPDATE Concours
SET
    actif = true
WHERE
    actif = false
    OR actif IS NULL;

-- 2. Mettre à jour les dates des concours pour les rendre disponibles
UPDATE Concours
SET
    dateFinCandidature = DATE_ADD (CURDATE (), INTERVAL 60 DAY)
WHERE
    actif = true
    AND (
        dateFinCandidature < CURDATE ()
        OR dateFinCandidature IS NULL
    );

-- 3. Mettre à jour les dates de début pour qu'elles soient valides
UPDATE Concours
SET
    dateDebutCandidature = CURDATE ()
WHERE
    actif = true
    AND (
        dateDebutCandidature > CURDATE ()
        OR dateDebutCandidature IS NULL
    );

-- 4. S'assurer que nous avons des données de test minimales
INSERT IGNORE INTO Concours (
    nom,
    description,
    dateDebutCandidature,
    dateFinCandidature,
    dateExamen,
    actif
)
VALUES
    (
        'Technicien Informatique 2025',
        'Recrutement de techniciens informatiques',
        CURDATE (),
        DATE_ADD (CURDATE (), INTERVAL 60 DAY),
        DATE_ADD (CURDATE (), INTERVAL 90 DAY),
        true
    );

-- 5. S'assurer que nous avons des centres
INSERT IGNORE INTO Centre (nom, ville, adresse, actif)
VALUES
    (
        'Centre Rabat',
        'Rabat',
        'Avenue Mohammed V',
        true
    ),
    (
        'Centre Casablanca',
        'Casablanca',
        'Boulevard Hassan II',
        true
    ),
    ('Centre Fès', 'Fès', 'Rue des Mérinides', true);

-- 6. S'assurer que nous avons des spécialités
INSERT IGNORE INTO Specialite (nom, code, description, domaine, actif)
VALUES
    (
        'Informatique',
        'INFO',
        'Spécialité Informatique',
        'Technologie',
        true
    ),
    (
        'Réseaux',
        'RES',
        'Spécialité Réseaux et Télécommunications',
        'Technologie',
        true
    ),
    (
        'Gestion',
        'GEST',
        'Spécialité Gestion',
        'Administration',
        true
    );

-- 7. Créer des associations concours-spécialités si elles n'existent pas
INSERT IGNORE INTO ConcourSpecialite (concours_id, specialite_id, places_disponibles)
SELECT
    c.id,
    s.id,
    50
FROM
    Concours c
    CROSS JOIN Specialite s
WHERE
    c.actif = true
    AND s.actif = true;

-- 8. Créer des associations concours-centres si elles n'existent pas
INSERT IGNORE INTO ConcoursCentre (concours_id, centre_id, places_disponibles)
SELECT
    c.id,
    ce.id,
    100
FROM
    Concours c
    CROSS JOIN Centre ce
WHERE
    c.actif = true
    AND ce.actif = true;

-- 9. Vérifier les résultats après correction
SELECT
    'CONCOURS ACTIFS' as verification,
    COUNT(*) as nombre
FROM
    Concours
WHERE
    actif = true;

SELECT
    'CONCOURS OUVERTS' as verification,
    COUNT(*) as nombre
FROM
    Concours
WHERE
    actif = true
    AND dateDebutCandidature <= CURDATE ()
    AND dateFinCandidature >= CURDATE ();

SELECT
    'CENTRES' as verification,
    COUNT(*) as nombre
FROM
    Centre
WHERE
    actif = true;

SELECT
    'SPÉCIALITÉS' as verification,
    COUNT(*) as nombre
FROM
    Specialite
WHERE
    actif = true;

SELECT
    'ASSOCIATIONS CONCOURS-SPECIALITES' as verification,
    COUNT(*) as nombre
FROM
    ConcourSpecialite;

SELECT
    'ASSOCIATIONS CONCOURS-CENTRES' as verification,
    COUNT(*) as nombre
FROM
    ConcoursCentre;

-- 10. Afficher les concours ouverts avec leurs détails
SELECT
    c.nom as concours,
    c.dateDebutCandidature,
    c.dateFinCandidature,
    DATEDIFF (c.dateFinCandidature, CURDATE ()) as jours_restants,
    COUNT(DISTINCT cs.specialite_id) as nb_specialites,
    COUNT(DISTINCT cc.centre_id) as nb_centres
FROM
    Concours c
    LEFT JOIN ConcourSpecialite cs ON c.id = cs.concours_id
    LEFT JOIN ConcoursCentre cc ON c.id = cc.concours_id
WHERE
    c.actif = true
GROUP BY
    c.id,
    c.nom,
    c.dateDebutCandidature,
    c.dateFinCandidature
ORDER BY
    c.dateFinCandidature;

COMMIT;