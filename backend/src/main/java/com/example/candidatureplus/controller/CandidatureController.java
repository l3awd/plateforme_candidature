package com.example.candidatureplus.controller;

import com.example.candidatureplus.entity.*;
import com.example.candidatureplus.repository.*;
import com.example.candidatureplus.dto.*;
import com.example.candidatureplus.service.CandidatureService;
import com.example.candidatureplus.service.CandidatureEnhancedService;
import com.example.candidatureplus.service.NotificationService;
import com.example.candidatureplus.service.DocumentService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.servlet.http.HttpSession;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/candidatures")
@CrossOrigin(origins = "http://localhost:3000")
public class CandidatureController {

    @Autowired
    private CandidatRepository candidatRepository;

    @Autowired
    private CandidatureRepository candidatureRepository;

    @Autowired
    private CentreRepository centreRepository;

    @Autowired
    private ConcoursRepository concoursRepository;

    @Autowired
    private SpecialiteRepository specialiteRepository;

    @Autowired
    private CandidatureService candidatureService;

    @Autowired
    private CandidatureEnhancedService candidatureEnhancedService;

    @Autowired
    private NotificationService notificationService;

    @Autowired
    private DocumentService documentService;

    @PostMapping("/soumettre")
    public ResponseEntity<ApiResponse<CandidatureResponse>> soumettreCandidate(
            @RequestBody CandidatureRequest request) {
        try {
            // Harmonisation des valeurs Genre côté backend (Masculin/Feminin)
            if (request.getCandidat() != null && request.getCandidat().getGenre() == null) {
                // mapping éventuel si nécessaire
            }
            Candidat candidat = candidatRepository.findByCin(request.getCandidat().getCin())
                    .orElseGet(() -> candidatRepository.findByEmail(request.getCandidat().getEmail()).orElse(null));
            if (candidat == null) {
                candidat = new Candidat();
                candidat.setNumeroUnique(generateNumeroUnique());
            }
            copyDataFromRequest(candidat, request.getCandidat());
            candidat = candidatRepository.save(candidat);

            if (candidatureRepository.existsByCandidat_IdAndConcours_Id(candidat.getId(), request.getConcoursId())) {
                return ResponseEntity.badRequest()
                        .body(ApiResponse.error("Vous avez déjà une candidature pour ce concours"));
            }
            Concours concours = concoursRepository.findById(request.getConcoursId())
                    .orElseThrow(() -> new RuntimeException("Concours non trouvé"));
            Specialite specialite = specialiteRepository.findById(request.getSpecialiteId())
                    .orElseThrow(() -> new RuntimeException("Spécialité non trouvée"));
            Centre centre = centreRepository.findById(request.getCentreId())
                    .orElseThrow(() -> new RuntimeException("Centre non trouvé"));

            Candidature candidature = new Candidature();
            candidature.setCandidat(candidat);
            candidature.setConcours(concours);
            candidature.setSpecialite(specialite);
            candidature.setCentre(centre);
            candidature.setEtat(Candidature.Etat.Soumise);
            candidature.setDateSoumission(LocalDateTime.now());
            candidature = candidatureRepository.save(candidature);
            // Rattacher éventuels documents pré-uploadés (CIN, CV, Diplome) via CIN
            try {
                documentService.rattacherPreUploadedDocuments(candidat.getCin(), candidature.getId());
            } catch (Exception ignore) {
            }

            notificationService.envoyerNotificationInscription(candidature);

            CandidatureResponse payload = CandidatureResponse.builder().success(true)
                    .message("Candidature soumise avec succès")
                    .numeroUnique(candidat.getNumeroUnique())
                    .candidatureId(candidature.getId())
                    .build();
            return ResponseEntity.ok(ApiResponse.ok(payload));
        } catch (Exception e) {
            return ResponseEntity.badRequest()
                    .body(ApiResponse.error("Erreur lors de la soumission: " + e.getMessage()));
        }
    }

