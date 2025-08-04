package com.example.candidatureplus.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import com.example.candidatureplus.repository.*;
import com.example.candidatureplus.entity.*;
import java.util.List;
import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api")
@CrossOrigin(origins = "http://localhost:3000")
public class MainController {

    @Autowired
    private CandidatRepository candidatRepository;

    @Autowired
    private ConcoursRepository concoursRepository;

    @Autowired
    private SpecialiteRepository specialiteRepository;

    @Autowired
    private CentreRepository centreRepository;

    // Page d'accueil de l'API
    @GetMapping("/")
    public ResponseEntity<Map<String, Object>> home() {
        Map<String, Object> response = new HashMap<>();
        response.put("message", "Bienvenue sur l'API CandidaturePlus");
        response.put("version", "1.0");
        response.put("status", "active");

        // Statistiques de base
        Map<String, Long> stats = new HashMap<>();
        stats.put("candidats", candidatRepository.count());
        stats.put("concours", concoursRepository.count());
        stats.put("specialites", specialiteRepository.count());
        stats.put("centres", centreRepository.count());

        response.put("statistics", stats);
        return ResponseEntity.ok(response);
    }

    // Endpoints pour les candidats
    @GetMapping("/candidats")
    public ResponseEntity<List<Candidat>> getAllCandidats() {
        return ResponseEntity.ok(candidatRepository.findAll());
    }

    @GetMapping("/candidats/{id}")
    public ResponseEntity<Candidat> getCandidatById(@PathVariable Integer id) {
        return candidatRepository.findById(id)
                .map(candidat -> ResponseEntity.ok().body(candidat))
                .orElse(ResponseEntity.notFound().build());
    }

    // Endpoints pour les spécialités
    @GetMapping("/specialites-legacy")
    public ResponseEntity<List<Specialite>> getAllSpecialites() {
        return ResponseEntity.ok(specialiteRepository.findAll());
    }

    @GetMapping("/specialites-legacy/{id}")
    public ResponseEntity<Specialite> getSpecialiteById(@PathVariable Integer id) {
        return specialiteRepository.findById(id)
                .map(specialite -> ResponseEntity.ok().body(specialite))
                .orElse(ResponseEntity.notFound().build());
    }

    // Endpoints pour les centres
    @GetMapping("/centres-legacy")
    public ResponseEntity<List<Centre>> getAllCentres() {
        return ResponseEntity.ok(centreRepository.findAll());
    }

    @GetMapping("/centres-legacy/{id}")
    public ResponseEntity<Centre> getCentreById(@PathVariable Integer id) {
        return centreRepository.findById(id)
                .map(centre -> ResponseEntity.ok().body(centre))
                .orElse(ResponseEntity.notFound().build());
    }

    // Endpoint de santé
    @GetMapping("/health")
    public ResponseEntity<Map<String, String>> health() {
        Map<String, String> status = new HashMap<>();
        status.put("status", "UP");
        status.put("database", "connected");
        status.put("timestamp", java.time.LocalDateTime.now().toString());
        return ResponseEntity.ok(status);
    }
}
