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
import lombok.RequiredArgsConstructor;

import jakarta.servlet.http.HttpSession;
import java.util.List;
import java.util.Optional;
import java.util.Map;
import java.util.HashMap;

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
    public ResponseEntity<List<CandidatureSimpleDto>> getAllCandidatures(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size,
            @RequestParam(required = false) Long concoursId,
            @RequestParam(required = false) Long specialiteId,
            @RequestParam(required = false) Long centreId,
            @RequestParam(required = false) String statut,
            HttpSession session) {

        // Vérifier l'authentification
        Integer userId = (Integer) session.getAttribute("userId");
        if (userId == null) {
            return ResponseEntity.status(401).build();
        }

        try {
            if (concoursId != null || specialiteId != null || centreId != null || statut != null) {
                List<CandidatureSimpleDto> candidatures = gestionnaireService.getCandidaturesByFilters(
                        concoursId, specialiteId, centreId, statut);
                return ResponseEntity.ok(candidatures);
            } else {
                Pageable pageable = PageRequest.of(page, size);
                Page<CandidatureSimpleDto> candidatures = gestionnaireService.getAllCandidatures(pageable);
                return ResponseEntity.ok(candidatures.getContent());
            }
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.badRequest().build();
        }
    }

    /**
     * Récupérer les détails d'une candidature
     */
    @GetMapping("/candidatures/{id}")
    public ResponseEntity<CandidatureSimpleDto> getCandidatureDetails(@PathVariable Integer id, HttpSession session) {
        Integer userId = (Integer) session.getAttribute("userId");
        if (userId == null) {
            return ResponseEntity.status(401).build();
        }

        try {
            Optional<CandidatureSimpleDto> candidature = gestionnaireService.getCandidatureDetails(id);
            return candidature.map(ResponseEntity::ok)
                    .orElse(ResponseEntity.notFound().build());
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.badRequest().build();
        }
    }

    /**
     * Télécharger le CV d'une candidature
     */
    @GetMapping("/candidatures/{id}/cv")
    public ResponseEntity<byte[]> downloadCV(@PathVariable Integer id, HttpSession session) {
        Integer userId = (Integer) session.getAttribute("userId");
        if (userId == null) {
            return ResponseEntity.status(401).build();
        }

        try {
            byte[] cvData = gestionnaireService.getCandidatureCV(id);
            String contentType = gestionnaireService.getCandidatureCVType(id);

            return ResponseEntity.ok()
                    .contentType(MediaType.parseMediaType(contentType))
                    .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=\"cv_candidature_" + id + ".pdf\"")
                    .body(cvData);
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.notFound().build();
        }
    }

    /**
     * Mettre à jour le statut d'une candidature
     */
    @PutMapping("/candidatures/{id}/statut")
    public ResponseEntity<Map<String, String>> updateStatut(@PathVariable Integer id,
            @RequestBody Map<String, String> statutData,
            HttpSession session) {
        Integer userId = (Integer) session.getAttribute("userId");
        if (userId == null) {
            return ResponseEntity.status(401).build();
        }

        try {
            String nouveauStatut = statutData.get("statut");
            String motif = statutData.get("motif");

            Map<String, String> response = new HashMap<>();

            switch (nouveauStatut) {
                case "En_Cours_Validation":
                    candidatureService.marquerEnCoursValidation(id, userId);
                    response.put("message", "Candidature marquée en cours de validation");
                    break;
                case "Validee":
                    candidatureService.validerCandidature(id, userId);
                    response.put("message", "Candidature validée avec succès");
                    break;
                case "Rejetee":
                    if (motif == null || motif.trim().isEmpty()) {
                        response.put("error", "Le motif de rejet est obligatoire");
                        return ResponseEntity.badRequest().body(response);
                    }
                    candidatureService.rejeterCandidature(id, motif, userId);
                    response.put("message", "Candidature rejetée");
                    break;
                default:
                    response.put("error", "Statut non reconnu");
                    return ResponseEntity.badRequest().body(response);
            }

            return ResponseEntity.ok(response);
        } catch (Exception e) {
            e.printStackTrace();
            Map<String, String> error = new HashMap<>();
            error.put("error", "Erreur lors de la mise à jour: " + e.getMessage());
            return ResponseEntity.badRequest().body(error);
        }
    }

    /**
     * Récupérer les statistiques générales
     */
    @GetMapping("/statistiques")
    public ResponseEntity<StatistiquesDto> getStatistiques(HttpSession session) {
        Integer userId = (Integer) session.getAttribute("userId");
        if (userId == null) {
            return ResponseEntity.status(401).build();
        }

        try {
            StatistiquesDto stats = statistiquesService.getStatistiquesGenerales();
            return ResponseEntity.ok(stats);
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.badRequest().build();
        }
    }

    /**
     * Récupérer les statistiques par statut
     */
    @GetMapping("/statistiques/statuts")
    public ResponseEntity<List<StatistiquesDto.StatutCount>> getStatistiquesParStatut(HttpSession session) {
        Integer userId = (Integer) session.getAttribute("userId");
        if (userId == null) {
            return ResponseEntity.status(401).build();
        }

        try {
            List<StatistiquesDto.StatutCount> stats = statistiquesService.getStatistiquesParStatut();
            return ResponseEntity.ok(stats);
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.badRequest().build();
        }
    }

    /**
     * Récupérer les statistiques par concours
     */
    @GetMapping("/statistiques/concours")
    public ResponseEntity<List<StatistiquesDto.ConcoursCount>> getStatistiquesParConcours(HttpSession session) {
        Integer userId = (Integer) session.getAttribute("userId");
        if (userId == null) {
            return ResponseEntity.status(401).build();
        }

        try {
            List<StatistiquesDto.ConcoursCount> stats = statistiquesService.getStatistiquesParConcours();
            return ResponseEntity.ok(stats);
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.badRequest().build();
        }
    }

    /**
     * Récupérer les centres les plus populaires
     */
    @GetMapping("/statistiques/centres-populaires")
    public ResponseEntity<List<StatistiquesDto.CentrePopulaire>> getCentresPopulaires(HttpSession session) {
        Integer userId = (Integer) session.getAttribute("userId");
        if (userId == null) {
            return ResponseEntity.status(401).build();
        }

        try {
            List<StatistiquesDto.CentrePopulaire> centres = statistiquesService.getCentresPopulaires();
            return ResponseEntity.ok(centres);
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.badRequest().build();
        }
    }

    /**
     * Exporter les candidatures (format CSV/Excel)
     */
    @GetMapping("/export/candidatures")
    public ResponseEntity<byte[]> exportCandidatures(@RequestParam String format,
            @RequestParam(required = false) Long concoursId,
            @RequestParam(required = false) String statut,
            HttpSession session) {
        Integer userId = (Integer) session.getAttribute("userId");
        if (userId == null) {
            return ResponseEntity.status(401).build();
        }

        try {
            // Pour l'instant, retour d'un message simple
            // TODO: Implémenter l'export réel
            String content = "Export des candidatures en cours de développement";

            if ("csv".equalsIgnoreCase(format)) {
                return ResponseEntity.ok()
                        .contentType(MediaType.parseMediaType("text/csv"))
                        .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=\"candidatures.csv\"")
                        .body(content.getBytes());
            } else {
                return ResponseEntity.ok()
                        .contentType(MediaType.parseMediaType("application/vnd.ms-excel"))
                        .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=\"candidatures.xlsx\"")
                        .body(content.getBytes());
            }
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.badRequest().build();
        }
    }

    /**
     * Récupérer les candidatures en attente pour un gestionnaire
     */
    @GetMapping("/candidatures/en-attente")
    public ResponseEntity<List<CandidatureSimpleDto>> getCandidaturesEnAttente(
            @RequestParam(required = false) Integer centreId,
            HttpSession session) {
        Integer userId = (Integer) session.getAttribute("userId");
        if (userId == null) {
            return ResponseEntity.status(401).build();
        }

        try {
            // Si pas de centre spécifié, utiliser le centre du gestionnaire ou tous
            List<CandidatureSimpleDto> candidatures = gestionnaireService.getCandidaturesByFilters(
                    null, null, centreId != null ? centreId.longValue() : null, "Soumise");
            return ResponseEntity.ok(candidatures);
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.badRequest().build();
        }
    }

    /**
     * Traitement en lot des candidatures
     */
    @PostMapping("/candidatures/traitement-lot")
    public ResponseEntity<Map<String, Object>> traitementLot(@RequestBody Map<String, Object> traitementData,
            HttpSession session) {
        Integer userId = (Integer) session.getAttribute("userId");
        if (userId == null) {
            return ResponseEntity.status(401).build();
        }

        try {
            @SuppressWarnings("unchecked")
            List<Integer> candidatureIds = (List<Integer>) traitementData.get("candidatureIds");
            String action = (String) traitementData.get("action");
            String motif = (String) traitementData.get("motif");

            Map<String, Object> response = new HashMap<>();
            int succes = 0;
            int echecs = 0;

            for (Integer candidatureId : candidatureIds) {
                try {
                    switch (action) {
                        case "valider":
                            candidatureService.validerCandidature(candidatureId, userId);
                            succes++;
                            break;
                        case "rejeter":
                            candidatureService.rejeterCandidature(candidatureId, motif, userId);
                            succes++;
                            break;
                        case "en_cours":
                            candidatureService.marquerEnCoursValidation(candidatureId, userId);
                            succes++;
                            break;
                        default:
                            echecs++;
                    }
                } catch (Exception e) {
                    echecs++;
                }
            }

            response.put("succes", succes);
            response.put("echecs", echecs);
            response.put("total", candidatureIds.size());

            if (echecs == 0) {
                response.put("message", "Toutes les candidatures ont été traitées avec succès");
            } else {
                response.put("message", succes + " candidatures traitées, " + echecs + " échecs");
            }

            return ResponseEntity.ok(response);
        } catch (Exception e) {
            e.printStackTrace();
            Map<String, Object> error = new HashMap<>();
            error.put("error", "Erreur lors du traitement en lot: " + e.getMessage());
            return ResponseEntity.badRequest().body(error);
        }
    }

    /**
     * Recherche avancée de candidatures
     */
    @PostMapping("/candidatures/recherche")
    public ResponseEntity<List<CandidatureSimpleDto>> rechercheAvancee(@RequestBody Map<String, Object> criteres,
            HttpSession session) {
        Integer userId = (Integer) session.getAttribute("userId");
        if (userId == null) {
            return ResponseEntity.status(401).build();
        }

        try {
            // Extraction des critères de recherche
            Long concoursId = criteres.get("concoursId") != null ? Long.valueOf(criteres.get("concoursId").toString())
                    : null;
            Long specialiteId = criteres.get("specialiteId") != null
                    ? Long.valueOf(criteres.get("specialiteId").toString())
                    : null;
            Long centreId = criteres.get("centreId") != null ? Long.valueOf(criteres.get("centreId").toString()) : null;
            String statut = (String) criteres.get("statut");

            List<CandidatureSimpleDto> candidatures = gestionnaireService.getCandidaturesByFilters(
                    concoursId, specialiteId, centreId, statut);

            return ResponseEntity.ok(candidatures);
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.badRequest().build();
        }
    }

    /**
     * Tableau de bord du gestionnaire
     */
    @GetMapping("/dashboard")
    public ResponseEntity<Map<String, Object>> getDashboard(HttpSession session) {
        Integer userId = (Integer) session.getAttribute("userId");
        if (userId == null) {
            return ResponseEntity.status(401).build();
        }

        try {
            Map<String, Object> dashboard = new HashMap<>();

            // Statistiques rapides
            StatistiquesDto stats = statistiquesService.getStatistiquesGenerales();
            dashboard.put("statistiques", stats);

            // Candidatures en attente
            List<CandidatureSimpleDto> enAttente = gestionnaireService.getCandidaturesByFilters(
                    null, null, null, "Soumise");
            dashboard.put("candidaturesEnAttente", enAttente.size());

            // Candidatures à traiter aujourd'hui
            List<CandidatureSimpleDto> enCours = gestionnaireService.getCandidaturesByFilters(
                    null, null, null, "En_Cours_Validation");
            dashboard.put("candidaturesEnCours", enCours.size());

            return ResponseEntity.ok(dashboard);
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.badRequest().build();
        }
    }
}
