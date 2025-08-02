-- =========================================
-- Script de nettoyage des données de test
-- =========================================
USE candidature_plus;

-- Désactiver les contraintes de clés étrangères temporairement
SET
    FOREIGN_KEY_CHECKS = 0;

-- Nettoyer les données de test dans l'ordre inverse des dépendances
TRUNCATE TABLE Log_Action;

TRUNCATE TABLE Notification;

TRUNCATE TABLE Candidature;

TRUNCATE TABLE Centre_Specialite;

TRUNCATE TABLE Concours_Specialite;

TRUNCATE TABLE Candidat;

TRUNCATE TABLE Utilisateur;

TRUNCATE TABLE Concours;

TRUNCATE TABLE Specialite;

TRUNCATE TABLE Centre;

TRUNCATE TABLE Statistique;

-- Réactiver les contraintes de clés étrangères
SET
    FOREIGN_KEY_CHECKS = 1;

SELECT
    'Base de données nettoyée avec succès!' AS Status;