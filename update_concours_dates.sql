-- Met à jour les dates des concours pour qu'ils soient ouverts aujourd'hui
-- Idempotent: n'affecte que les concours expirés ou non ouverts
USE candidature_plus;

-- Ouvrir les concours expirés: fenêtre [aujourd'hui-7j ; aujourd'hui+45j]
UPDATE Concours
SET
    date_debut_candidature = LEAST (
        date_debut_candidature,
        CURDATE () - INTERVAL 7 DAY
    ),
    date_fin_candidature = CURDATE () + INTERVAL 45 DAY,
    actif = 1
WHERE
    date_fin_candidature < CURDATE ();

-- Optionnel: si un concours commence dans le futur proche (> aujourd'hui) on l'ouvre dès maintenant
UPDATE Concours
SET
    date_debut_candidature = CURDATE () - INTERVAL 3 DAY,
    actif = 1
WHERE
    date_debut_candidature > CURDATE ()
    AND date_debut_candidature <= CURDATE () + INTERVAL 30 DAY;

-- Vérification rapide
SELECT
    id,
    nom,
    date_debut_candidature,
    date_fin_candidature,
    actif
FROM
    Concours
ORDER BY
    id;