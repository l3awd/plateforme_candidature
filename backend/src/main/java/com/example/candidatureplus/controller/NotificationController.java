package com.example.candidatureplus.controller;

import com.example.candidatureplus.entity.Notification;
import com.example.candidatureplus.repository.NotificationRepository;
import com.example.candidatureplus.service.NotificationService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import jakarta.servlet.http.HttpSession;
import java.util.List;
import java.util.Map;
import java.util.HashMap;
import com.example.candidatureplus.dto.ApiResponse; // added

@RestController
@RequestMapping("/api/notifications")
@CrossOrigin(origins = "http://localhost:3000")
public class NotificationController {

    @Autowired
    private NotificationRepository notificationRepository;

    @Autowired
    private NotificationService notificationService;

    /**
     * Récupère les notifications d'un candidat
     */
    @GetMapping("/candidat/{candidatId}")
    public ResponseEntity<ApiResponse<List<Notification>>> getNotificationsCandidiat(@PathVariable Integer candidatId) {
        try {
            List<Notification> notifications = notificationRepository.findByTypeDestinataireAndDestinataireId(
                    Notification.TypeDestinataire.Candidat, candidatId);
            return ResponseEntity.ok(ApiResponse.ok(notifications));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }

    /**
     * Récupère les notifications d'un utilisateur
     */
    @GetMapping("/utilisateur/{utilisateurId}")
    public ResponseEntity<ApiResponse<List<Notification>>> getNotificationsUtilisateur(
            @PathVariable Integer utilisateurId) {
        try {
            List<Notification> notifications = notificationRepository.findByTypeDestinataireAndDestinataireId(
                    Notification.TypeDestinataire.Utilisateur, utilisateurId);
            return ResponseEntity.ok(ApiResponse.ok(notifications));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }

    /**
     * Récupère toutes les notifications (pour les administrateurs)
     */
    @GetMapping("/all")
    public ResponseEntity<ApiResponse<List<Notification>>> getAllNotifications(HttpSession session) {
        try {
            List<Notification> notifications = notificationRepository.findAll();
            return ResponseEntity.ok(ApiResponse.ok(notifications));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }

    /**
     * Récupère les statistiques des notifications
     */
    @GetMapping("/statistiques")
    public ResponseEntity<ApiResponse<Map<String, Object>>> getStatistiquesNotifications() {
        try {
            Map<String, Object> stats = new HashMap<>();

            long totalNotifications = notificationRepository.count();
            long notificationsEnvoyees = notificationRepository.countByEtat(Notification.Etat.Envoye);
            long notificationsEchec = notificationRepository.countByEtat(Notification.Etat.Echec);
            long notificationsEnAttente = notificationRepository.countByEtat(Notification.Etat.En_Attente);

            stats.put("total", totalNotifications);
            stats.put("envoyees", notificationsEnvoyees);
            stats.put("echec", notificationsEchec);
            stats.put("en_attente", notificationsEnAttente);

            // Calculer le taux de réussite
            if (totalNotifications > 0) {
                double tauxReussite = (double) notificationsEnvoyees / totalNotifications * 100;
                stats.put("taux_reussite", Math.round(tauxReussite * 100.0) / 100.0);
            } else {
                stats.put("taux_reussite", 0);
            }

            return ResponseEntity.ok(ApiResponse.ok(stats));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }

    /**
     * Relance les notifications en échec
     */
    @PostMapping("/relancer")
    public ResponseEntity<ApiResponse<Map<String, String>>> relancerNotificationsEchec(HttpSession session) {
        try {
            // Vérifier les permissions (optionnel pour le diagnostic)
            notificationService.relancerNotificationsEchec();

            Map<String, String> response = new HashMap<>();
            response.put("message", "Relance des notifications en échec démarrée");
            response.put("status", "success");

            return ResponseEntity.ok(ApiResponse.ok(response));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }

    /**
     * Endpoint de test pour vérifier que le système de notifications fonctionne
     */
    @GetMapping("/test")
    public ResponseEntity<ApiResponse<Map<String, Object>>> testNotifications() {
        Map<String, Object> response = new HashMap<>();

        try {
            // Compter les notifications par état
            long totalNotifications = notificationRepository.count();

            response.put("status", "OK");
            response.put("message", "Système de notifications opérationnel");
            response.put("total_notifications", totalNotifications);
            response.put("timestamp", System.currentTimeMillis());

            return ResponseEntity.ok(ApiResponse.ok(response));
        } catch (Exception e) {
            response.put("status", "ERROR");
            response.put("message", "Erreur dans le système de notifications");
            response.put("error", e.getMessage());
            response.put("timestamp", System.currentTimeMillis());

            return ResponseEntity.status(500).body(ApiResponse.error("Erreur: " + e.getMessage()));
        }
    }
}
