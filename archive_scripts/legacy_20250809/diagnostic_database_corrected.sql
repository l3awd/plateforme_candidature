-- ===============================================
-- SCRIPT DE DIAGNOSTIC BASE DE DONNÉES - VERSION CORRIGÉE
-- Plateforme Candidature - Vérification complète
-- ===============================================
USE candidature_plus;

-- 1. VÉRIFICATION DE L'EXISTENCE DES TABLES
-- ===============================================
SELECT
    'VÉRIFICATION DES TABLES' as TYPE_VERIFICATION;

SELECT
    TABLE_NAME as 'Table',
    TABLE_ROWS as 'Nombre_Lignes',
    TABLE_TYPE as 'Type'
FROM
    information_schema.TABLES
WHERE
    TABLE_SCHEMA = 'candidature_plus'
ORDER BY
    TABLE_NAME;

-- 2. COMPTAGE DES DONNÉES PAR TABLE (NOMS RÉELS)
-- ===============================================
SELECT
    'COMPTAGE DES DONNÉES' as TYPE_VERIFICATION;

SELECT
    'candidat' as Table_Name,
    COUNT(*) as Nombre_Enregistrements
FROM
    candidat
UNION ALL
SELECT
    'utilisateur' as Table_Name,
    COUNT(*) as Nombre_Enregistrements
FROM
    utilisateur
UNION ALL
SELECT
    'centre' as Table_Name,
    COUNT(*) as Nombre_Enregistrements
FROM
    centre
UNION ALL
SELECT
    'concours' as Table_Name,
    COUNT(*) as Nombre_Enregistrements
FROM
    concours
UNION ALL
SELECT
    'specialite' as Table_Name,
    COUNT(*) as Nombre_Enregistrements
FROM
    specialite
UNION ALL
SELECT
    'candidature' as Table_Name,
    COUNT(*) as Nombre_Enregistrements
FROM
    candidature
UNION ALL
SELECT
    'document' as Table_Name,
    COUNT(*) as Nombre_Enregistrements
FROM
    document
UNION ALL
SELECT
    'log_action' as Table_Name,
    COUNT(*) as Nombre_Enregistrements
FROM
    log_action
UNION ALL
SELECT
    'notification' as Table_Name,
    COUNT(*) as Nombre_Enregistrements
FROM
    notification
UNION ALL
SELECT
    'concours_specialite' as Table_Name,
    COUNT(*) as Nombre_Enregistrements
FROM
    concours_specialite
UNION ALL
SELECT
    'concourscentre' as Table_Name,
    COUNT(*) as Nombre_Enregistrements
FROM
    concourscentre
UNION ALL
SELECT
    'centre_specialite' as Table_Name,
    COUNT(*) as Nombre_Enregistrements
FROM
    centre_specialite;

-- 3. VÉRIFICATION DES DONNÉES CRITIQUES
-- ===============================================
SELECT
    'VÉRIFICATION DONNÉES CRITIQUES' as TYPE_VERIFICATION;

-- Utilisateurs administrateur
SELECT
    'Utilisateurs Administrateur' as Verification,
    COUNT(*) as Nombre
FROM
    utilisateur
WHERE
    role = 'Administrateur'
    AND actif = true;

-- Concours actifs
SELECT
    'Concours Actifs' as Verification,
    COUNT(*) as Nombre
FROM
    concours
WHERE
    actif = true;

-- Centres actifs
SELECT
    'Centres Actifs' as Verification,
    COUNT(*) as Nombre
FROM
    centre
WHERE
    actif = true;

-- Spécialités actives
SELECT
    'Spécialités Actives' as Verification,
    COUNT(*) as Nombre
FROM
    specialite
WHERE
    actif = true;

-- 4. VÉRIFICATION DES RELATIONS MANQUANTES
-- ===============================================
SELECT
    'VÉRIFICATION RELATIONS MANQUANTES' as TYPE_VERIFICATION;

-- Candidatures sans candidat
SELECT
    'Candidatures sans candidat' as Probleme,
    COUNT(*) as Nombre
FROM
    candidature c
    LEFT JOIN candidat cd ON c.candidat_id = cd.id
