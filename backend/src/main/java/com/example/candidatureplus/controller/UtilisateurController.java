package com.example.candidatureplus.controller;

import com.example.candidatureplus.entity.Utilisateur;
import com.example.candidatureplus.entity.Centre;
import com.example.candidatureplus.repository.UtilisateurRepository;
import com.example.candidatureplus.repository.CentreRepository;
import com.example.candidatureplus.service.LogActionService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import jakarta.servlet.http.HttpSession;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;
import java.util.HashMap;
import java.util.stream.Collectors;
import com.example.candidatureplus.dto.ApiResponse;

@RestController
@RequestMapping("/api/utilisateurs")
@CrossOrigin(origins = "http://localhost:3000")
public class UtilisateurController {

    @Autowired
    private UtilisateurRepository utilisateurRepository;

    @Autowired
    private CentreRepository centreRepository;

    @Autowired
    private LogActionService logActionService;

    /**
     * Récupérer tous les utilisateurs
     */
    @GetMapping
    public ResponseEntity<ApiResponse<List<Map<String, Object>>>> getAllUtilisateurs(HttpSession session) {
        try {
            Integer userId = (Integer) session.getAttribute("userId");
            if (userId == null) {
                return ResponseEntity.status(401).body(ApiResponse.error("Non authentifié"));
            }
            List<Utilisateur> utilisateurs = utilisateurRepository.findAll();
            List<Map<String, Object>> utilisateursSimples = utilisateurs.stream()
                    .map(this::convertToMapSimple)
                    .collect(Collectors.toList());
            return ResponseEntity.ok(ApiResponse.ok(utilisateursSimples));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }

    /**
     * Récupérer un utilisateur par ID
     */
    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse<Map<String, Object>>> getUtilisateurById(@PathVariable Integer id,
            HttpSession session) {
        try {
            Integer userId = (Integer) session.getAttribute("userId");
            if (userId == null) {
                return ResponseEntity.status(401).body(ApiResponse.error("Non authentifié"));
            }
            Utilisateur utilisateur = utilisateurRepository.findById(id)
                    .orElseThrow(() -> new RuntimeException("Utilisateur non trouvé"));
            return ResponseEntity.ok(ApiResponse.ok(convertToMapDetailed(utilisateur)));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }

    /**
     * Créer un nouvel utilisateur
     */
    @PostMapping
    public ResponseEntity<ApiResponse<Map<String, Object>>> createUtilisateur(@RequestBody Map<String, Object> userData,
            HttpSession session) {
        try {
            Integer adminId = (Integer) session.getAttribute("userId");
            if (adminId == null) {
                return ResponseEntity.status(401).body(ApiResponse.error("Non authentifié"));
            }
            String email = (String) userData.get("email");
            if (utilisateurRepository.existsByEmail(email)) {
                return ResponseEntity.badRequest().body(ApiResponse.error("Un utilisateur avec cet email existe déjà"));
            }
            Utilisateur utilisateur = new Utilisateur();
            utilisateur.setNom((String) userData.get("nom"));
            utilisateur.setPrenom((String) userData.get("prenom"));
            utilisateur.setEmail(email);
            utilisateur.setMotDePasse((String) userData.get("motDePasse"));
            String roleStr = (String) userData.get("role");
            if (roleStr != null) {
                utilisateur.setRole(Utilisateur.Role.valueOf(roleStr));
            }
            if (userData.get("centreId") != null) {
                Integer centreId = Integer.valueOf(userData.get("centreId").toString());
                Centre centre = centreRepository.findById(centreId)
                        .orElseThrow(() -> new RuntimeException("Centre non trouvé"));
                utilisateur.setCentre(centre);
            }
            utilisateur.setActif(true);
            utilisateur.setDateCreation(LocalDateTime.now());
            utilisateurRepository.save(utilisateur);
            Map<String, Object> response = convertToMapDetailed(utilisateur);
            return ResponseEntity.ok(ApiResponse.ok("Utilisateur créé", response));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }

    /**
     * Mettre à jour un utilisateur
     */
    @PutMapping("/{id}")
    public ResponseEntity<ApiResponse<Map<String, Object>>> updateUtilisateur(@PathVariable Integer id,
            @RequestBody Map<String, Object> userData, HttpSession session) {
        try {
            Integer adminId = (Integer) session.getAttribute("userId");
            if (adminId == null) {
                return ResponseEntity.status(401).body(ApiResponse.error("Non authentifié"));
            }
            Utilisateur utilisateur = utilisateurRepository.findById(id)
                    .orElseThrow(() -> new RuntimeException("Utilisateur non trouvé"));
            if (userData.get("nom") != null)
                utilisateur.setNom((String) userData.get("nom"));
            if (userData.get("prenom") != null)
                utilisateur.setPrenom((String) userData.get("prenom"));
            if (userData.get("email") != null)
                utilisateur.setEmail((String) userData.get("email"));
            if (userData.get("motDePasse") != null)
                utilisateur.setMotDePasse((String) userData.get("motDePasse"));
            if (userData.get("role") != null)
                utilisateur.setRole(Utilisateur.Role.valueOf(userData.get("role").toString()));
            if (userData.get("centreId") != null) {
                Integer centreId = Integer.valueOf(userData.get("centreId").toString());
                Centre centre = centreRepository.findById(centreId)
                        .orElseThrow(() -> new RuntimeException("Centre non trouvé"));
                utilisateur.setCentre(centre);
            }
            utilisateurRepository.save(utilisateur);
            return ResponseEntity.ok(ApiResponse.ok("Utilisateur mis à jour", convertToMapDetailed(utilisateur)));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }

    /**
     * Désactiver un utilisateur
     */
    @PostMapping("/{id}/deactivate")
    public ResponseEntity<ApiResponse<Map<String, Object>>> deactivateUtilisateur(@PathVariable Integer id,
            HttpSession session) {
        try {
            Integer adminId = (Integer) session.getAttribute("userId");
            if (adminId == null) {
                return ResponseEntity.status(401).body(ApiResponse.error("Non authentifié"));
            }
            Utilisateur utilisateur = utilisateurRepository.findById(id)
                    .orElseThrow(() -> new RuntimeException("Utilisateur non trouvé"));
            utilisateur.setActif(false);
            utilisateurRepository.save(utilisateur);
            logActionService.logAction(
                    com.example.candidatureplus.entity.LogAction.TypeActeur.Utilisateur,
                    adminId,
                    "DESACTIVATION_UTILISATEUR",
                    "Utilisateur",
                    id.longValue());
            return ResponseEntity.ok(ApiResponse.ok("Utilisateur désactivé", convertToMapDetailed(utilisateur)));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }

    /**
     * Réactiver un utilisateur
     */
    @PostMapping("/{id}/reactivate")
    public ResponseEntity<ApiResponse<Map<String, Object>>> reactivateUtilisateur(@PathVariable Integer id,
            HttpSession session) {
        try {
            Integer adminId = (Integer) session.getAttribute("userId");
            if (adminId == null) {
                return ResponseEntity.status(401).body(ApiResponse.error("Non authentifié"));
            }
            Utilisateur utilisateur = utilisateurRepository.findById(id)
                    .orElseThrow(() -> new RuntimeException("Utilisateur non trouvé"));
            utilisateur.setActif(true);
            utilisateurRepository.save(utilisateur);
            logActionService.logAction(
                    com.example.candidatureplus.entity.LogAction.TypeActeur.Utilisateur,
                    adminId,
                    "REACTIVATION_UTILISATEUR",
                    "Utilisateur",
                    id.longValue());
            return ResponseEntity.ok(ApiResponse.ok("Utilisateur réactivé", convertToMapDetailed(utilisateur)));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }

    /**
     * Statistiques des utilisateurs
     */
    @GetMapping("/statistiques")
    public ResponseEntity<ApiResponse<Map<String, Object>>> getStatistiques(HttpSession session) {
        try {
            Integer userId = (Integer) session.getAttribute("userId");
            if (userId == null) {
                return ResponseEntity.status(401).body(ApiResponse.error("Non authentifié"));
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
            return ResponseEntity.ok(ApiResponse.ok(stats));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
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
        return map;
    }

    private Map<String, Object> convertToMapDetailed(Utilisateur utilisateur) {
        Map<String, Object> map = convertToMapSimple(utilisateur);
        if (utilisateur.getCentre() != null) {
            map.put("centre", Map.of(
                    "id", utilisateur.getCentre().getId(),
                    "nom", utilisateur.getCentre().getNom()));
        }
        return map;
    }
}
