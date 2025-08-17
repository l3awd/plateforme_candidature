package com.example.candidatureplus.controller;

import com.example.candidatureplus.entity.*;
import com.example.candidatureplus.repository.*;
import com.example.candidatureplus.dto.SpecialiteDto;
import com.example.candidatureplus.dto.CentreDto;
import com.example.candidatureplus.dto.ApiResponse;
import com.example.candidatureplus.service.PermissionService;
import com.example.candidatureplus.service.UtilisateurCentreService;
import com.example.candidatureplus.service.ParametreService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.*;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/concours")
@CrossOrigin(origins = "http://localhost:3000")
public class ConcoursAssociationController {

    @Autowired
    private ConcoursRepository concoursRepository;
    @Autowired
    private SpecialiteRepository specialiteRepository;
    @Autowired
    private CentreRepository centreRepository;
    @Autowired
    private CentreSpecialiteRepository centreSpecialiteRepository;
    @Autowired
    private ConcoursSpecialiteRepository concoursSpecialiteRepository;
    @Autowired
    private ConcoursCentreRepository concoursCentreRepository;
    @Autowired
    private PermissionService permissionService;
    @Autowired
    private UtilisateurCentreService utilisateurCentreService;
    @Autowired
    private ParametreService parametreService;

    // Placeholder récupération utilisateur courant (à remplacer par vrai contexte
    // sécurité)
    private Integer currentUserId() {
        return 1;
    }

    private String currentUserRole() {
        return "Administrateur";
    }

    private boolean checkPermission(String code) {
        return permissionService.roleHas(currentUserRole(), code);
    }

