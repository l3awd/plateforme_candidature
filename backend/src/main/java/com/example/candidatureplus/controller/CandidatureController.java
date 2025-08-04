package com.example.candidatureplus.controller;

import com.example.candidatureplus.entity.*;
import com.example.candidatureplus.repository.*;
import com.example.candidatureplus.dto.*;
import com.example.candidatureplus.service.CandidatureService;
import com.example.candidatureplus.service.CandidatureEnhancedService;
import com.example.candidatureplus.service.NotificationService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.servlet.http.HttpSession;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

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

    @PostMapping("/soumettre")
    public ResponseEntity<CandidatureResponse> soumettreCandidate(@RequestBody CandidatureRequest request) {
        try {
            // Vérifier si le candidat existe déjà par CIN ou email
            Candidat candidat = candidatRepository.findByCin(request.getCandidat().getCin())
                    .orElse(null);

            if (candidat == null) {
                candidat = candidatRepository.findByEmail(request.getCandidat().getEmail())
                        .orElse(null);
            }

            // Si le candidat n'existe pas, le créer
            if (candidat == null) {
                candidat = new Candidat();
                candidat.setNumeroUnique(generateNumeroUnique());
                copyDataFromRequest(candidat, request.getCandidat());
                candidat = candidatRepository.save(candidat);
            } else {
                // Mettre à jour les informations du candidat existant
                copyDataFromRequest(candidat, request.getCandidat());
                candidat = candidatRepository.save(candidat);
            }

            // Vérifier si le candidat a déjà une candidature pour ce concours
            boolean existingCandidature = candidatureRepository.existsByCandidat_IdAndConcours_Id(
                    candidat.getId(), request.getConcoursId());

            if (existingCandidature) {
                return ResponseEntity.badRequest()
                        .body(CandidatureResponse.builder()
                                .success(false)
                                .message("Vous avez déjà une candidature pour ce concours")
                                .build());
            }

            // Récupérer les entités liées
            Concours concours = concoursRepository.findById(request.getConcoursId())
                    .orElseThrow(() -> new RuntimeException("Concours non trouvé"));

            Specialite specialite = specialiteRepository.findById(request.getSpecialiteId())
                    .orElseThrow(() -> new RuntimeException("Spécialité non trouvée"));

            Centre centre = centreRepository.findById(request.getCentreId())
                    .orElseThrow(() -> new RuntimeException("Centre non trouvé"));

            // Créer la candidature
            Candidature candidature = new Candidature();
            candidature.setCandidat(candidat);
            candidature.setConcours(concours);
            candidature.setSpecialite(specialite);
            candidature.setCentre(centre);
            candidature.setEtat(Candidature.Etat.Soumise);
            candidature.setDateSoumission(LocalDateTime.now());

            candidature = candidatureRepository.save(candidature);

            // Envoyer notification d'inscription
            notificationService.envoyerNotificationInscription(candidature);

            return ResponseEntity.ok(CandidatureResponse.builder()
                    .success(true)
                    .message("Candidature soumise avec succès")
                    .numeroUnique(candidat.getNumeroUnique())
                    .build());

        } catch (Exception e) {
            return ResponseEntity.badRequest()
                    .body(CandidatureResponse.builder()
                            .success(false)
                            .message("Erreur lors de la soumission: " + e.getMessage())
                            .build());
        }
    }

    @PostMapping("/soumettre-avec-cv")
    public ResponseEntity<CandidatureResponse> soumettreAvecCV(
            @RequestParam("data") String jsonData,
            @RequestParam(value = "cv", required = false) MultipartFile cvFile) {
        try {
            ObjectMapper objectMapper = new ObjectMapper();
            CandidatureRequest request = objectMapper.readValue(jsonData, CandidatureRequest.class);

            CandidatureResponse response = candidatureEnhancedService.soumettreAvecCV(request, cvFile);
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            return ResponseEntity.badRequest()
                    .body(CandidatureResponse.builder()
                            .success(false)
                            .message("Erreur lors de la soumission: " + e.getMessage())
                            .build());
        }
    }

    @GetMapping("/centre/{centreId}")
    public ResponseEntity<List<Map<String, Object>>> getCandidaturesByCentre(@PathVariable Integer centreId) {
        try {
            List<Map<String, Object>> candidatures = candidatureService.getCandidaturesByCentre(centreId);
            return ResponseEntity.ok(candidatures);
        } catch (Exception e) {
            return ResponseEntity.badRequest().build();
        }
    }

    @GetMapping("/centre/{centreId}/etat/{etat}")
    public ResponseEntity<List<Map<String, Object>>> getCandidaturesByCentreAndEtat(
            @PathVariable Integer centreId,
            @PathVariable String etat) {
        try {
            // Récupérer toutes les candidatures du centre et filtrer par état
            List<Map<String, Object>> candidaturesMap = candidatureService.getCandidaturesByCentre(centreId)
                    .stream()
                    .filter(c -> etat.equals(c.get("etat")))
                    .collect(Collectors.toList());
            return ResponseEntity.ok(candidaturesMap);
        } catch (Exception e) {
            return ResponseEntity.badRequest().build();
        }
    }

    @PostMapping("/{id}/valider")
    public ResponseEntity<ValidationResponse> validerCandidature(
            @PathVariable Integer id,
            @RequestBody ValidationRequest request,
            HttpSession session) {

        try {
            // Vérifier l'authentification
            Integer userId = (Integer) session.getAttribute("userId");
            if (userId == null) {
                return ResponseEntity.status(401)
                        .body(ValidationResponse.failure("Non authentifié"));
            }

            ValidationResponse response = candidatureService.validerCandidature(id, request, userId);
            return ResponseEntity.ok(response);

        } catch (Exception e) {
            return ResponseEntity.badRequest()
                    .body(ValidationResponse.failure("Erreur lors de la validation: " + e.getMessage()));
        }
    }

    @PostMapping("/{id}/rejeter")
    public ResponseEntity<ValidationResponse> rejeterCandidature(
            @PathVariable Integer id,
            @RequestBody RejetRequest request,
            HttpSession session) {

        try {
            // Vérifier l'authentification
            Integer userId = (Integer) session.getAttribute("userId");
            if (userId == null) {
                return ResponseEntity.status(401)
                        .body(ValidationResponse.failure("Non authentifié"));
            }

            ValidationResponse response = candidatureService.rejeterCandidature(id, request, userId);
            return ResponseEntity.ok(response);

        } catch (Exception e) {
            return ResponseEntity.badRequest()
                    .body(ValidationResponse.failure("Erreur lors du rejet: " + e.getMessage()));
        }
    }

    @GetMapping("/suivi/{numeroUnique}")
    public ResponseEntity<?> suivreCandidature(@PathVariable String numeroUnique) {
        try {
            Candidat candidat = candidatRepository.findByNumeroUnique(numeroUnique)
                    .orElseThrow(() -> new RuntimeException("Candidat non trouvé"));

            List<Candidature> candidatures = candidatureRepository.findByCandidat_Id(candidat.getId());

            if (candidatures.isEmpty()) {
                return ResponseEntity.notFound().build();
            }

            // Pour l'instant, retourner la première candidature
            Candidature candidature = candidatures.get(0);
            return ResponseEntity.ok(candidature);

        } catch (Exception e) {
            return ResponseEntity.notFound().build();
        }
    }

    @GetMapping("/statistiques/globales")
    public ResponseEntity<Map<String, Object>> getStatistiquesGlobales(HttpSession session) {
        try {
            Integer userId = (Integer) session.getAttribute("userId");
            if (userId == null) {
                return ResponseEntity.status(401).build();
            }

            Map<String, Object> stats = candidatureService.getStatistiquesGlobales();
            return ResponseEntity.ok(stats);

        } catch (Exception e) {
            return ResponseEntity.badRequest().build();
        }
    }

    @GetMapping("/statistiques/centre/{centreId}")
    public ResponseEntity<Map<String, Object>> getStatistiquesCentre(@PathVariable Integer centreId) {
        try {
            Map<String, Object> stats = candidatureService.getStatistiquesCentre(centreId);
            return ResponseEntity.ok(stats);
        } catch (Exception e) {
            return ResponseEntity.badRequest().build();
        }
    }

    @GetMapping("/export/csv")
    public ResponseEntity<String> exporterCandidaturesCSV(
            @RequestParam(required = false) Integer centreId,
            @RequestParam(required = false) String statut) {
        try {
            String csvContent = candidatureService.exporterCandidaturesCSV(centreId, statut);
            return ResponseEntity.ok()
                    .header("Content-Type", "text/csv")
                    .header("Content-Disposition", "attachment; filename=candidatures.csv")
                    .body(csvContent);
        } catch (Exception e) {
            return ResponseEntity.badRequest().build();
        }
    }

    @GetMapping("/recherche")
    public ResponseEntity<List<Map<String, Object>>> rechercherCandidatures(
            @RequestParam(required = false) String numeroUnique,
            @RequestParam(required = false) String nom,
            @RequestParam(required = false) String cin,
            @RequestParam(required = false) String statut,
            @RequestParam(required = false) Integer centreId) {
        try {
            List<Map<String, Object>> candidatures = candidatureService.rechercherCandidatures(
                    numeroUnique, nom, cin, statut, centreId);
            return ResponseEntity.ok(candidatures);
        } catch (Exception e) {
            return ResponseEntity.badRequest().build();
        }
    }

    // Méthodes utilitaires
    private String generateNumeroUnique() {
        return "CAND" + System.currentTimeMillis();
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
