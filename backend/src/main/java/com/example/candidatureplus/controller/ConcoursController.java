package com.example.candidatureplus.controller;

import com.example.candidatureplus.entity.Concours;
import com.example.candidatureplus.entity.Specialite;
import com.example.candidatureplus.entity.Centre;
import com.example.candidatureplus.repository.ConcoursRepository;
import com.example.candidatureplus.repository.ConcoursSpecialiteRepository;
import com.example.candidatureplus.repository.ConcoursCentreRepository;
import com.example.candidatureplus.repository.CandidatureRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.List;
import java.util.Map;
import java.util.HashMap;
import java.util.stream.Collectors;
import com.example.candidatureplus.dto.ApiResponse; // added

@RestController
@RequestMapping("/api/concours")
@CrossOrigin(origins = "http://localhost:3000")
public class ConcoursController {

    @Autowired
    private ConcoursRepository concoursRepository;
    @Autowired
    private ConcoursSpecialiteRepository concoursSpecialiteRepository;
    @Autowired
    private ConcoursCentreRepository concoursCentreRepository;
    @Autowired
    private CandidatureRepository candidatureRepository;

    /**
     * Récupérer tous les concours
     */
    @GetMapping
    public ResponseEntity<ApiResponse<List<Map<String, Object>>>> getAllConcours() {
        try {
            List<Concours> concours = concoursRepository.findAll();

            List<Map<String, Object>> concoursSimples = concours.stream()
                    .map(this::convertToMapSimple)
                    .collect(Collectors.toList());

            return ResponseEntity.ok(ApiResponse.ok(concoursSimples));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }

    /**
     * Récupérer un concours par ID
     */
    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse<Map<String, Object>>> getConcoursById(@PathVariable Integer id) {
        try {
            Concours concours = concoursRepository.findById(id)
                    .orElseThrow(() -> new RuntimeException("Concours non trouvé"));

            return ResponseEntity.ok(ApiResponse.ok(convertToMapDetailed(concours)));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }

    /**
     * Récupérer les concours actifs (ouverts aux candidatures)
     */
    @GetMapping("/actifs")
    public ResponseEntity<ApiResponse<List<Map<String, Object>>>> getConcoursActifs() {
        try {
            LocalDate aujourdhui = LocalDate.now();
            List<Concours> concoursActifs = concoursRepository.findConcoursActifs(aujourdhui);

            List<Map<String, Object>> result = concoursActifs.stream()
                    .map(this::convertToMapSimple)
                    .collect(Collectors.toList());

            return ResponseEntity.ok(ApiResponse.ok(result));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }

    /**
     * Récupérer les spécialités d'un concours
     */
    @GetMapping("/{id}/specialites")
    public ResponseEntity<ApiResponse<List<Map<String, Object>>>> getSpecialitesByConcours(@PathVariable Integer id) {
        try {
            List<Specialite> specialites = concoursSpecialiteRepository.findSpecialitesByConcoursId(id);

            List<Map<String, Object>> specialitesSimples = specialites.stream()
                    .map(this::convertSpecialiteToMap)
                    .collect(Collectors.toList());

            return ResponseEntity.ok(ApiResponse.ok(specialitesSimples));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }

    /**
     * Récupérer les centres d'un concours
     */
    @GetMapping("/{id}/centres")
    public ResponseEntity<ApiResponse<List<Map<String, Object>>>> getCentresByConcours(@PathVariable Integer id) {
        try {
            List<Centre> centres = concoursCentreRepository.findCentresByConcoursId(id);

            List<Map<String, Object>> centresSimples = centres.stream()
                    .map(this::convertCentreToMap)
                    .collect(Collectors.toList());

            return ResponseEntity.ok(ApiResponse.ok(centresSimples));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }

    /**
     * Créer un nouveau concours
     */
    @PostMapping
    public ResponseEntity<ApiResponse<Map<String, Object>>> createConcours(
            @RequestBody Map<String, Object> concoursData) {
        try {
            Concours concours = new Concours();
            concours.setNom((String) concoursData.get("nom"));
            concours.setDescription((String) concoursData.get("description"));

            // Conversion des dates
            if (concoursData.get("dateDebutCandidature") != null) {
                concours.setDateDebutCandidature(LocalDate.parse((String) concoursData.get("dateDebutCandidature")));
            }
            if (concoursData.get("dateFinCandidature") != null) {
                concours.setDateFinCandidature(LocalDate.parse((String) concoursData.get("dateFinCandidature")));
            }
            if (concoursData.get("dateExamen") != null) {
                concours.setDateExamen(LocalDate.parse((String) concoursData.get("dateExamen")));
            }

            concours.setConditionsParticipation((String) concoursData.get("conditionsParticipation"));
            concours.setDocumentsRequis((String) concoursData.get("documentsRequis"));
            concours.setFicheConcours((String) concoursData.get("ficheConcours"));

            Boolean actif = (Boolean) concoursData.get("actif");
            concours.setActif(actif != null ? actif : true);

            Concours saved = concoursRepository.save(concours);
            return ResponseEntity.ok(ApiResponse.ok("Concours créé", convertToMapDetailed(saved)));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }

    /**
     * Mettre à jour un concours
     */
    @PutMapping("/{id}")
    public ResponseEntity<ApiResponse<Map<String, Object>>> updateConcours(@PathVariable Integer id,
            @RequestBody Map<String, Object> concoursData) {
        try {
            Concours concours = concoursRepository.findById(id)
                    .orElseThrow(() -> new RuntimeException("Concours non trouvé"));

            if (concoursData.get("nom") != null) {
                concours.setNom((String) concoursData.get("nom"));
            }
            if (concoursData.get("description") != null) {
                concours.setDescription((String) concoursData.get("description"));
            }
            if (concoursData.get("dateDebutCandidature") != null) {
                concours.setDateDebutCandidature(LocalDate.parse((String) concoursData.get("dateDebutCandidature")));
            }
            if (concoursData.get("dateFinCandidature") != null) {
                concours.setDateFinCandidature(LocalDate.parse((String) concoursData.get("dateFinCandidature")));
            }
            if (concoursData.get("dateExamen") != null) {
                concours.setDateExamen(LocalDate.parse((String) concoursData.get("dateExamen")));
            }
            if (concoursData.get("conditionsParticipation") != null) {
                concours.setConditionsParticipation((String) concoursData.get("conditionsParticipation"));
            }
            if (concoursData.get("documentsRequis") != null) {
                concours.setDocumentsRequis((String) concoursData.get("documentsRequis"));
            }
            if (concoursData.get("ficheConcours") != null) {
                concours.setFicheConcours((String) concoursData.get("ficheConcours"));
            }
            if (concoursData.get("actif") != null) {
                concours.setActif((Boolean) concoursData.get("actif"));
            }

            Concours updated = concoursRepository.save(concours);
            return ResponseEntity.ok(ApiResponse.ok("Concours mis à jour", convertToMapDetailed(updated)));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }

    /**
     * Supprimer un concours (désactivation)
     */
    @DeleteMapping("/{id}")
    public ResponseEntity<ApiResponse<Map<String, String>>> deleteConcours(@PathVariable Integer id) {
        try {
            Concours concours = concoursRepository.findById(id)
                    .orElseThrow(() -> new RuntimeException("Concours non trouvé"));

            // Vérifier s'il y a des candidatures
            long nbCandidatures = candidatureRepository.findByConcours_Id(id).size();
            Map<String, String> response = new HashMap<>();
            if (nbCandidatures > 0) {
                // Désactiver au lieu de supprimer
                concours.setActif(false);
                concoursRepository.save(concours);

                response.put("message", "Concours désactivé car il y a des candidatures associées");
            } else {
                // Supprimer complètement
                concoursRepository.delete(concours);

                response.put("message", "Concours supprimé avec succès");
            }
            return ResponseEntity.ok(ApiResponse.ok(response));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }

    /**
     * Statistiques d'un concours
     */
    @GetMapping("/{id}/statistiques")
    public ResponseEntity<ApiResponse<Map<String, Object>>> getStatistiquesConcours(@PathVariable Integer id) {
        try {
            Map<String, Object> stats = new HashMap<>();

            long totalCandidatures = candidatureRepository.findByConcours_Id(id).size();

            stats.put("id", id);
            stats.put("totalCandidatures", totalCandidatures);
            stats.put("specialitesDisponibles", concoursSpecialiteRepository.findByConcoursId(id).size());
            stats.put("centresDisponibles", concoursCentreRepository.findByConcoursId(id).size());

            return ResponseEntity.ok(ApiResponse.ok(stats));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }

    // Méthodes utilitaires de conversion

    private Map<String, Object> convertToMapSimple(Concours concours) {
        Map<String, Object> map = new HashMap<>();
        map.put("id", concours.getId());
        map.put("nom", concours.getNom());
        map.put("description", concours.getDescription());
        map.put("dateDebutCandidature", concours.getDateDebutCandidature());
        map.put("dateFinCandidature", concours.getDateFinCandidature());
        map.put("dateExamen", concours.getDateExamen());
        map.put("actif", concours.getActif());
        map.put("ficheConcours", concours.getFicheConcours());
        return map;
    }

    private Map<String, Object> convertToMapDetailed(Concours concours) {
        Map<String, Object> map = convertToMapSimple(concours);
        map.put("conditionsParticipation", concours.getConditionsParticipation());
        map.put("documentsRequis", concours.getDocumentsRequis());
        map.put("dateCreation", concours.getDateCreation());
        return map;
    }

    private Map<String, Object> convertSpecialiteToMap(Specialite specialite) {
        Map<String, Object> map = new HashMap<>();
        map.put("id", specialite.getId());
        map.put("nom", specialite.getNom());
        map.put("code", specialite.getCode());
        map.put("domaine", specialite.getDomaine());
        map.put("description", specialite.getDescription());
        map.put("actif", specialite.getActif());
        return map;
    }

    private Map<String, Object> convertCentreToMap(Centre centre) {
        Map<String, Object> map = new HashMap<>();
        map.put("id", centre.getId());
        map.put("nom", centre.getNom());
        map.put("ville", centre.getVille());
        map.put("adresse", centre.getAdresse());
        map.put("telephone", centre.getTelephone());
        map.put("email", centre.getEmail());
        map.put("actif", centre.getActif());
        return map;
    }
}
