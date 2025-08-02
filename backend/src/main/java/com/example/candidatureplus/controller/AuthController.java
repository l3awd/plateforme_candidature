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
        System.out.println("=== LOGIN REQUEST ===");
        System.out.println("Email reçu: " + loginRequest.getEmail());
        System.out.println("Password reçu: " + loginRequest.getPassword());

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
            System.err.println("ERREUR DANS LOGIN: " + e.getMessage());
            e.printStackTrace();
            return ResponseEntity.internalServerError()
                    .body(LoginResponse.failure("Erreur lors de l'authentification: " + e.getMessage()));
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
     * Endpoint de debug pour tester l'authentification
     */
    @PostMapping("/debug")
    public ResponseEntity<String> debugAuth(@RequestBody LoginRequest loginRequest) {
        try {
            System.out.println("=== DEBUG AUTH ===");
            System.out.println("Email reçu: " + loginRequest.getEmail());
            System.out.println("Password reçu: " + loginRequest.getPassword());

            Optional<Utilisateur> result = authenticationService.authenticate(
                    loginRequest.getEmail(),
                    loginRequest.getPassword());

            if (result.isPresent()) {
                return ResponseEntity.ok("Authentification réussie pour: " + result.get().getEmail());
            } else {
                return ResponseEntity.badRequest().body("Authentification échouée");
            }
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.internalServerError().body("Erreur: " + e.getMessage());
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
