package com.example.candidatureplus.service;

import com.example.candidatureplus.entity.Utilisateur;
import com.example.candidatureplus.entity.LogAction;
import com.example.candidatureplus.repository.UtilisateurRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.Optional;

@Service
public class AuthenticationService {

    @Autowired
    private UtilisateurRepository utilisateurRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @Autowired
    private LogActionService logActionService;

    /**
     * Authentifie un utilisateur avec email et mot de passe
     */
    public Optional<Utilisateur> authenticate(String email, String password) {
        Optional<Utilisateur> utilisateurOpt = utilisateurRepository.findByEmail(email);

        if (utilisateurOpt.isPresent()) {
            Utilisateur utilisateur = utilisateurOpt.get();

            // Vérifier si l'utilisateur est actif
            if (!utilisateur.getActif()) {
                return Optional.empty();
            }

            // Vérifier le mot de passe
            if (passwordEncoder.matches(password, utilisateur.getMotDePasse())) {
                // Mettre à jour la dernière connexion
                utilisateur.setDerniereConnexion(LocalDateTime.now());
                utilisateurRepository.save(utilisateur);

                // Logger la connexion
                logActionService.logAction(
                        LogAction.TypeActeur.Utilisateur,
                        utilisateur.getId(),
                        "CONNEXION",
                        "Utilisateur",
                        utilisateur.getId().longValue());

                return Optional.of(utilisateur);
            }
        }

        // Logger la tentative de connexion échouée
        logActionService.logAction(
                LogAction.TypeActeur.Systeme,
                null,
                "TENTATIVE_CONNEXION_ECHEC",
                "Utilisateur",
                null,
                "Email: " + email);

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

        // Vérifier l'ancien mot de passe
        if (!passwordEncoder.matches(oldPassword, utilisateur.getMotDePasse())) {
            throw new RuntimeException("Ancien mot de passe incorrect");
        }

        // Encoder et sauvegarder le nouveau mot de passe
        utilisateur.setMotDePasse(passwordEncoder.encode(newPassword));
        utilisateurRepository.save(utilisateur);

        // Logger l'action
        logActionService.logAction(
                LogAction.TypeActeur.Utilisateur,
                utilisateurId,
                "CHANGEMENT_MOT_DE_PASSE",
                "Utilisateur",
                utilisateurId.longValue());
    }

    /**
     * Désactive un utilisateur
     */
    public void deactivateUser(Integer utilisateurId, Integer adminId) {
        Utilisateur utilisateur = utilisateurRepository.findById(utilisateurId)
                .orElseThrow(() -> new RuntimeException("Utilisateur non trouvé"));

        utilisateur.setActif(false);
        utilisateurRepository.save(utilisateur);

        // Logger l'action
        logActionService.logAction(
                LogAction.TypeActeur.Utilisateur,
                adminId,
                "DESACTIVATION_UTILISATEUR",
                "Utilisateur",
                utilisateurId.longValue());
    }
}
