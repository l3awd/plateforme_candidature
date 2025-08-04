package com.example.candidatureplus.controller;

import com.example.candidatureplus.entity.Utilisateur;
import com.example.candidatureplus.entity.Centre;
import com.example.candidatureplus.repository.UtilisateurRepository;
import com.example.candidatureplus.repository.CentreRepository;
import com.example.candidatureplus.service.AuthenticationService;
import com.example.candidatureplus.service.LogActionService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import jakarta.servlet.http.HttpSession;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;
import java.util.HashMap;
import java.util.Optional;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/utilisateurs")
@CrossOrigin(origins = "http://localhost:3000")
public class UtilisateurController {

    @Autowired
    private UtilisateurRepository utilisateurRepository;

    @Autowired
    private CentreRepository centreRepository;

    @Autowired
    private AuthenticationService authenticationService;

    @Autowired
    private LogActionService logActionService;

    /**
     * Récupérer tous les utilisateurs
     */
    @GetMapping
    public ResponseEntity<List<Map<String, Object>>> getAllUtilisateurs(HttpSession session) {
        try {
            // Vérifier que l'utilisateur est authentifié et est admin
            Integer userId = (Integer) session.getAttribute("userId");
            if (userId == null) {
                return ResponseEntity.status(401).build();
            }

            List<Utilisateur> utilisateurs = utilisateurRepository.findAll();

            List<Map<String, Object>> utilisateursSimples = utilisateurs.stream()
                    .map(this::convertToMapSimple)
                    .collect(Collectors.toList());

            return ResponseEntity.ok(utilisateursSimples);
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.badRequest().build();
        }
    }

    /**
     * Récupérer un utilisateur par ID
     */
    @GetMapping("/{id}")
    public ResponseEntity<Map<String, Object>> getUtilisateurById(@PathVariable Integer id, HttpSession session) {
        try {
            Integer userId = (Integer) session.getAttribute("userId");
            if (userId == null) {
                return ResponseEntity.status(401).build();
            }

            Utilisateur utilisateur = utilisateurRepository.findById(id)
                    .orElseThrow(() -> new RuntimeException("Utilisateur non trouvé"));

            return ResponseEntity.ok(convertToMapDetailed(utilisateur));
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.badRequest().build();
        }
    }

    /**
     * Créer un nouvel utilisateur
     */
    @PostMapping
    public ResponseEntity<Map<String, Object>> createUtilisateur(@RequestBody Map<String, Object> userData,
            HttpSession session) {
        try {
            Integer adminId = (Integer) session.getAttribute("userId");
            if (adminId == null) {
                return ResponseEntity.status(401).build();
            }

            // Vérifier que l'email n'existe pas déjà
            String email = (String) userData.get("email");
            if (utilisateurRepository.existsByEmail(email)) {
                Map<String, Object> error = new HashMap<>();
                error.put("error", "Un utilisateur avec cet email existe déjà");
                return ResponseEntity.badRequest().body(error);
            }

            Utilisateur utilisateur = new Utilisateur();
            utilisateur.setNom((String) userData.get("nom"));
            utilisateur.setPrenom((String) userData.get("prenom"));
            utilisateur.setEmail(email);
            utilisateur.setMotDePasse((String) userData.get("motDePasse")); // Note: devrait être hashé en production

            // Conversion du rôle
            String roleStr = (String) userData.get("role");
            if (roleStr != null) {
                utilisateur.setRole(Utilisateur.Role.valueOf(roleStr));
            }

            // Assignation du centre si fourni
            if (userData.get("centreId") != null) {
                Integer centreId = Integer.valueOf(userData.get("centreId").toString());
                Centre centre = centreRepository.findById(centreId)
                        .orElseThrow(() -> new RuntimeException("Centre non trouvé"));
                utilisateur.setCentre(centre);
            }

            Boolean actif = (Boolean) userData.get("actif");
            utilisateur.setActif(actif != null ? actif : true);

            utilisateur.setDateCreation(LocalDateTime.now());

            Utilisateur saved = utilisateurRepository.save(utilisateur);

            // Logger l'action
            logActionService.logAction(
                    com.example.candidatureplus.entity.LogAction.TypeActeur.Utilisateur,
                    adminId,
                    "CREATION_UTILISATEUR",
                    "Utilisateur",
                    saved.getId().longValue());

            return ResponseEntity.ok(convertToMapDetailed(saved));
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.badRequest().build();
        }
    }

