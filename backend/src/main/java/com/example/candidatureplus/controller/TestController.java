package com.example.candidatureplus.controller;

import com.example.candidatureplus.repository.CandidatRepository;
import com.example.candidatureplus.repository.UtilisateurRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/test")
@CrossOrigin(origins = "http://localhost:3000")
public class TestController {
    
    @Autowired
    private UtilisateurRepository utilisateurRepository;
    
    @Autowired
    private CandidatRepository candidatRepository;
    
    @GetMapping("/health")
    public ResponseEntity<Map<String, Object>> healthCheck() {
        Map<String, Object> response = new HashMap<>();
        
        try {
            // Test de connexion à la base de données
            long nbUtilisateurs = utilisateurRepository.count();
            long nbCandidats = candidatRepository.count();
            
            response.put("status", "OK");
            response.put("message", "Connexion à la base de données réussie");
            response.put("nombre_utilisateurs", nbUtilisateurs);
            response.put("nombre_candidats", nbCandidats);
            response.put("timestamp", System.currentTimeMillis());
            
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            response.put("status", "ERROR");
            response.put("message", "Erreur de connexion à la base de données");
            response.put("error", e.getMessage());
            response.put("timestamp", System.currentTimeMillis());
            
            return ResponseEntity.status(500).body(response);
        }
    }
    
    @GetMapping("/ping")
    public ResponseEntity<String> ping() {
        return ResponseEntity.ok("Backend CandidaturePlus est opérationnel !");
    }
}
