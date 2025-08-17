package com.example.candidatureplus.controller;

import org.springframework.web.bind.annotation.*;
import org.springframework.http.ResponseEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import com.example.candidatureplus.dto.CandidatureSimpleDto;
import com.example.candidatureplus.dto.StatistiquesDto;
import com.example.candidatureplus.service.GestionnaireService;
import com.example.candidatureplus.service.StatistiquesService;
import com.example.candidatureplus.service.CandidatureService;
import com.example.candidatureplus.service.LogActionService;
import com.example.candidatureplus.entity.Utilisateur;
import lombok.RequiredArgsConstructor;
import jakarta.servlet.http.HttpSession;
import java.util.List;
import java.util.Optional;
import java.util.Map;
import java.util.HashMap;
import com.example.candidatureplus.dto.ApiResponse; // added

@RestController
@RequestMapping("/api/gestionnaire")
@RequiredArgsConstructor
@CrossOrigin(origins = "http://localhost:3000")
public class GestionnaireController {

    private final GestionnaireService gestionnaireService;
    private final StatistiquesService statistiquesService;
    private final CandidatureService candidatureService;
    private final LogActionService logActionService;

    /**
     * Récupérer toutes les candidatures avec filtres et pagination
     */
    @GetMapping("/candidatures")
    public ResponseEntity<ApiResponse<List<CandidatureSimpleDto>>> getAllCandidatures(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size,
            @RequestParam(required = false) Long concoursId,
            @RequestParam(required = false) Long specialiteId,
            @RequestParam(required = false) Long centreId,
            @RequestParam(required = false) String statut,
            HttpSession session) {

        // Vérifier l'authentification
        Integer userId = (Integer) session.getAttribute("userId");
        if (userId == null)
            return ResponseEntity.status(401).body(ApiResponse.error("Non authentifié"));
        Utilisateur user = (Utilisateur) session.getAttribute("utilisateur");
        try {
            List<CandidatureSimpleDto> candidatures;
            if (concoursId != null || specialiteId != null || centreId != null || statut != null) {
                candidatures = gestionnaireService.getCandidaturesByFiltersForUser(user, concoursId, specialiteId,
                        centreId, statut);
            } else {
                Pageable pageable = PageRequest.of(page, size);
                Page<CandidatureSimpleDto> pageResult = gestionnaireService.getAllCandidaturesFiltered(user, pageable);
                candidatures = pageResult.getContent();
            }
            return ResponseEntity.ok(ApiResponse.ok(candidatures));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }

    /**
     * Récupérer les détails d'une candidature
     */
    @GetMapping("/candidatures/{id}")
    public ResponseEntity<ApiResponse<CandidatureSimpleDto>> getCandidatureDetails(@PathVariable Integer id,
            HttpSession session) {
        Integer userId = (Integer) session.getAttribute("userId");
        if (userId == null)
            return ResponseEntity.status(401).body(ApiResponse.error("Non authentifié"));
        try {
            Optional<CandidatureSimpleDto> candidature = gestionnaireService.getCandidatureDetails(id);
            return candidature.map(c -> ResponseEntity.ok(ApiResponse.ok(c)))
                    .orElse(ResponseEntity.status(404).body(ApiResponse.error("Candidature non trouvée")));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }

    /**
     * Télécharger le CV d'une candidature
     */
    @GetMapping("/candidatures/{id}/cv")
    public ResponseEntity<byte[]> downloadCV(@PathVariable Integer id, HttpSession session) {
        Integer userId = (Integer) session.getAttribute("userId");
        if (userId == null)
            return ResponseEntity.status(401).build();
        try {
            byte[] cvData = gestionnaireService.getCandidatureCV(id);
            String contentType = gestionnaireService.getCandidatureCVType(id);
            return ResponseEntity.ok().contentType(MediaType.parseMediaType(contentType))
                    .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=\"cv_candidature_" + id + ".pdf\"")
                    .body(cvData);
        } catch (Exception e) {
            return ResponseEntity.notFound().build();
        }
    }

    /**
     * Mettre à jour le statut d'une candidature
     */
    @PutMapping("/candidatures/{id}/action")
    public ResponseEntity<ApiResponse<Map<String, Object>>> actionCandidature(@PathVariable Integer id,
            @RequestBody Map<String, String> body, HttpSession session) {
        Integer userId = (Integer) session.getAttribute("userId");
        if (userId == null)
            return ResponseEntity.status(401).body(ApiResponse.error("Non authentifié"));
        String action = body.getOrDefault("action", "");
        String motif = body.get("motif");
        Map<String, Object> resp = new HashMap<>();
        try {
            switch (action) {
                case "en_cours" -> {
                    candidatureService.marquerEnCoursValidation(id, userId);
                    resp.put("message", "Marquée en cours");
                }
                case "valider" -> {
                    candidatureService.validerCandidature(id, userId);
                    resp.put("message", "Validée");
                }
                case "rejeter" -> {
                    if (motif == null || motif.isBlank())
                        return ResponseEntity.badRequest().body(ApiResponse.error("Motif requis"));
                    candidatureService.rejeterCandidature(id, motif, userId);
                    resp.put("message", "Rejetée");
                }
                default -> {
                    return ResponseEntity.badRequest().body(ApiResponse.error("Action inconnue"));
                }
            }
            return ResponseEntity.ok(ApiResponse.ok(resp));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }

    /**
     * Récupérer les statistiques générales
     */
    @GetMapping("/statistiques")
    public ResponseEntity<ApiResponse<StatistiquesDto>> getStatistiques(HttpSession session) {
        Integer userId = (Integer) session.getAttribute("userId");
        if (userId == null)
            return ResponseEntity.status(401).body(ApiResponse.error("Non authentifié"));
        try {
            return ResponseEntity.ok(ApiResponse.ok(statistiquesService.getStatistiquesGenerales()));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }

    /**
     * Récupérer les statistiques par statut
     */
    @GetMapping("/statistiques/statuts")
    public ResponseEntity<ApiResponse<List<StatistiquesDto.StatutCount>>> getStatistiquesParStatut(
            HttpSession session) {
        Integer userId = (Integer) session.getAttribute("userId");
        if (userId == null)
            return ResponseEntity.status(401).body(ApiResponse.error("Non authentifié"));
        try {
            return ResponseEntity.ok(ApiResponse.ok(statistiquesService.getStatistiquesParStatut()));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }

    /**
     * Récupérer les statistiques par concours
     */
    @GetMapping("/statistiques/concours")
    public ResponseEntity<ApiResponse<List<StatistiquesDto.ConcoursCount>>> getStatistiquesParConcours(
            HttpSession session) {
        Integer userId = (Integer) session.getAttribute("userId");
        if (userId == null)
            return ResponseEntity.status(401).body(ApiResponse.error("Non authentifié"));
        try {
            return ResponseEntity.ok(ApiResponse.ok(statistiquesService.getStatistiquesParConcours()));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }

    /**
     * Récupérer les centres les plus populaires
     */
    @GetMapping("/statistiques/centres-populaires")
    public ResponseEntity<ApiResponse<List<StatistiquesDto.CentrePopulaire>>> getCentresPopulaires(
            HttpSession session) {
        Integer userId = (Integer) session.getAttribute("userId");
        if (userId == null)
            return ResponseEntity.status(401).body(ApiResponse.error("Non authentifié"));
        try {
            return ResponseEntity.ok(ApiResponse.ok(statistiquesService.getCentresPopulaires()));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }

    /**
     * Exporter les candidatures (format CSV/Excel)
     */
    @GetMapping("/export/candidatures")
    public ResponseEntity<byte[]> exportCandidatures(@RequestParam String format,
            @RequestParam(required = false) Long concoursId, @RequestParam(required = false) String statut,
            HttpSession session) {
        Integer userId = (Integer) session.getAttribute("userId");
        if (userId == null)
            return ResponseEntity.status(401).build();
        try {
            String content = "Export des candidatures en cours de développement";
            if ("csv".equalsIgnoreCase(format)) {
                return ResponseEntity.ok().contentType(MediaType.parseMediaType("text/csv"))
                        .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=\"candidatures.csv\"")
                        .body(content.getBytes());
            } else {
                return ResponseEntity.ok().contentType(MediaType.parseMediaType("application/vnd.ms-excel"))
                        .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=\"candidatures.xlsx\"")
                        .body(content.getBytes());
            }
        } catch (Exception e) {
            return ResponseEntity.badRequest().build();
        }
    }

    /**
     * Récupérer les candidatures en attente pour un gestionnaire
     */
    @GetMapping("/candidatures/en-attente")
    public ResponseEntity<ApiResponse<List<CandidatureSimpleDto>>> getCandidaturesEnAttente(
            @RequestParam(required = false) Integer centreId, HttpSession session) {
        Integer userId = (Integer) session.getAttribute("userId");
        if (userId == null)
            return ResponseEntity.status(401).body(ApiResponse.error("Non authentifié"));
        try {
            List<CandidatureSimpleDto> candidatures = gestionnaireService.getCandidaturesByFilters(null, null,
                    centreId != null ? centreId.longValue() : null, "Soumise");
            return ResponseEntity.ok(ApiResponse.ok(candidatures));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }

    /**
     * Traitement en lot des candidatures
     */
    @PostMapping("/candidatures/traitement-lot")
    public ResponseEntity<ApiResponse<Map<String, Object>>> traitementLot(
            @RequestBody Map<String, Object> traitementData, HttpSession session) {
        Integer userId = (Integer) session.getAttribute("userId");
        if (userId == null)
            return ResponseEntity.status(401).body(ApiResponse.error("Non authentifié"));
        try {
            @SuppressWarnings("unchecked")
            List<Integer> candidatureIds = (List<Integer>) traitementData.get("candidatureIds");
            String action = (String) traitementData.get("action");
            String motif = (String) traitementData.get("motif");
            int succes = 0;
            int echecs = 0;
            for (Integer candidatureId : candidatureIds) {
                try {
                    switch (action) {
                        case "valider" -> {
                            candidatureService.validerCandidature(candidatureId, userId);
                            succes++;
                        }
                        case "rejeter" -> {
                            candidatureService.rejeterCandidature(candidatureId, motif, userId);
                            succes++;
                        }
                        case "en_cours" -> {
                            candidatureService.marquerEnCoursValidation(candidatureId, userId);
                            succes++;
                        }
                        default -> {
                            echecs++;
                        }
                    }
                } catch (Exception ex) {
                    echecs++;
                }
            }
            Map<String, Object> response = new HashMap<>();
            response.put("succes", succes);
            response.put("echecs", echecs);
            response.put("total", candidatureIds.size());
            response.put("message", echecs == 0 ? "Toutes les candidatures ont été traitées avec succès"
                    : succes + " candidatures traitées, " + echecs + " échecs");
            return ResponseEntity.ok(ApiResponse.ok(response));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }

    /**
     * Recherche avancée de candidatures
     */
    @PostMapping("/candidatures/recherche")
    public ResponseEntity<ApiResponse<List<CandidatureSimpleDto>>> rechercheAvancee(
            @RequestBody Map<String, Object> criteres, HttpSession session) {
        Integer userId = (Integer) session.getAttribute("userId");
        if (userId == null)
            return ResponseEntity.status(401).body(ApiResponse.error("Non authentifié"));
        try {
            Long concoursId = criteres.get("concoursId") != null ? Long.valueOf(criteres.get("concoursId").toString())
                    : null;
            Long specialiteId = criteres.get("specialiteId") != null
                    ? Long.valueOf(criteres.get("specialiteId").toString())
                    : null;
            Long centreId = criteres.get("centreId") != null ? Long.valueOf(criteres.get("centreId").toString()) : null;
            String statut = (String) criteres.get("statut");
            List<CandidatureSimpleDto> candidatures = gestionnaireService.getCandidaturesByFilters(concoursId,
                    specialiteId, centreId, statut);
            return ResponseEntity.ok(ApiResponse.ok(candidatures));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }

    /**
     * Tableau de bord du gestionnaire
     */
    @GetMapping("/dashboard")
    public ResponseEntity<ApiResponse<Map<String, Object>>> getDashboard(HttpSession session) {
        Integer userId = (Integer) session.getAttribute("userId");
        if (userId == null)
            return ResponseEntity.status(401).body(ApiResponse.error("Non authentifié"));
        try {
            Map<String, Object> dashboard = new HashMap<>();
            StatistiquesDto stats = statistiquesService.getStatistiquesGenerales();
            dashboard.put("statistiques", stats);
            List<CandidatureSimpleDto> enAttente = gestionnaireService.getCandidaturesByFilters(null, null, null,
                    "Soumise");
            dashboard.put("candidaturesEnAttente", enAttente.size());
            List<CandidatureSimpleDto> enCours = gestionnaireService.getCandidaturesByFilters(null, null, null,
                    "En_Cours_Validation");
            dashboard.put("candidaturesEnCours", enCours.size());
            return ResponseEntity.ok(ApiResponse.ok(dashboard));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }
}