WHERE
    cd.id IS NULL;

-- Candidatures sans concours
SELECT
    'Candidatures sans concours' as Probleme,
    COUNT(*) as Nombre
FROM
    candidature c
    LEFT JOIN concours co ON c.concours_id = co.id
WHERE
    co.id IS NULL;

-- Candidatures sans centre
SELECT
    'Candidatures sans centre' as Probleme,
    COUNT(*) as Nombre
FROM
    candidature c
    LEFT JOIN centre ce ON c.centre_id = ce.id
WHERE
    ce.id IS NULL;

-- Candidatures sans spécialité
SELECT
    'Candidatures sans spécialité' as Probleme,
    COUNT(*) as Nombre
FROM
    candidature c
    LEFT JOIN specialite s ON c.specialite_id = s.id
WHERE
    s.id IS NULL;

-- Utilisateurs sans centre (pour gestionnaires locaux)
SELECT
    'Gestionnaires sans centre' as Probleme,
    COUNT(*) as Nombre
FROM
    utilisateur u
WHERE
    u.role = 'GestionnaireLocal'
    AND u.centre_id IS NULL;

-- 5. VÉRIFICATION DES VALEURS NULL CRITIQUES
-- ===============================================
SELECT
    'VÉRIFICATION VALEURS NULL' as TYPE_VERIFICATION;

-- Candidats sans informations critiques
SELECT
    'Candidats sans email' as Probleme,
    COUNT(*) as Nombre
FROM
    candidat
WHERE
    email IS NULL
    OR email = '';

SELECT
    'Candidats sans CIN' as Probleme,
    COUNT(*) as Nombre
FROM
    candidat
WHERE
    cin IS NULL
    OR cin = '';

SELECT
    'Candidats sans nom' as Probleme,
    COUNT(*) as Nombre
FROM
    candidat
WHERE
    nom IS NULL
    OR nom = '';

-- Utilisateurs sans informations critiques
SELECT
    'Utilisateurs sans email' as Probleme,
    COUNT(*) as Nombre
FROM
    utilisateur
WHERE
    email IS NULL
    OR email = '';

SELECT
    'Utilisateurs sans mot de passe' as Probleme,
    COUNT(*) as Nombre
FROM
    utilisateur
WHERE
    mot_de_passe IS NULL
    OR mot_de_passe = '';

-- 6. VÉRIFICATION DES DOUBLONS
-- ===============================================
SELECT
    'VÉRIFICATION DOUBLONS' as TYPE_VERIFICATION;

-- Candidats avec même CIN
SELECT
    'Candidats CIN doublons' as Probleme,
    COUNT(*) as Nombre
FROM
    (
        SELECT
            cin,
            COUNT(*) as nb
        FROM
            candidat
        WHERE
            cin IS NOT NULL
        GROUP BY
            cin
        HAVING
            COUNT(*) > 1
    ) as doublons;

-- Candidats avec même email
SELECT
    'Candidats email doublons' as Probleme,
    COUNT(*) as Nombre
FROM
    (
        SELECT
            email,
            COUNT(*) as nb
        FROM
            candidat
        WHERE
            email IS NOT NULL
        GROUP BY
            email
        HAVING
            COUNT(*) > 1
    ) as doublons;

-- Utilisateurs avec même email
SELECT
    'Utilisateurs email doublons' as Probleme,
    COUNT(*) as Nombre
FROM
    (
        SELECT
            email,
            COUNT(*) as nb
        FROM
            utilisateur
        WHERE
            email IS NOT NULL
        GROUP BY
            email
        HAVING
            COUNT(*) > 1
    ) as doublons;

-- 7. VÉRIFICATION DES ASSOCIATIONS CONCOURS-SPÉCIALITÉS-CENTRES
-- ===============================================
SELECT
    'VÉRIFICATION ASSOCIATIONS' as TYPE_VERIFICATION;

-- Concours sans spécialités
SELECT
    'Concours sans spécialités' as Probleme,
    COUNT(*) as Nombre
FROM
    concours c
    LEFT JOIN concours_specialite cs ON c.id = cs.concours_id
WHERE
    cs.concours_id IS NULL
    AND c.actif = true;

