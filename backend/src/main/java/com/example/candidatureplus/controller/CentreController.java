package com.example.candidatureplus.controller;

import com.example.candidatureplus.entity.Centre;
import com.example.candidatureplus.entity.Utilisateur;
import com.example.candidatureplus.repository.CentreRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import jakarta.servlet.http.HttpSession;
import java.util.List;
import java.util.Map;
import java.util.HashMap;
import java.util.stream.Collectors;
import com.example.candidatureplus.dto.ApiResponse; // added

@RestController
@RequestMapping("/api/centres")
@CrossOrigin(origins = "http://localhost:3000")
public class CentreController {

    @Autowired
    private CentreRepository centreRepository;

    @GetMapping
    public ResponseEntity<ApiResponse<List<Map<String, Object>>>> getAllCentres(HttpSession session) {
        try {
            Utilisateur user = (Utilisateur) session.getAttribute("utilisateur");
            List<Centre> centres = centreRepository.findAll();
            final boolean isLocal = user != null && user.getRole() == Utilisateur.Role.GestionnaireLocal
                    && user.getCentre() != null;
            final Integer centreLocalId = isLocal ? user.getCentre().getId() : null;
            List<Map<String, Object>> centresSimples = centres.stream()
                    .map(c -> convertToMapSimple(c, !isLocal || c.getId().equals(centreLocalId)))
                    .collect(Collectors.toList());
            return ResponseEntity.ok(ApiResponse.ok(centresSimples));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }

    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse<Map<String, Object>>> getCentreById(@PathVariable Integer id,
            HttpSession session) {
        try {
            Utilisateur user = (Utilisateur) session.getAttribute("utilisateur");
            Centre centre = centreRepository.findById(id)
                    .orElseThrow(() -> new RuntimeException("Centre non trouvé"));
            // Contrôle d'accès pour gestionnaire local
            if (user != null && user.getRole() == Utilisateur.Role.GestionnaireLocal && user.getCentre() != null
                    && !user.getCentre().getId().equals(id)) {
                return ResponseEntity.status(403).body(ApiResponse.error("Accès refusé"));
            }
            return ResponseEntity.ok(ApiResponse.ok(convertToMapSimple(centre, true)));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }

    private Map<String, Object> convertToMapSimple(Centre centre, boolean accessible) {
        Map<String, Object> result = new HashMap<>();
        result.put("id", centre.getId());
        result.put("nom", centre.getNom());
        result.put("adresse", centre.getAdresse());
        result.put("ville", centre.getVille());
        result.put("telephone", centre.getTelephone());
        result.put("email", centre.getEmail());
        result.put("actif", centre.getActif());
        result.put("dateCreation", centre.getDateCreation());
        result.put("accessible", accessible); // Pour griser côté front
        return result;
    }
}
