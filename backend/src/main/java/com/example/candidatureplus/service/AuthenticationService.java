package com.example.candidatureplus.service;

import com.example.candidatureplus.entity.Utilisateur;
import com.example.candidatureplus.entity.LogAction;
import com.example.candidatureplus.repository.UtilisateurRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.Optional;

@Service
public class AuthenticationService {

    @Autowired
    private UtilisateurRepository utilisateurRepository;

    @Autowired
    private LogActionService logActionService;

    /**
     * Authentifie un utilisateur avec email et mot de passe
     */
    public Optional<Utilisateur> authenticate(String email, String password) {
        System.out.println("=== AuthenticationService.authenticate ===");
        System.out.println("Email: " + email);
        System.out.println("Password: " + password);

        Optional<Utilisateur> utilisateurOpt = utilisateurRepository.findByEmail(email);
        System.out.println("Utilisateur trouvé: " + utilisateurOpt.isPresent());

        if (utilisateurOpt.isPresent()) {
            Utilisateur utilisateur = utilisateurOpt.get();
            System.out.println("Utilisateur actif: " + utilisateur.getActif());
            String motDePasse = utilisateur.getMotDePasse();
            if (motDePasse != null && motDePasse.length() > 20) {
                System.out.println("Hash en base: " + motDePasse.substring(0, 20) + "...");
            } else {
                System.out.println("Mot de passe en base: " + motDePasse);
            }

            // Vérifier si l'utilisateur est actif
            if (!utilisateur.getActif()) {
                System.out.println("Utilisateur inactif");
                return Optional.empty();
            }

            // Vérifier le mot de passe (comparaison directe sans cryptage)
            boolean passwordMatches = password.equals(utilisateur.getMotDePasse());
            System.out.println("Mot de passe correspond: " + passwordMatches);

            if (passwordMatches) {
                // Mettre à jour la dernière connexion
                utilisateur.setDerniereConnexion(LocalDateTime.now());
                utilisateurRepository.save(utilisateur);

                // Logger la connexion (avec gestion d'erreur)
                try {
                    logActionService.logAction(
                            LogAction.TypeActeur.Utilisateur,
                            utilisateur.getId(),
                            "CONNEXION",
                            "Utilisateur",
                            utilisateur.getId().longValue());
                } catch (Exception logException) {
                    // Ignorer les erreurs de log pour ne pas bloquer l'authentification
                    System.err.println("Erreur de log ignorée: " + logException.getMessage());
                }

                System.out.println("Authentification réussie");
                return Optional.of(utilisateur);
            } else {
                System.out.println("Mot de passe incorrect");
            }
        } else {
            System.out.println("Utilisateur non trouvé");
        }

        // Logger la tentative de connexion échouée (avec gestion d'erreur)
        try {
            logActionService.logAction(
                    LogAction.TypeActeur.Systeme,
                    null,
                    "TENTATIVE_CONNEXION_ECHEC",
                    "Utilisateur",
                    null,
                    "Email: " + email);
        } catch (Exception logException) {
            // Ignorer les erreurs de log
            System.err.println("Erreur de log ignorée: " + logException.getMessage());
        }

        System.out.println("Authentification échouée");
        return Optional.empty();
    }

    /**
     * Vérifie si un utilisateur a un rôle spécifique
     */
    public boolean hasRole(Utilisateur utilisateur, Utilisateur.Role role) {
        return utilisateur.getRole() == role;
    }

    /**
     * Vérifie si un utilisateur peut accéder à un centre spécifique
     */
    public boolean canAccessCentre(Utilisateur utilisateur, Integer centreId) {
        // Les administrateurs et gestionnaires globaux peuvent accéder à tous les
        // centres
        if (utilisateur.getRole() == Utilisateur.Role.Administrateur ||
                utilisateur.getRole() == Utilisateur.Role.GestionnaireGlobal) {
            return true;
        }

        // Les gestionnaires locaux ne peuvent accéder qu'à leur centre
        if (utilisateur.getRole() == Utilisateur.Role.GestionnaireLocal) {
            return utilisateur.getCentre() != null &&
                    utilisateur.getCentre().getId().equals(centreId);
        }

        return false;
    }

    /**
     * Change le mot de passe d'un utilisateur
     */
    public void changePassword(Integer utilisateurId, String oldPassword, String newPassword) {
        Utilisateur utilisateur = utilisateurRepository.findById(utilisateurId)
                .orElseThrow(() -> new RuntimeException("Utilisateur non trouvé"));

        // Vérifier l'ancien mot de passe (comparaison directe)
        if (!oldPassword.equals(utilisateur.getMotDePasse())) {
            throw new RuntimeException("Ancien mot de passe incorrect");
        }

        // Sauvegarder le nouveau mot de passe en texte clair
        utilisateur.setMotDePasse(newPassword);
        utilisateurRepository.save(utilisateur);

        // Logger l'action (avec gestion d'erreur)
        try {
            logActionService.logAction(
                    LogAction.TypeActeur.Utilisateur,
                    utilisateurId,
                    "CHANGEMENT_MOT_DE_PASSE",
                    "Utilisateur",
                    utilisateurId.longValue());
        } catch (Exception logException) {
            // Ignorer les erreurs de log
            System.err.println("Erreur de log ignorée: " + logException.getMessage());
        }
    }

    /**
     * Désactive un utilisateur
     */
    public void deactivateUser(Integer utilisateurId, Integer adminId) {
        Utilisateur utilisateur = utilisateurRepository.findById(utilisateurId)
                .orElseThrow(() -> new RuntimeException("Utilisateur non trouvé"));

        utilisateur.setActif(false);
        utilisateurRepository.save(utilisateur);

        // Logger l'action (avec gestion d'erreur)
        try {
            logActionService.logAction(
                    LogAction.TypeActeur.Utilisateur,
                    adminId,
                    "DESACTIVATION_UTILISATEUR",
                    "Utilisateur",
                    utilisateurId.longValue());
        } catch (Exception logException) {
            // Ignorer les erreurs de log
            System.err.println("Erreur de log ignorée: " + logException.getMessage());
        }
    }
}
