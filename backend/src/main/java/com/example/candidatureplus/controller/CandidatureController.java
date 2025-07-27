package com.example.candidatureplus.controller;

import com.example.candidatureplus.entity.*;
import com.example.candidatureplus.repository.*;
import com.example.candidatureplus.dto.CandidatureRequest;
import com.example.candidatureplus.dto.CandidatureResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/candidatures")
@CrossOrigin(origins = "http://localhost:3000")
public class CandidatureController {

    @Autowired
    private CandidatRepository candidatRepository;
    
    @Autowired
    private CandidatureRepository candidatureRepository;
    
    @Autowired
    private ConcoursRepository concoursRepository;
    
    @Autowired
    private SpecialiteRepository specialiteRepository;
    
    @Autowired
    private CentreRepository centreRepository;

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
                    .body(new CandidatureResponse("Vous avez déjà une candidature pour ce concours", null));
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

            return ResponseEntity.ok(new CandidatureResponse(
                "Candidature soumise avec succès", 
                candidat.getNumeroUnique()
            ));

        } catch (Exception e) {
            return ResponseEntity.badRequest()
                .body(new CandidatureResponse("Erreur lors de la soumission: " + e.getMessage(), null));
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
            // Dans une version future, on pourrait gérer plusieurs candidatures
            Candidature candidature = candidatures.get(0);
            
            return ResponseEntity.ok(candidature);

        } catch (Exception e) {
            return ResponseEntity.notFound().build();
        }
    }

    @GetMapping("/candidat/{candidatId}")
    public ResponseEntity<List<Candidature>> getCandidaturesByCandidat(@PathVariable Integer candidatId) {
        List<Candidature> candidatures = candidatureRepository.findByCandidat_Id(candidatId);
        return ResponseEntity.ok(candidatures);
    }

    @GetMapping("/concours/{concoursId}")
    public ResponseEntity<List<Candidature>> getCandidaturesByConcours(@PathVariable Integer concoursId) {
        List<Candidature> candidatures = candidatureRepository.findByConcours_Id(concoursId);
        return ResponseEntity.ok(candidatures);
    }

    @GetMapping("/centre/{centreId}")
    public ResponseEntity<List<Candidature>> getCandidaturesByCentre(@PathVariable Integer centreId) {
        List<Candidature> candidatures = candidatureRepository.findByCentre_Id(centreId);
        return ResponseEntity.ok(candidatures);
    }

    private void copyDataFromRequest(Candidat candidat, CandidatureRequest.CandidatData data) {
        candidat.setNom(data.getNom());
        candidat.setPrenom(data.getPrenom());
        candidat.setCin(data.getCin());
        candidat.setDateNaissance(data.getDateNaissance());
        candidat.setLieuNaissance(data.getLieuNaissance());
        candidat.setAdresse(data.getAdresse());
        candidat.setVille(data.getVille());
        candidat.setCodePostal(data.getCodePostal());
        candidat.setEmail(data.getEmail());
        candidat.setTelephone(data.getTelephone());
        candidat.setTelephoneUrgence(data.getTelephoneUrgence());
        candidat.setNiveauEtudes(data.getNiveauEtudes());
        candidat.setDiplomePrincipal(data.getDiplomePrincipal());
        candidat.setSpecialiteDiplome(data.getSpecialiteDiplome());
        candidat.setEtablissement(data.getEtablissement());
        candidat.setAnneeObtention(data.getAnneeObtention());
        candidat.setExperienceProfessionnelle(data.getExperienceProfessionnelle());
        candidat.setConditionsAcceptees(data.getConditionsAcceptees());
    }

    private String generateNumeroUnique() {
        String prefix = "CAND-" + java.time.Year.now() + "-";
        String suffix;
        String numeroUnique;
        
        do {
            suffix = String.format("%06d", (int) (Math.random() * 999999) + 1);
            numeroUnique = prefix + suffix;
        } while (candidatRepository.existsByNumeroUnique(numeroUnique));
        
        return numeroUnique;
    }
}