    /**
     * Mettre à jour un utilisateur
     */
    @PutMapping("/{id}")
    public ResponseEntity<Map<String, Object>> updateUtilisateur(@PathVariable Integer id,
            @RequestBody Map<String, Object> userData,
            HttpSession session) {
        try {
            Integer adminId = (Integer) session.getAttribute("userId");
            if (adminId == null) {
                return ResponseEntity.status(401).build();
            }

            Utilisateur utilisateur = utilisateurRepository.findById(id)
                    .orElseThrow(() -> new RuntimeException("Utilisateur non trouvé"));

            if (userData.get("nom") != null) {
                utilisateur.setNom((String) userData.get("nom"));
            }
            if (userData.get("prenom") != null) {
                utilisateur.setPrenom((String) userData.get("prenom"));
            }
            if (userData.get("email") != null) {
                String newEmail = (String) userData.get("email");
                // Vérifier que le nouvel email n'est pas déjà utilisé par un autre utilisateur
                Optional<Utilisateur> existingUser = utilisateurRepository.findByEmail(newEmail);
                if (existingUser.isPresent() && !existingUser.get().getId().equals(id)) {
                    Map<String, Object> error = new HashMap<>();
                    error.put("error", "Un autre utilisateur utilise déjà cet email");
                    return ResponseEntity.badRequest().body(error);
                }
                utilisateur.setEmail(newEmail);
            }
            if (userData.get("role") != null) {
                String roleStr = (String) userData.get("role");
                utilisateur.setRole(Utilisateur.Role.valueOf(roleStr));
            }
            if (userData.get("centreId") != null) {
                Integer centreId = Integer.valueOf(userData.get("centreId").toString());
                Centre centre = centreRepository.findById(centreId)
                        .orElseThrow(() -> new RuntimeException("Centre non trouvé"));
                utilisateur.setCentre(centre);
            }
            if (userData.get("actif") != null) {
                utilisateur.setActif((Boolean) userData.get("actif"));
            }

            Utilisateur updated = utilisateurRepository.save(utilisateur);

            // Logger l'action
            logActionService.logAction(
                    com.example.candidatureplus.entity.LogAction.TypeActeur.Utilisateur,
                    adminId,
                    "MODIFICATION_UTILISATEUR",
                    "Utilisateur",
                    updated.getId().longValue());

            return ResponseEntity.ok(convertToMapDetailed(updated));
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.badRequest().build();
        }
    }

    /**
     * Désactiver un utilisateur
     */
    @DeleteMapping("/{id}")
    public ResponseEntity<Map<String, String>> deactivateUtilisateur(@PathVariable Integer id, HttpSession session) {
        try {
            Integer adminId = (Integer) session.getAttribute("userId");
            if (adminId == null) {
                return ResponseEntity.status(401).build();
            }

            authenticationService.deactivateUser(id, adminId);

            Map<String, String> response = new HashMap<>();
            response.put("message", "Utilisateur désactivé avec succès");
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            e.printStackTrace();
            Map<String, String> error = new HashMap<>();
            error.put("error", "Erreur lors de la désactivation: " + e.getMessage());
            return ResponseEntity.badRequest().body(error);
        }
    }

    /**
     * Changer le mot de passe d'un utilisateur
     */
    @PostMapping("/{id}/change-password")
    public ResponseEntity<Map<String, String>> changePassword(@PathVariable Integer id,
            @RequestBody Map<String, String> passwordData,
            HttpSession session) {
        try {
            Integer userId = (Integer) session.getAttribute("userId");
            if (userId == null) {
                return ResponseEntity.status(401).build();
            }

            // Un utilisateur ne peut changer que son propre mot de passe, ou un admin peut
            // changer celui des autres
            Utilisateur currentUser = utilisateurRepository.findById(userId).orElse(null);
            if (currentUser == null) {
                return ResponseEntity.status(401).build();
            }

            boolean isAdmin = currentUser.getRole() == Utilisateur.Role.Administrateur;
            boolean isSelf = userId.equals(id);

            if (!isAdmin && !isSelf) {
                Map<String, String> error = new HashMap<>();
                error.put("error", "Vous n'avez pas l'autorisation de changer ce mot de passe");
                return ResponseEntity.status(403).body(error);
            }

            String oldPassword = passwordData.get("oldPassword");
            String newPassword = passwordData.get("newPassword");

            if (isSelf && oldPassword == null) {
                Map<String, String> error = new HashMap<>();
                error.put("error", "L'ancien mot de passe est requis");
                return ResponseEntity.badRequest().body(error);
            }

            authenticationService.changePassword(id, oldPassword, newPassword);

            Map<String, String> response = new HashMap<>();
            response.put("message", "Mot de passe changé avec succès");
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            e.printStackTrace();
            Map<String, String> error = new HashMap<>();
            error.put("error", "Erreur lors du changement de mot de passe: " + e.getMessage());
            return ResponseEntity.badRequest().body(error);
        }
    }