    @PostMapping("/soumettre-avec-cv")
    public ResponseEntity<ApiResponse<CandidatureResponse>> soumettreAvecCV(
            @RequestParam("data") String jsonData,
            @RequestParam(value = "cv", required = false) MultipartFile cvFile) {
        try {
            ObjectMapper objectMapper = new ObjectMapper();
            CandidatureRequest request = objectMapper.readValue(jsonData, CandidatureRequest.class);
            CandidatureResponse response = candidatureEnhancedService.soumettreAvecCV(request, cvFile);
            if (!response.isSuccess())
                return ResponseEntity.badRequest().body(ApiResponse.error(response.getMessage()));
            return ResponseEntity.ok(ApiResponse.ok(response));
        } catch (Exception e) {
            return ResponseEntity.badRequest()
                    .body(ApiResponse.error("Erreur lors de la soumission: " + e.getMessage()));
        }
    }

    @GetMapping("/centre/{centreId}")
    public ResponseEntity<ApiResponse<List<Map<String, Object>>>> getCandidaturesByCentre(
            @PathVariable Integer centreId, HttpSession session) {
        try {
            Integer userId = (Integer) session.getAttribute("userId");
            List<Map<String, Object>> candidatures = candidatureService.getCandidaturesByCentre(centreId, userId);
            return ResponseEntity.ok(ApiResponse.ok(candidatures));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }

    @GetMapping("/centre/{centreId}/etat/{etat}")
    public ResponseEntity<ApiResponse<List<Map<String, Object>>>> getCandidaturesByCentreAndEtat(
            @PathVariable Integer centreId,
            @PathVariable String etat,
            HttpSession session) {
        try {
            Integer userId = (Integer) session.getAttribute("userId");
            List<Map<String, Object>> base = candidatureService.getCandidaturesByCentre(centreId, userId);
            List<Map<String, Object>> candidaturesMap = base.stream()
                    .filter(c -> etat.equals(c.get("etat")))
                    .collect(java.util.stream.Collectors.toList());
            return ResponseEntity.ok(ApiResponse.ok(candidaturesMap));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }

    @PostMapping("/{id}/valider")
    public ResponseEntity<ApiResponse<ValidationResponse>> validerCandidature(
            @PathVariable Integer id,
            @RequestBody ValidationRequest request,
            HttpSession session) {

        try {
            Integer userId = (Integer) session.getAttribute("userId");
            if (userId == null)
                return ResponseEntity.status(401).body(ApiResponse.error("Non authentifié"));
            ValidationResponse resp = candidatureService.validerCandidature(id, request, userId);
            if (!resp.isSuccess())
                return ResponseEntity.badRequest().body(ApiResponse.error(resp.getMessage()));
            return ResponseEntity.ok(ApiResponse.ok(resp));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }

    @PostMapping("/{id}/rejeter")
    public ResponseEntity<ApiResponse<ValidationResponse>> rejeterCandidature(
            @PathVariable Integer id,
            @RequestBody RejetRequest request,
            HttpSession session) {

        try {
            Integer userId = (Integer) session.getAttribute("userId");
            if (userId == null)
                return ResponseEntity.status(401).body(ApiResponse.error("Non authentifié"));
            ValidationResponse resp = candidatureService.rejeterCandidature(id, request, userId);
            if (!resp.isSuccess())
                return ResponseEntity.badRequest().body(ApiResponse.error(resp.getMessage()));
            return ResponseEntity.ok(ApiResponse.ok(resp));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }

    @PostMapping("/{id}/confirmer")
    public ResponseEntity<ApiResponse<ValidationResponse>> confirmerCandidature(
            @PathVariable Integer id,
            HttpSession session) {
        try {
            Integer userId = (Integer) session.getAttribute("userId");
            if (userId == null)
                return ResponseEntity.status(401).body(ApiResponse.error("Non authentifié"));
            ValidationResponse resp = candidatureService.confirmerCandidature(id, userId);
            if (!resp.isSuccess())
                return ResponseEntity.badRequest().body(ApiResponse.error(resp.getMessage()));
            return ResponseEntity.ok(ApiResponse.ok(resp));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }

    @GetMapping("/suivi/{numeroUnique}")
    public ResponseEntity<ApiResponse<Object>> suivreCandidature(@PathVariable String numeroUnique) {
        try {
            Candidat candidat = candidatRepository.findByNumeroUnique(numeroUnique)
                    .orElseThrow(() -> new RuntimeException("Candidat non trouvé"));
            List<Candidature> candidatures = candidatureRepository.findByCandidat_Id(candidat.getId());
            if (candidatures.isEmpty()) {
                return ResponseEntity.status(404).body(ApiResponse.error("Aucune candidature trouvée"));
            }
            return ResponseEntity.ok(ApiResponse.ok(candidatures.get(0)));
        } catch (Exception e) {
            return ResponseEntity.status(404).body(ApiResponse.error(e.getMessage()));
        }
    }

    @GetMapping("/statistiques/globales")
    public ResponseEntity<ApiResponse<Map<String, Object>>> getStatistiquesGlobales(HttpSession session) {
        try {
            Integer userId = (Integer) session.getAttribute("userId");
            if (userId == null)
                return ResponseEntity.status(401).body(ApiResponse.error("Non authentifié"));
            return ResponseEntity.ok(ApiResponse.ok(candidatureService.getStatistiquesGlobales(userId)));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }

    @GetMapping("/statistiques/centre/{centreId}")
    public ResponseEntity<ApiResponse<Map<String, Object>>> getStatistiquesCentre(@PathVariable Integer centreId,
            HttpSession session) {
        try {
            Integer userId = (Integer) session.getAttribute("userId");
            return ResponseEntity
                    .ok(ApiResponse.ok(userId != null ? candidatureService.getStatistiquesCentreSecure(centreId, userId)
                            : candidatureService.getStatistiquesCentre(centreId)));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }

    @GetMapping("/recherche")
    public ResponseEntity<ApiResponse<List<Map<String, Object>>>> rechercherCandidatures(
            @RequestParam(required = false) String numeroUnique,
            @RequestParam(required = false) String nom,
            @RequestParam(required = false) String cin,
            @RequestParam(required = false) String statut,
            @RequestParam(required = false) Integer centreId,
            HttpSession session) {
        try {
            Integer userId = (Integer) session.getAttribute("userId");
            List<Map<String, Object>> candidatures = (userId != null)
                    ? candidatureService.rechercherCandidaturesForUser(numeroUnique, nom, cin, statut, centreId, userId)
                    : candidatureService.rechercherCandidatures(numeroUnique, nom, cin, statut, centreId);
            return ResponseEntity.ok(ApiResponse.ok(candidatures));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }

    // export CSV laissé brut (fichier) pour compatibilité téléchargement
    @GetMapping("/export/csv")
    public ResponseEntity<String> exporterCandidaturesCSV(
            @RequestParam(required = false) Integer centreId,
            @RequestParam(required = false) String statut,
            HttpSession session) {
        try {
            Integer userId = (Integer) session.getAttribute("userId");
            String csvContent = userId != null ? candidatureService.exporterCandidaturesCSV(centreId, statut, userId)
                    : candidatureService.exporterCandidaturesCSV(centreId, statut);
            return ResponseEntity.ok()
                    .header("Content-Type", "text/csv")
                    .header("Content-Disposition", "attachment; filename=candidatures.csv")
                    .body(csvContent);
        } catch (Exception e) {
            return ResponseEntity.badRequest().build();
        }
    }

    @GetMapping("/export/quotas-csv")
    public ResponseEntity<String> exportQuotasCsv(@RequestParam(required = false) Integer concoursId,
            HttpSession session) {
        try {
            Object roleObj = session.getAttribute("userRole");
            if (roleObj == null)
                return ResponseEntity.status(401).build();
            // Vérifier rôle (l'enum est stockée directement en session dans login)
            if (!(roleObj instanceof com.example.candidatureplus.entity.Utilisateur.Role role)
                    || role != com.example.candidatureplus.entity.Utilisateur.Role.GestionnaireGlobal) {
                return ResponseEntity.status(403).build();
            }
            String csv = candidatureService.exporterQuotasOccupationCSV(concoursId);
            return ResponseEntity.ok()
                    .header("Content-Type", "text/csv")
                    .header("Content-Disposition", "attachment; filename=quotas_occupation.csv")
                    .body(csv);
        } catch (Exception e) {
            return ResponseEntity.badRequest().build();
        }
    }

    @GetMapping("/{id}/documents/manquants")
    public ResponseEntity<ApiResponse<Map<String, Object>>> getDocumentsManquants(@PathVariable Integer id) {
        try {
            List<String> manquants = documentService.getDocumentsManquants(id);
            Map<String, Object> data = Map.of(
                    "documentsManquants", manquants,
                    "complets", manquants.isEmpty());
            return ResponseEntity.ok(ApiResponse.ok(data));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }

    @GetMapping("/statistiques/multi")
    public ResponseEntity<ApiResponse<Map<String, Object>>> statistiquesMulti(
            @RequestParam(required = false) Integer concoursId,
            HttpSession session) {
        try {
            Integer userId = (Integer) session.getAttribute("userId");
            Map<String, Object> data = (userId != null)
                    ? candidatureService.getStatistiquesMultiAxesForUser(concoursId, userId)
                    : candidatureService.getStatistiquesMultiAxes(concoursId);
            return ResponseEntity.ok(ApiResponse.ok(data));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }

    @GetMapping("/statistiques/avancees")
    public ResponseEntity<ApiResponse<Map<String, Object>>> statistiquesAvancees(HttpSession session) {
        try {
            Integer userId = (Integer) session.getAttribute("userId");
            Map<String, Object> data = (userId != null) ? candidatureService.getStatistiquesAvanceesForUser(userId)
                    : candidatureService.getStatistiquesAvancees();
            return ResponseEntity.ok(ApiResponse.ok(data));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }

    @GetMapping("/kpi/synthese")
    public ResponseEntity<ApiResponse<Map<String, Object>>> kpiSynthese(HttpSession session) {
        try {
            Integer userId = (Integer) session.getAttribute("userId");
            if (userId == null)
                return ResponseEntity.status(401).body(ApiResponse.error("Non authentifié"));
            return ResponseEntity.ok(ApiResponse.ok(candidatureService.getKpiSynthese(userId)));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }

    @GetMapping("/kpi/timeline30j")
    public ResponseEntity<ApiResponse<Map<String, Object>>> kpiTimeline30(HttpSession session) {
        try {
            Integer userId = (Integer) session.getAttribute("userId");
            if (userId == null)
                return ResponseEntity.status(401).body(ApiResponse.error("Non authentifié"));
            return ResponseEntity.ok(ApiResponse.ok(candidatureService.getTimeline30J(userId)));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }

    // Méthodes utilitaires
    private String generateNumeroUnique() {
        return "CAND-" + System.currentTimeMillis();
    }

    private void copyDataFromRequest(Candidat candidat, CandidatureRequest.CandidatData candidatRequest) {
        candidat.setNom(candidatRequest.getNom());
        candidat.setPrenom(candidatRequest.getPrenom());
        candidat.setGenre(candidatRequest.getGenre());
        candidat.setCin(candidatRequest.getCin());
        candidat.setEmail(candidatRequest.getEmail());
        candidat.setTelephone(candidatRequest.getTelephone());
        candidat.setTelephoneUrgence(candidatRequest.getTelephoneUrgence());
        candidat.setDateNaissance(candidatRequest.getDateNaissance());
        candidat.setLieuNaissance(candidatRequest.getLieuNaissance());
        candidat.setVille(candidatRequest.getVille());
        candidat.setNiveauEtudes(candidatRequest.getNiveauEtudes());
        candidat.setDiplomePrincipal(candidatRequest.getDiplomePrincipal());
        candidat.setSpecialiteDiplome(candidatRequest.getSpecialiteDiplome());
        candidat.setEtablissement(candidatRequest.getEtablissement());
        candidat.setAnneeObtention(candidatRequest.getAnneeObtention());
        candidat.setExperienceProfessionnelle(candidatRequest.getExperienceProfessionnelle());
        candidat.setConditionsAcceptees(candidatRequest.getConditionsAcceptees());
    }
}