    @GetMapping("/{concoursId}/specialites")
    public ResponseEntity<ApiResponse<List<SpecialiteDto>>> getSpecialitesByConcours(@PathVariable Integer concoursId) {
        try {
            if (!concoursRepository.existsById(concoursId))
                return ResponseEntity.status(404).body(ApiResponse.error("Concours introuvable"));
            List<Specialite> specialites = concoursSpecialiteRepository.findSpecialitesByConcoursId(concoursId);
            List<SpecialiteDto> specialiteDtos = specialites.stream()
                    .filter(Specialite::getActif)
                    .map(this::convertToSpecialiteDto)
                    .collect(Collectors.toList());
            return ResponseEntity.ok(ApiResponse.ok(specialiteDtos));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }

    @GetMapping("/{concoursId}/centres")
    public ResponseEntity<ApiResponse<List<CentreDto>>> getCentresByConcours(@PathVariable Integer concoursId) {
        try {
            if (!concoursRepository.existsById(concoursId))
                return ResponseEntity.status(404).body(ApiResponse.error("Concours introuvable"));
            List<Centre> centres = concoursCentreRepository.findCentresByConcoursId(concoursId);
            // Filtrage multi-centres pour gestionnaire local: restreindre aux rattachements
            // actifs
            if ("GestionnaireLocal".equals(currentUserRole())) {
                Set<Integer> autorises = new HashSet<>(utilisateurCentreService.centresIdsActifs(currentUserId()));
                centres = centres.stream().filter(c -> autorises.contains(c.getId())).collect(Collectors.toList());
            }
            List<CentreDto> centreDtos = centres.stream()
                    .filter(Centre::getActif)
                    .map(this::convertToCentreDto)
                    .collect(Collectors.toList());
            return ResponseEntity.ok(ApiResponse.ok(centreDtos));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }

    @PostMapping("/{concoursId}/centre-specialite")
    public ResponseEntity<ApiResponse<Map<String, Object>>> createOrUpdateCentreSpecialite(
            @PathVariable Integer concoursId,
            @RequestBody Map<String, Object> payload) {
        try {
            if (!checkPermission("QUOTA_GERER"))
                return ResponseEntity.status(403).body(ApiResponse.error("Permission manquante: QUOTA_GERER"));
            Integer centreId = (Integer) payload.get("centreId");
            Integer specialiteId = (Integer) payload.get("specialiteId");
            Integer nombrePlaces = (Integer) payload.getOrDefault("nombrePlaces", 0);

            Centre centre = centreRepository.findById(centreId)
                    .orElseThrow(() -> new RuntimeException("Centre introuvable"));
            Specialite specialite = specialiteRepository.findById(specialiteId)
                    .orElseThrow(() -> new RuntimeException("Spécialité introuvable"));
            Concours concours = concoursRepository.findById(concoursId)
                    .orElseThrow(() -> new RuntimeException("Concours introuvable"));

            // Restriction multi-centres pour gestionnaire local
            if ("GestionnaireLocal".equals(currentUserRole())) {
                if (utilisateurCentreService.centresIdsActifs(currentUserId()).stream()
                        .noneMatch(id -> id.equals(centreId)))
                    return ResponseEntity.status(403).body(ApiResponse.error("Centre non autorisé"));
            }

            CentreSpecialite cs = centreSpecialiteRepository
                    .findByCentreIdAndSpecialiteIdAndConcoursId(centreId, specialiteId, concoursId)
                    .orElseGet(() -> {
                        CentreSpecialite n = new CentreSpecialite();
                        n.setCentre(centre);
                        n.setSpecialite(specialite);
                        n.setConcours(concours);
                        return n;
                    });
            int occupees = cs.getPlacesOccupees() != null ? cs.getPlacesOccupees() : 0;
            if (nombrePlaces < occupees) {
                return ResponseEntity.badRequest()
                        .body(ApiResponse.error("Nombre de places inférieur aux places déjà occupées: " + occupees));
            }
            cs.setNombrePlacesDisponibles(nombrePlaces - occupees);
            cs.setPlacesOccupees(occupees);
            centreSpecialiteRepository.save(cs);

            Map<String, Object> data = Map.of(
                    "centreId", centreId,
                    "specialiteId", specialiteId,
                    "concoursId", concoursId,
                    "placesOccupees", occupees,
                    "placesRestantes", cs.getNombrePlacesDisponibles(),
                    "capaciteTotale", nombrePlaces);
            return ResponseEntity.ok(ApiResponse.ok("Quota enregistré", data));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }

    @GetMapping("/{concoursId}/centre-specialite")
    public ResponseEntity<ApiResponse<List<Map<String, Object>>>> listCentreSpecialite(
            @PathVariable Integer concoursId) {
        try {
            List<Map<String, Object>> result = centreSpecialiteRepository.findByConcoursId(concoursId).stream()
                    .filter(cs -> {
                        if ("GestionnaireLocal".equals(currentUserRole())) {
                            return utilisateurCentreService.centresIdsActifs(currentUserId())
                                    .contains(cs.getCentre().getId());
                        }
                        return true;
                    })
                    .map(cs -> Map.<String, Object>of(
                            "id", cs.getId(),
                            "centreId", cs.getCentre().getId(),
                            "centreNom", cs.getCentre().getNom(),
                            "specialiteId", cs.getSpecialite().getId(),
                            "specialiteNom", cs.getSpecialite().getNom(),
                            "placesOccupees", cs.getPlacesOccupees(),
                            "placesRestantes", cs.getNombrePlacesDisponibles(),
                            "capaciteTotale",
                            ((cs.getPlacesOccupees() == null ? 0 : cs.getPlacesOccupees())
                                    + (cs.getNombrePlacesDisponibles() == null ? 0 : cs.getNombrePlacesDisponibles()))))
                    .collect(Collectors.toList());
            return ResponseEntity.ok(ApiResponse.ok(result));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }

    @DeleteMapping("/{concoursId}/centre-specialite")
    public ResponseEntity<ApiResponse<Void>> deleteCentreSpecialite(@PathVariable Integer concoursId,
            @RequestParam Integer centreId,
            @RequestParam Integer specialiteId) {
        try {
            if (!checkPermission("QUOTA_GERER"))
                return ResponseEntity.status(403).body(ApiResponse.error("Permission manquante: QUOTA_GERER"));
            CentreSpecialite cs = centreSpecialiteRepository
                    .findByCentreIdAndSpecialiteIdAndConcoursId(centreId, specialiteId, concoursId)
                    .orElseThrow(() -> new RuntimeException("Association introuvable"));
            if (cs.getPlacesOccupees() != null && cs.getPlacesOccupees() > 0) {
                return ResponseEntity.badRequest()
                        .body(ApiResponse.error("Suppression refusée: des places sont déjà occupées"));
            }
            // Restriction multi-centres gestionnaire local
            if ("GestionnaireLocal".equals(currentUserRole()) &&
                    utilisateurCentreService.centresIdsActifs(currentUserId()).stream()
                            .noneMatch(id -> id.equals(centreId))) {
                return ResponseEntity.status(403).body(ApiResponse.error("Centre non autorisé"));
            }
            centreSpecialiteRepository.delete(cs);
            return ResponseEntity.ok(ApiResponse.ok("Association supprimée", null));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }

    private SpecialiteDto convertToSpecialiteDto(Specialite specialite) {
        return SpecialiteDto.builder()
                .id(specialite.getId())
                .nom(specialite.getNom())
                .domaine(specialite.getDomaine())
                .description(specialite.getDescription())
                .actif(specialite.getActif())
                .build();
    }

    private CentreDto convertToCentreDto(Centre centre) {
        return CentreDto.builder()
                .id(centre.getId())
                .nom(centre.getNom())
                .ville(centre.getVille())
                .adresse(centre.getAdresse())
                .telephone(centre.getTelephone())
                .email(centre.getEmail())
                .actif(centre.getActif())
                .build();
    }
}
