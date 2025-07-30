-- Mise à jour des dates pour avoir des concours ouverts
USE candidature_plus;

-- Mettre à jour les dates pour que les concours soient ouverts maintenant
UPDATE Concours SET 
    date_debut_candidature = '2025-07-01',
    date_fin_candidature = '2025-08-31',
    date_examen = '2025-09-15'
WHERE id IN (1,2,3,4,5,6,7,8,9,10,11,12,13);

-- Vérification
SELECT id, nom, date_debut_candidature, date_fin_candidature, 
       CASE 
           WHEN CURDATE() BETWEEN date_debut_candidature AND date_fin_candidature 
           THEN 'OUVERT' 
           ELSE 'FERME' 
       END as statut
FROM Concours 
WHERE actif = 1;
