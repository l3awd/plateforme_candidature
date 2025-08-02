package com.example.candidatureplus.controller;

import com.example.candidatureplus.entity.LogAction;
import com.example.candidatureplus.repository.LogActionRepository;
import com.example.candidatureplus.service.LogActionService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import jakarta.servlet.http.HttpSession;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;
import java.util.HashMap;

@RestController
@RequestMapping("/api/logs")
@CrossOrigin(origins = "http://localhost:3000")
public class LogActionController {

    @Autowired
    private LogActionRepository logActionRepository;

    @Autowired
    private LogActionService logActionService;

    /**
     * Récupère tous les logs d'actions (pour les administrateurs)
     */
    @GetMapping
    public ResponseEntity<List<LogAction>> getAllLogs(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "50") int size,
            HttpSession session) {
        try {
            // Pour le diagnostic, on retourne les dernières actions
            List<LogAction> logs;
            if (size > 0) {
                logs = logActionRepository.findTop50ByOrderByDateActionDesc();
            } else {
                logs = logActionRepository.findAll();
            }

            return ResponseEntity.ok(logs);
        } catch (Exception e) {
            return ResponseEntity.badRequest().build();
        }
    }

    /**
     * Récupère les logs d'un acteur spécifique
     */
    @GetMapping("/acteur/{typeActeur}/{acteurId}")
    public ResponseEntity<List<LogAction>> getLogsByActeur(
            @PathVariable LogAction.TypeActeur typeActeur,
            @PathVariable Integer acteurId) {
        try {
            List<LogAction> logs = logActionRepository.findByTypeActeurAndActeurIdOrderByDateActionDesc(
                    typeActeur, acteurId);
            return ResponseEntity.ok(logs);
        } catch (Exception e) {
            return ResponseEntity.badRequest().build();
        }
    }

    /**
     * Récupère les logs par type d'action
     */
    @GetMapping("/action/{action}")
    public ResponseEntity<List<LogAction>> getLogsByAction(@PathVariable String action) {
        try {
            List<LogAction> logs = logActionRepository.findByActionOrderByDateActionDesc(action);
            return ResponseEntity.ok(logs);
        } catch (Exception e) {
            return ResponseEntity.badRequest().build();
        }
    }

    /**
     * Récupère les logs récents (dernières 24h)
     */
    @GetMapping("/recent")
    public ResponseEntity<List<LogAction>> getLogsRecents() {
        try {
            LocalDateTime depuis24h = LocalDateTime.now().minusDays(1);
            List<LogAction> logs = logActionRepository.findByDateActionAfterOrderByDateActionDesc(depuis24h);
            return ResponseEntity.ok(logs);
        } catch (Exception e) {
            return ResponseEntity.badRequest().build();
        }
    }

    /**
     * Récupère les statistiques des logs
     */
    @GetMapping("/statistiques")
    public ResponseEntity<Map<String, Object>> getStatistiquesLogs() {
        try {
            Map<String, Object> stats = new HashMap<>();

            long totalLogs = logActionRepository.count();

            // Compter par type d'acteur
            long logsCandidats = logActionRepository.countByTypeActeur(LogAction.TypeActeur.Candidat);
            long logsUtilisateurs = logActionRepository.countByTypeActeur(LogAction.TypeActeur.Utilisateur);
            long logsSysteme = logActionRepository.countByTypeActeur(LogAction.TypeActeur.Systeme);

            // Compter les logs récents (dernières 24h)
            LocalDateTime depuis24h = LocalDateTime.now().minusDays(1);
            long logsRecents = logActionRepository.countByDateActionAfter(depuis24h);

            stats.put("total", totalLogs);
            stats.put("candidats", logsCandidats);
            stats.put("utilisateurs", logsUtilisateurs);
            stats.put("systeme", logsSysteme);
            stats.put("dernières_24h", logsRecents);

            return ResponseEntity.ok(stats);
        } catch (Exception e) {
            return ResponseEntity.badRequest().build();
        }
    }

    /**
     * Endpoint de test pour vérifier que le système de logs fonctionne
     */
    @GetMapping("/test")
    public ResponseEntity<Map<String, Object>> testLogs() {
        Map<String, Object> response = new HashMap<>();

        try {
            // Créer un log de test
            logActionService.logSystemAction("TEST_DIAGNOSTIC", "Test du système de logs via l'API");

            // Compter les logs
            long totalLogs = logActionRepository.count();

            response.put("status", "OK");
            response.put("message", "Système de logs opérationnel");
            response.put("total_logs", totalLogs);
            response.put("test_log_created", true);
            response.put("timestamp", System.currentTimeMillis());

            return ResponseEntity.ok(response);
        } catch (Exception e) {
            response.put("status", "ERROR");
            response.put("message", "Erreur dans le système de logs");
            response.put("error", e.getMessage());
            response.put("timestamp", System.currentTimeMillis());

            return ResponseEntity.status(500).body(response);
        }
    }

    /**
     * Recherche dans les logs par mot-clé
     */
    @GetMapping("/search")
    public ResponseEntity<List<LogAction>> searchLogs(@RequestParam String keyword) {
        try {
            List<LogAction> logs = logActionRepository.findByActionContainingOrDetailsContainingOrderByDateActionDesc(
                    keyword);
            return ResponseEntity.ok(logs);
        } catch (Exception e) {
            return ResponseEntity.badRequest().build();
        }
    }
}
