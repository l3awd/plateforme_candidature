package com.example.candidatureplus.service;

import com.example.candidatureplus.entity.Candidature;
import com.example.candidatureplus.entity.Notification;
import com.example.candidatureplus.repository.NotificationRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;

@Service
public class NotificationService {
        @Autowired
        private NotificationRepository notificationRepository;
        @Autowired
        private LogActionService logActionService;
        private static final boolean EMAIL_ACTIF = false; // stub désactivé

        public void envoyerNotificationValidation(Candidature candidature, Integer numeroPlace) {
                stub("VALIDATION", candidature, numeroPlace, null);
        }

        public void envoyerNotificationRejet(Candidature candidature, String motif) {
                stub("REJET", candidature, null, motif);
        }

        public void envoyerNotificationInscription(Candidature candidature) {
                stub("INSCRIPTION", candidature, null, null);
        }

        private void stub(String type, Candidature candidature, Integer numeroPlace, String motif) {
                Notification notification = new Notification();
                notification.setTypeDestinataire(Notification.TypeDestinataire.Candidat);
                notification.setDestinataireId(candidature.getCandidat().getId());
                notification.setTypeNotification(Notification.TypeNotification.Systeme);
                notification.setSujet(type);
                notification.setMessage("STUB:" + type);
                notification.setEtat(Notification.Etat.Envoye);
                notification.setDateCreation(LocalDateTime.now());
                notification.setDateEnvoi(LocalDateTime.now());
                notificationRepository.save(notification);
                logActionService.logSystemAction("NOTIFICATION_STUB",
                                type + " candidature=" + candidature.getId()
                                                + (numeroPlace != null ? " place=" + numeroPlace : "")
                                                + (motif != null ? " motif=" + motif : ""));
        }

        public void relancerNotificationsEchec() {
                /* stub */ }

        public void envoyerConfirmationCandidature(Candidature candidature) {
                /* stub */ }
}