-- Concours sans centres
SELECT
    'Concours sans centres' as Probleme,
    COUNT(*) as Nombre
FROM
    concours c
    LEFT JOIN concourscentre cc ON c.id = cc.concours_id
WHERE
    cc.concours_id IS NULL
    AND c.actif = true;

-- 8. STATISTIQUES PAR ÉTAT DES CANDIDATURES
-- ===============================================
SELECT
    'STATISTIQUES CANDIDATURES' as TYPE_VERIFICATION;

SELECT
    etat as 'État_Candidature',
    COUNT(*) as 'Nombre'
FROM
    candidature
GROUP BY
    etat
ORDER BY
    COUNT(*) DESC;

-- 9. TOP 5 DES CONCOURS LES PLUS DEMANDÉS
-- ===============================================
SELECT
    'TOP CONCOURS DEMANDÉS' as TYPE_VERIFICATION;

SELECT
    co.nom as 'Concours',
    COUNT(ca.id) as 'Nombre_Candidatures'
FROM
    concours co
    LEFT JOIN candidature ca ON co.id = ca.concours_id
GROUP BY
    co.id,
    co.nom
ORDER BY
    COUNT(ca.id) DESC
LIMIT
    5;

-- 10. TOP 5 DES CENTRES LES PLUS DEMANDÉS
-- ===============================================
SELECT
    'TOP CENTRES DEMANDÉS' as TYPE_VERIFICATION;

SELECT
    ce.nom as 'Centre',
    ce.ville as 'Ville',
    COUNT(ca.id) as 'Nombre_Candidatures'
FROM
    centre ce
    LEFT JOIN candidature ca ON ce.id = ca.centre_id
GROUP BY
    ce.id,
    ce.nom,
    ce.ville
ORDER BY
    COUNT(ca.id) DESC
LIMIT
    5;

-- 11. RÉSUMÉ FINAL
-- ===============================================
SELECT
    'RÉSUMÉ DIAGNOSTIC' as TYPE_VERIFICATION;

SELECT
    'TOTAL TABLES' as Métrique,
    COUNT(*) as Valeur
FROM
    information_schema.TABLES
WHERE
    TABLE_SCHEMA = 'candidature_plus'
    AND TABLE_TYPE = 'BASE TABLE';

SELECT
    'TOTAL CANDIDATURES' as Métrique,
    COUNT(*) as Valeur
FROM
    candidature;

SELECT
    'TOTAL CANDIDATS' as Métrique,
    COUNT(*) as Valeur
FROM
    candidat;

SELECT
    'TOTAL UTILISATEURS ACTIFS' as Métrique,
    COUNT(*) as Valeur
FROM
    utilisateur
WHERE
    actif = true;

SELECT
    'CONCOURS DISPONIBLES' as Métrique,
    COUNT(*) as Valeur
FROM
    concours
WHERE
    actif = true
    AND date_debut_candidature <= CURDATE ()
    AND date_fin_candidature >= CURDATE ();

-- 12. RECOMMANDATIONS FINALES
-- ===============================================
SELECT
    'RECOMMANDATIONS' as TYPE_VERIFICATION;

SELECT
    CASE
        WHEN (
            SELECT
                COUNT(*)
            FROM
                utilisateur
            WHERE
                role = 'Administrateur'
                AND actif = true
        ) = 0 THEN '⚠️ URGENT: Créer un administrateur'
        WHEN (
            SELECT
                COUNT(*)
            FROM
                concours
            WHERE
                actif = true
        ) = 0 THEN '⚠️ Ajouter des concours actifs'
        WHEN (
            SELECT
                COUNT(*)
            FROM
                centre
            WHERE
                actif = true
        ) = 0 THEN '⚠️ Ajouter des centres actifs'
        WHEN (
            SELECT
                COUNT(*)
            FROM
                specialite
            WHERE
                actif = true
        ) = 0 THEN '⚠️ Ajouter des spécialités actives'
        ELSE '✅ Configuration de base OK'
    END as 'Recommandation_Prioritaire';

SELECT
    'DIAGNOSTIC TERMINÉ' as 'STATUS',
    NOW () as 'Timestamp';