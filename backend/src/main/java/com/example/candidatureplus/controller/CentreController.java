package com.example.candidatureplus.controller;

import com.example.candidatureplus.entity.Centre;
import com.example.candidatureplus.repository.CentreRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
import java.util.HashMap;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/centres")
@CrossOrigin(origins = "http://localhost:3000")
public class CentreController {

    @Autowired
    private CentreRepository centreRepository;

    @GetMapping
    public ResponseEntity<List<Map<String, Object>>> getAllCentres() {
        try {
            List<Centre> centres = centreRepository.findAll();

            List<Map<String, Object>> centresSimples = centres.stream()
                    .map(this::convertToMapSimple)
                    .collect(Collectors.toList());

            return ResponseEntity.ok(centresSimples);
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.badRequest().build();
        }
    }

    @GetMapping("/{id}")
    public ResponseEntity<Map<String, Object>> getCentreById(@PathVariable Integer id) {
        try {
            Centre centre = centreRepository.findById(id)
                    .orElseThrow(() -> new RuntimeException("Centre non trouvé"));

            return ResponseEntity.ok(convertToMapSimple(centre));
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.badRequest().build();
        }
    }

    private Map<String, Object> convertToMapSimple(Centre centre) {
        Map<String, Object> result = new HashMap<>();
        result.put("id", centre.getId());
        result.put("nom", centre.getNom());
        result.put("adresse", centre.getAdresse());
        result.put("ville", centre.getVille());
        result.put("telephone", centre.getTelephone());
        result.put("email", centre.getEmail());
        result.put("actif", centre.getActif());
        result.put("dateCreation", centre.getDateCreation());
        return result;
    }
}