    /**
     * Récupérer les utilisateurs par rôle
     */
    @GetMapping("/role/{role}")
    public ResponseEntity<List<Map<String, Object>>> getUtilisateursByRole(@PathVariable String role,
            HttpSession session) {
        try {
            Integer userId = (Integer) session.getAttribute("userId");
            if (userId == null) {
                return ResponseEntity.status(401).build();
            }

            Utilisateur.Role userRole = Utilisateur.Role.valueOf(role);
            List<Utilisateur> utilisateurs = utilisateurRepository.findAll().stream()
                    .filter(u -> u.getRole() == userRole && u.getActif())
                    .collect(Collectors.toList());

            List<Map<String, Object>> result = utilisateurs.stream()
                    .map(this::convertToMapSimple)
                    .collect(Collectors.toList());

            return ResponseEntity.ok(result);
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.badRequest().build();
        }
    }

    /**
     * Réactiver un utilisateur
     */
    @PostMapping("/{id}/reactivate")
    public ResponseEntity<Map<String, String>> reactivateUtilisateur(@PathVariable Integer id, HttpSession session) {
        try {
            Integer adminId = (Integer) session.getAttribute("userId");
            if (adminId == null) {
                return ResponseEntity.status(401).build();
            }

            Utilisateur utilisateur = utilisateurRepository.findById(id)
                    .orElseThrow(() -> new RuntimeException("Utilisateur non trouvé"));

            utilisateur.setActif(true);
            utilisateurRepository.save(utilisateur);

            // Logger l'action
            logActionService.logAction(
                    com.example.candidatureplus.entity.LogAction.TypeActeur.Utilisateur,
                    adminId,
                    "REACTIVATION_UTILISATEUR",
                    "Utilisateur",
                    id.longValue());

            Map<String, String> response = new HashMap<>();
            response.put("message", "Utilisateur réactivé avec succès");
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            e.printStackTrace();
            Map<String, String> error = new HashMap<>();
            error.put("error", "Erreur lors de la réactivation: " + e.getMessage());
            return ResponseEntity.badRequest().body(error);
        }
    }

    /**
     * Statistiques des utilisateurs
     */
    @GetMapping("/statistiques")
    public ResponseEntity<Map<String, Object>> getStatistiques(HttpSession session) {
        try {
            Integer userId = (Integer) session.getAttribute("userId");
            if (userId == null) {
                return ResponseEntity.status(401).build();
            }

            Map<String, Object> stats = new HashMap<>();

            long totalUtilisateurs = utilisateurRepository.count();
            long utilisateursActifs = utilisateurRepository.findAll().stream()
                    .filter(Utilisateur::getActif)
                    .count();
            long gestionnairesLocaux = utilisateurRepository.findAll().stream()
                    .filter(u -> u.getRole() == Utilisateur.Role.GestionnaireLocal && u.getActif())
                    .count();
            long gestionnairesGlobaux = utilisateurRepository.findAll().stream()
                    .filter(u -> u.getRole() == Utilisateur.Role.GestionnaireGlobal && u.getActif())
                    .count();
            long administrateurs = utilisateurRepository.findAll().stream()
                    .filter(u -> u.getRole() == Utilisateur.Role.Administrateur && u.getActif())
                    .count();

            stats.put("total", totalUtilisateurs);
            stats.put("actifs", utilisateursActifs);
            stats.put("inactifs", totalUtilisateurs - utilisateursActifs);
            stats.put("gestionnairesLocaux", gestionnairesLocaux);
            stats.put("gestionnairesGlobaux", gestionnairesGlobaux);
            stats.put("administrateurs", administrateurs);

            return ResponseEntity.ok(stats);
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.badRequest().build();
        }
    }

    // Méthodes utilitaires de conversion

    private Map<String, Object> convertToMapSimple(Utilisateur utilisateur) {
        Map<String, Object> map = new HashMap<>();
        map.put("id", utilisateur.getId());
        map.put("nom", utilisateur.getNom());
        map.put("prenom", utilisateur.getPrenom());
        map.put("email", utilisateur.getEmail());
        map.put("role", utilisateur.getRole());
        map.put("actif", utilisateur.getActif());
        map.put("dateCreation", utilisateur.getDateCreation());
        map.put("derniereConnexion", utilisateur.getDerniereConnexion());

        if (utilisateur.getCentre() != null) {
            Map<String, Object> centreMap = new HashMap<>();
            centreMap.put("id", utilisateur.getCentre().getId());
            centreMap.put("nom", utilisateur.getCentre().getNom());
            centreMap.put("ville", utilisateur.getCentre().getVille());
            map.put("centre", centreMap);
        }

        return map;
    }

    private Map<String, Object> convertToMapDetailed(Utilisateur utilisateur) {
        Map<String, Object> map = convertToMapSimple(utilisateur);
        map.put("centresAssignes", utilisateur.getCentresAssignes());
        return map;
    }
}
