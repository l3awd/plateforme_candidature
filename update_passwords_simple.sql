-- Script pour remettre les mots de passe en clair (pas de cryptage)
-- Password: "1234" en clair
UPDATE Utilisateur
SET
    mot_de_passe = '1234'
WHERE
    email = 'admin@test.com';

UPDATE Utilisateur
SET
    mot_de_passe = '1234'
WHERE
    email = 'h.alami@mf.gov.ma';

UPDATE Utilisateur
SET
    mot_de_passe = '1234'
WHERE
    email = 'm.chraibi@mf.gov.ma';

-- Vérification des utilisateurs mis à jour
SELECT
    email,
    mot_de_passe,
    role
FROM
    Utilisateur
WHERE
    email IN (
        'admin@test.com',
        'h.alami@mf.gov.ma',
        'm.chraibi@mf.gov.ma'
    );