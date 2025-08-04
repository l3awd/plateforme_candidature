package com.example.candidatureplus.controller;

import com.example.candidatureplus.entity.Specialite;
import com.example.candidatureplus.repository.SpecialiteRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
import java.util.HashMap;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/specialites")
@CrossOrigin(origins = "http://localhost:3000")
public class SpecialiteController {

    @Autowired
    private SpecialiteRepository specialiteRepository;

    @GetMapping
    public ResponseEntity<List<Map<String, Object>>> getAllSpecialites() {
        try {
            List<Specialite> specialites = specialiteRepository.findAll();

            List<Map<String, Object>> specialitesSimples = specialites.stream()
                    .map(this::convertToMapSimple)
                    .collect(Collectors.toList());

            return ResponseEntity.ok(specialitesSimples);
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.badRequest().build();
        }
    }

    @GetMapping("/{id}")
    public ResponseEntity<Map<String, Object>> getSpecialiteById(@PathVariable Integer id) {
        try {
            Specialite specialite = specialiteRepository.findById(id)
                    .orElseThrow(() -> new RuntimeException("Spécialité non trouvée"));

            return ResponseEntity.ok(convertToMapSimple(specialite));
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.badRequest().build();
        }
    }

    private Map<String, Object> convertToMapSimple(Specialite specialite) {
        Map<String, Object> result = new HashMap<>();
        result.put("id", specialite.getId());
        result.put("nom", specialite.getNom());
        result.put("code", specialite.getCode());
        result.put("description", specialite.getDescription());
        // Vérifier si domaine existe avant de l'ajouter
        if (specialite.getDomaine() != null) {
            result.put("domaine", specialite.getDomaine());
        }
        result.put("actif", specialite.getActif());
        result.put("dateCreation", specialite.getDateCreation());
        return result;
    }
}
