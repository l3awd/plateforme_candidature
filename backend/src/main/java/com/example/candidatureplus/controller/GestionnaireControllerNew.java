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
import lombok.RequiredArgsConstructor;

import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping("/api/gestionnaire-new")
@RequiredArgsConstructor
@CrossOrigin(origins = "http://localhost:3000")
public class GestionnaireControllerNew {

    private final GestionnaireService gestionnaireService;

    private final StatistiquesService statistiquesService;

    @GetMapping("/candidatures")
    public ResponseEntity<List<CandidatureSimpleDto>> getAllCandidatures(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size,
            @RequestParam(required = false) Long concoursId,
            @RequestParam(required = false) Long specialiteId,
            @RequestParam(required = false) Long centreId,
            @RequestParam(required = false) String statut) {

        if (concoursId != null || specialiteId != null || centreId != null || statut != null) {
            List<CandidatureSimpleDto> candidatures = gestionnaireService.getCandidaturesByFilters(
                    concoursId, specialiteId, centreId, statut);
            return ResponseEntity.ok(candidatures);
        } else {
            Pageable pageable = PageRequest.of(page, size);
            Page<CandidatureSimpleDto> candidatures = gestionnaireService.getAllCandidatures(pageable);
            return ResponseEntity.ok(candidatures.getContent());
        }
    }

    @GetMapping("/candidatures/{id}")
    public ResponseEntity<CandidatureSimpleDto> getCandidatureDetails(@PathVariable Integer id) {
        Optional<CandidatureSimpleDto> candidature = gestionnaireService.getCandidatureDetails(id);
        return candidature.map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @GetMapping("/candidatures/{id}/cv")
    public ResponseEntity<byte[]> downloadCV(@PathVariable Integer id) {
        byte[] cvData = gestionnaireService.getCandidatureCV(id);
        if (cvData == null) {
            return ResponseEntity.notFound().build();
        }

        String contentType = gestionnaireService.getCandidatureCVType(id);

        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.parseMediaType(contentType));
        headers.setContentDispositionFormData("attachment", "CV_" + id + ".pdf");

        return ResponseEntity.ok()
                .headers(headers)
                .body(cvData);
    }

    @PutMapping("/candidatures/{id}/statut")
    public ResponseEntity<String> updateStatut(@PathVariable Integer id, @RequestBody String nouveauStatut) {
        boolean success = gestionnaireService.updateCandidatureStatut(id, nouveauStatut);
        if (success) {
            return ResponseEntity.ok("Statut mis à jour avec succès");
        } else {
            return ResponseEntity.badRequest().body("Erreur lors de la mise à jour du statut");
        }
    }

    @GetMapping("/statistiques")
    public ResponseEntity<StatistiquesDto> getStatistiques() {
        StatistiquesDto stats = statistiquesService.getStatistiquesGenerales();
        return ResponseEntity.ok(stats);
    }

    @GetMapping("/statistiques/statuts")
    public ResponseEntity<List<StatistiquesDto.StatutCount>> getStatistiquesParStatut() {
        List<StatistiquesDto.StatutCount> stats = statistiquesService.getStatistiquesParStatut();
        return ResponseEntity.ok(stats);
    }

    @GetMapping("/statistiques/concours")
    public ResponseEntity<List<StatistiquesDto.ConcoursCount>> getStatistiquesParConcours() {
        List<StatistiquesDto.ConcoursCount> stats = statistiquesService.getStatistiquesParConcours();
        return ResponseEntity.ok(stats);
    }

    @GetMapping("/statistiques/centres-populaires")
    public ResponseEntity<List<StatistiquesDto.CentrePopulaire>> getCentresPopulaires() {
        List<StatistiquesDto.CentrePopulaire> centres = statistiquesService.getCentresPopulaires();
        return ResponseEntity.ok(centres);
    }

    @GetMapping("/export/candidatures")
    public ResponseEntity<byte[]> exportCandidatures(@RequestParam String format) {
        // Implémentation future pour l'export Excel/PDF
        return ResponseEntity.ok("Export en cours de développement".getBytes());
    }
}
