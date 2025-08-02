package com.example.candidatureplus.controller;

import com.example.candidatureplus.dto.LoginRequest;
import com.example.candidatureplus.dto.LoginResponse;
import com.example.candidatureplus.entity.Utilisateur;
import com.example.candidatureplus.service.AuthenticationService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import jakarta.servlet.http.HttpSession;
import java.util.Optional;

@RestController
@RequestMapping("/api/auth")
@CrossOrigin(origins = "http://localhost:3000")
public class AuthController {

    @Autowired
    private AuthenticationService authenticationService;

    /**
     * Endpoint de connexion
     */
    @PostMapping("/login")
    public ResponseEntity<LoginResponse> login(@RequestBody LoginRequest loginRequest, HttpSession session) {
        try {
            Optional<Utilisateur> utilisateurOpt = authenticationService.authenticate(
                    loginRequest.getEmail(),
                    loginRequest.getPassword());

            if (utilisateurOpt.isPresent()) {
                Utilisateur utilisateur = utilisateurOpt.get();

                // Stocker l'utilisateur en session
                session.setAttribute("utilisateur", utilisateur);
                session.setAttribute("userId", utilisateur.getId());
                session.setAttribute("userRole", utilisateur.getRole());

                return ResponseEntity.ok(LoginResponse.success(utilisateur));
            } else {
                return ResponseEntity.badRequest()
                        .body(LoginResponse.failure("Email ou mot de passe incorrect"));
            }
        } catch (Exception e) {
            return ResponseEntity.internalServerError()
                    .body(LoginResponse.failure("Erreur lors de l'authentification"));
        }
    }

    /**
     * Endpoint de déconnexion
     */
    @PostMapping("/logout")
    public ResponseEntity<String> logout(HttpSession session) {
        session.invalidate();
        return ResponseEntity.ok("Déconnexion réussie");
    }

    /**
     * Endpoint pour vérifier si l'utilisateur est connecté
     */
    @GetMapping("/current")
    public ResponseEntity<LoginResponse> getCurrentUser(HttpSession session) {
        Utilisateur utilisateur = (Utilisateur) session.getAttribute("utilisateur");

        if (utilisateur != null) {
            return ResponseEntity.ok(LoginResponse.success(utilisateur));
        } else {
            return ResponseEntity.status(401)
                    .body(LoginResponse.failure("Non authentifié"));
        }
    }

    /**
     * Endpoint pour changer le mot de passe
     */
    @PostMapping("/change-password")
    public ResponseEntity<String> changePassword(
            @RequestParam String oldPassword,
            @RequestParam String newPassword,
            HttpSession session) {

        Integer userId = (Integer) session.getAttribute("userId");
        if (userId == null) {
            return ResponseEntity.status(401).body("Non authentifié");
        }

        try {
            authenticationService.changePassword(userId, oldPassword, newPassword);
            return ResponseEntity.ok("Mot de passe modifié avec succès");
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(e.getMessage());
        }
    }
}
