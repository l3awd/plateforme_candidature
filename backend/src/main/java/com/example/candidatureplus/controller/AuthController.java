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
import com.example.candidatureplus.dto.ApiResponse; // added

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
    public ResponseEntity<ApiResponse<LoginResponse>> login(@RequestBody LoginRequest loginRequest,
            HttpSession session) {
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

                return ResponseEntity.ok(ApiResponse.ok(LoginResponse.success(utilisateur)));
            } else {
                return ResponseEntity.badRequest().body(ApiResponse.error("Email ou mot de passe incorrect"));
            }
        } catch (Exception e) {
            System.err.println("ERREUR DANS LOGIN: " + e.getMessage());
            e.printStackTrace();
            return ResponseEntity.internalServerError()
                    .body(ApiResponse.error("Erreur lors de l'authentification: " + e.getMessage()));
        }
    }

    /**
     * Endpoint de déconnexion
     */
    @PostMapping("/logout")
    public ResponseEntity<ApiResponse<String>> logout(HttpSession session) {
        session.invalidate();
        return ResponseEntity.ok(ApiResponse.ok("Déconnexion réussie", "Déconnexion réussie"));
    }

    /**
     * Endpoint pour vérifier si l'utilisateur est connecté
     */
    @GetMapping("/current")
    public ResponseEntity<ApiResponse<LoginResponse>> getCurrentUser(HttpSession session) {
        Utilisateur utilisateur = (Utilisateur) session.getAttribute("utilisateur");

        if (utilisateur != null) {
            return ResponseEntity.ok(ApiResponse.ok(LoginResponse.success(utilisateur)));
        } else {
            return ResponseEntity.status(401).body(ApiResponse.error("Non authentifié"));
        }
    }

    /**
     * Endpoint de debug pour tester l'authentification
     */
    @PostMapping("/debug")
    public ResponseEntity<ApiResponse<String>> debugAuth(@RequestBody LoginRequest loginRequest) {
        try {
            System.out.println("=== DEBUG AUTH ===");
            System.out.println("Email reçu: " + loginRequest.getEmail());
            System.out.println("Password reçu: " + loginRequest.getPassword());

            Optional<Utilisateur> result = authenticationService.authenticate(
                    loginRequest.getEmail(),
                    loginRequest.getPassword());

            if (result.isPresent()) {
                return ResponseEntity.ok(ApiResponse.ok("Authentification réussie",
                        "Authentification réussie pour: " + result.get().getEmail()));
            } else {
                return ResponseEntity.badRequest().body(ApiResponse.error("Authentification échouée"));
            }
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.internalServerError().body(ApiResponse.error("Erreur: " + e.getMessage()));
        }
    }

    /**
     * Endpoint pour changer le mot de passe
     */
    @PostMapping("/change-password")
    public ResponseEntity<ApiResponse<String>> changePassword(
            @RequestParam String oldPassword,
            @RequestParam String newPassword,
            HttpSession session) {

        Integer userId = (Integer) session.getAttribute("userId");
        if (userId == null) {
            return ResponseEntity.status(401).body(ApiResponse.error("Non authentifié"));
        }

        try {
            authenticationService.changePassword(userId, oldPassword, newPassword);
            return ResponseEntity.ok(ApiResponse.ok("Mot de passe modifié", "Mot de passe modifié avec succès"));
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }
}
