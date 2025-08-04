-- ===============================================
-- SCRIPT DE DIAGNOSTIC BASE DE DONNÉES
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

-- 2. VÉRIFICATION DES CONTRAINTES ET CLÉS ÉTRANGÈRES
-- ===============================================
SELECT
    'VÉRIFICATION DES CONTRAINTES' as TYPE_VERIFICATION;

SELECT
    TABLE_NAME as 'Table',
    COLUMN_NAME as 'Colonne',
    CONSTRAINT_NAME as 'Contrainte',
    REFERENCED_TABLE_NAME as 'Table_Référencée',
    REFERENCED_COLUMN_NAME as 'Colonne_Référencée'
FROM
    information_schema.KEY_COLUMN_USAGE
WHERE
    TABLE_SCHEMA = 'candidature_plus'
    AND REFERENCED_TABLE_NAME IS NOT NULL
ORDER BY
    TABLE_NAME,
    COLUMN_NAME;

-- 3. VÉRIFICATION DES INDEX
-- ===============================================
SELECT
    'VÉRIFICATION DES INDEX' as TYPE_VERIFICATION;

SELECT
    TABLE_NAME as 'Table',
    INDEX_NAME as 'Index',
    COLUMN_NAME as 'Colonne',
    NON_UNIQUE as 'Non_Unique'
FROM
    information_schema.STATISTICS
WHERE
    TABLE_SCHEMA = 'candidature_plus'
ORDER BY
    TABLE_NAME,
    INDEX_NAME;

-- 4. COMPTAGE DES DONNÉES PAR TABLE
-- ===============================================
SELECT
    'COMPTAGE DES DONNÉES' as TYPE_VERIFICATION;

SELECT
    'Candidat' as Table_Name,
    COUNT(*) as Nombre_Enregistrements
FROM
    Candidat
UNION ALL
SELECT
    'Utilisateur' as Table_Name,
    COUNT(*) as Nombre_Enregistrements
FROM
    Utilisateur
UNION ALL
SELECT
    'Centre' as Table_Name,
    COUNT(*) as Nombre_Enregistrements
FROM
    Centre
UNION ALL
SELECT
    'Concours' as Table_Name,
    COUNT(*) as Nombre_Enregistrements
FROM
    Concours
UNION ALL
SELECT
    'Specialite' as Table_Name,
    COUNT(*) as Nombre_Enregistrements
FROM
    Specialite
UNION ALL
SELECT
    'Candidature' as Table_Name,
    COUNT(*) as Nombre_Enregistrements
FROM
    Candidature
UNION ALL
SELECT
    'Document' as Table_Name,
    COUNT(*) as Nombre_Enregistrements
FROM
    Document
UNION ALL
SELECT
    'LogAction' as Table_Name,
    COUNT(*) as Nombre_Enregistrements
FROM
    LogAction
UNION ALL
SELECT
    'Notification' as Table_Name,
    COUNT(*) as Nombre_Enregistrements
FROM
    Notification
UNION ALL
SELECT
    'ConcoursSpecialite' as Table_Name,
    COUNT(*) as Nombre_Enregistrements
FROM
    ConcoursSpecialite
UNION ALL
SELECT
    'ConcoursCentre' as Table_Name,
    COUNT(*) as Nombre_Enregistrements
FROM
    ConcoursCentre
UNION ALL
SELECT
    'CentreSpecialite' as Table_Name,
    COUNT(*) as Nombre_Enregistrements
FROM
    CentreSpecialite;

-- 5. VÉRIFICATION DES DONNÉES CRITIQUES
-- ===============================================
SELECT
    'VÉRIFICATION DONNÉES CRITIQUES' as TYPE_VERIFICATION;

-- Utilisateurs administrateur
SELECT
    'Utilisateurs Administrateur' as Verification,
    COUNT(*) as Nombre
FROM
    Utilisateur
WHERE
    role = 'Administrateur'
    AND actif = true;

-- Concours actifs
SELECT
    'Concours Actifs' as Verification,
    COUNT(*) as Nombre
FROM
    Concours
WHERE
    actif = true;

-- Centres actifs
SELECT
    'Centres Actifs' as Verification,
    COUNT(*) as Nombre
FROM
    Centre
WHERE
    actif = true;

-- Spécialités actives
SELECT
    'Spécialités Actives' as Verification,
    COUNT(*) as Nombre
FROM
    Specialite
WHERE
    actif = true;

-- 6. VÉRIFICATION DES RELATIONS MANQUANTES
-- ===============================================
SELECT
    'VÉRIFICATION RELATIONS MANQUANTES' as TYPE_VERIFICATION;

-- Candidatures sans candidat
SELECT
    'Candidatures sans candidat' as Probleme,
    COUNT(*) as Nombre
FROM
    Candidature c
    LEFT JOIN Candidat cd ON c.candidat_id = cd.id
WHERE
    cd.id IS NULL;

-- Candidatures sans concours
SELECT
    'Candidatures sans concours' as Probleme,
    COUNT(*) as Nombre
FROM
    Candidature c
    LEFT JOIN Concours co ON c.concours_id = co.id
WHERE
    co.id IS NULL;

-- Candidatures sans centre
SELECT
    'Candidatures sans centre' as Probleme,
    COUNT(*) as Nombre
FROM
    Candidature c
    LEFT JOIN Centre ce ON c.centre_id = ce.id
WHERE
    ce.id IS NULL;

-- Candidatures sans spécialité
SELECT
    'Candidatures sans spécialité' as Probleme,
    COUNT(*) as Nombre
FROM
    Candidature c
    LEFT JOIN Specialite s ON c.specialite_id = s.id
WHERE
    s.id IS NULL;

-- Utilisateurs sans centre (pour gestionnaires locaux)
SELECT
    'Gestionnaires sans centre' as Probleme,
    COUNT(*) as Nombre
FROM
    Utilisateur u
WHERE
    u.role = 'GestionnaireLocal'
    AND u.centre_id IS NULL;

-- 7. VÉRIFICATION DES VALEURS NULL CRITIQUES
-- ===============================================
SELECT
    'VÉRIFICATION VALEURS NULL' as TYPE_VERIFICATION;

-- Candidats sans informations critiques
SELECT
    'Candidats sans email' as Probleme,
    COUNT(*) as Nombre
FROM
    Candidat
WHERE
    email IS NULL
    OR email = '';

SELECT
    'Candidats sans CIN' as Probleme,
    COUNT(*) as Nombre
FROM
    Candidat
WHERE
    cin IS NULL
    OR cin = '';

SELECT
    'Candidats sans nom' as Probleme,
    COUNT(*) as Nombre
FROM
    Candidat
WHERE
    nom IS NULL
    OR nom = '';

-- Utilisateurs sans informations critiques
SELECT
    'Utilisateurs sans email' as Probleme,
    COUNT(*) as Nombre
FROM
    Utilisateur
WHERE
    email IS NULL
    OR email = '';

SELECT
    'Utilisateurs sans mot de passe' as Probleme,
    COUNT(*) as Nombre
FROM
    Utilisateur
WHERE
    mot_de_passe IS NULL
    OR mot_de_passe = '';

-- 8. VÉRIFICATION DES DOUBLONS
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
            Candidat
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
            Candidat
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
            Utilisateur
        WHERE
            email IS NOT NULL
        GROUP BY
            email
        HAVING
            COUNT(*) > 1
    ) as doublons;

-- 9. VÉRIFICATION DES ASSOCIATIONS CONCOURS-SPÉCIALITÉS-CENTRES
-- ===============================================
SELECT
    'VÉRIFICATION ASSOCIATIONS' as TYPE_VERIFICATION;

-- Concours sans spécialités
SELECT
    'Concours sans spécialités' as Probleme,
    COUNT(*) as Nombre
FROM
    Concours c
    LEFT JOIN ConcoursSpecialite cs ON c.id = cs.concours_id
WHERE
    cs.concours_id IS NULL
    AND c.actif = true;

-- Concours sans centres
SELECT
    'Concours sans centres' as Probleme,
    COUNT(*) as Nombre
FROM
    Concours c
    LEFT JOIN ConcoursCentre cc ON c.id = cc.concours_id
WHERE
    cc.concours_id IS NULL
    AND c.actif = true;

-- Spécialités sans concours
SELECT
    'Spécialités orphelines' as Probleme,
    COUNT(*) as Nombre
FROM
    Specialite s
    LEFT JOIN ConcoursSpecialite cs ON s.id = cs.specialite_id
WHERE
    cs.specialite_id IS NULL
    AND s.actif = true;

-- Centres sans concours
SELECT
    'Centres orphelins' as Probleme,
    COUNT(*) as Nombre
FROM
    Centre c
    LEFT JOIN ConcoursCentre cc ON c.id = cc.centre_id
WHERE
    cc.centre_id IS NULL
    AND c.actif = true;

-- 10. RÉSUMÉ FINAL
-- ===============================================
SELECT
    'RÉSUMÉ DIAGNOSTIC' as TYPE_VERIFICATION;

SELECT
    'TOTAL TABLES' as Métrique,
    COUNT(*) as Valeur
FROM
    information_schema.TABLES
WHERE
    TABLE_SCHEMA = 'candidature_plus';

SELECT
    'TOTAL CANDIDATURES' as Métrique,
    COUNT(*) as Valeur
FROM
    Candidature;

SELECT
    'TOTAL CANDIDATS' as Métrique,
    COUNT(*) as Valeur
FROM
    Candidat;

SELECT
    'TOTAL UTILISATEURS ACTIFS' as Métrique,
    COUNT(*) as Valeur
FROM
    Utilisateur
WHERE
    actif = true;

SELECT
    'CONCOURS DISPONIBLES' as Métrique,
    COUNT(*) as Valeur
FROM
    Concours
WHERE
    actif = true
    AND date_debut_candidature <= CURDATE ()
    AND date_fin_candidature >= CURDATE ();