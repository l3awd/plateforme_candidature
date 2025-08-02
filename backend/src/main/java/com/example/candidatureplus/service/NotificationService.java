package com.example.candidatureplus.service;

import com.example.candidatureplus.entity.Candidature;
import com.example.candidatureplus.entity.Notification;
import com.example.candidatureplus.repository.NotificationRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;

@Service
public class NotificationService {

        @Autowired
        private NotificationRepository notificationRepository;

        @Autowired
        private JavaMailSender mailSender;

        @Autowired
        private LogActionService logActionService;

        /**
         * Envoie une notification de validation de candidature
         */
        public void envoyerNotificationValidation(Candidature candidature, Integer numeroPlace) {
                String sujet = "Candidature validée - CandidaturePlus";
                String message = String.format(
                                "Bonjour %s %s,\n\n" +
                                                "Nous avons le plaisir de vous informer que votre candidature pour le concours \"%s\" "
                                                +
                                                "a été validée avec succès.\n\n" +
                                                "Détails de votre candidature :\n" +
                                                "- Numéro unique : %s\n" +
                                                "- Concours : %s\n" +
                                                "- Spécialité : %s\n" +
                                                "- Centre d'examen : %s\n" +
                                                "- Numéro de place : %d\n" +
                                                "- Date de validation : %s\n\n" +
                                                "Vous recevrez prochainement les informations détaillées concernant le déroulement de l'examen.\n\n"
                                                +
                                                "Cordialement,\n" +
                                                "L'équipe CandidaturePlus",
                                candidature.getCandidat().getPrenom(),
                                candidature.getCandidat().getNom(),
                                candidature.getConcours().getNom(),
                                candidature.getCandidat().getNumeroUnique(),
                                candidature.getConcours().getNom(),
                                candidature.getSpecialite().getNom(),
                                candidature.getCentre().getNom(),
                                numeroPlace,
                                LocalDateTime.now().format(DateTimeFormatter.ofPattern("dd/MM/yyyy à HH:mm")));

                envoyerNotification(
                                Notification.TypeDestinataire.Candidat,
                                candidature.getCandidat().getId(),
                                Notification.TypeNotification.Email,
                                sujet,
                                message,
                                candidature.getCandidat().getEmail());
        }

        /**
         * Envoie une notification de rejet de candidature
         */
        public void envoyerNotificationRejet(Candidature candidature, String motif) {
                String sujet = "Candidature non retenue - CandidaturePlus";
                String message = String.format(
                                "Bonjour %s %s,\n\n" +
                                                "Nous avons le regret de vous informer que votre candidature pour le concours \"%s\" "
                                                +
                                                "n'a pas été retenue.\n\n" +
                                                "Détails de votre candidature :\n" +
                                                "- Numéro unique : %s\n" +
                                                "- Concours : %s\n" +
                                                "- Spécialité : %s\n" +
                                                "- Centre d'examen : %s\n" +
                                                "- Date de traitement : %s\n\n" +
                                                "Motif : %s\n\n" +
                                                "Nous vous encourageons à postuler pour les prochains concours si vous remplissez les conditions requises.\n\n"
                                                +
                                                "Cordialement,\n" +
                                                "L'équipe CandidaturePlus",
                                candidature.getCandidat().getPrenom(),
                                candidature.getCandidat().getNom(),
                                candidature.getConcours().getNom(),
                                candidature.getCandidat().getNumeroUnique(),
                                candidature.getConcours().getNom(),
                                candidature.getSpecialite().getNom(),
                                candidature.getCentre().getNom(),
                                LocalDateTime.now().format(DateTimeFormatter.ofPattern("dd/MM/yyyy à HH:mm")),
                                motif);

                envoyerNotification(
                                Notification.TypeDestinataire.Candidat,
                                candidature.getCandidat().getId(),
                                Notification.TypeNotification.Email,
                                sujet,
                                message,
                                candidature.getCandidat().getEmail());
        }

        /**
         * Envoie une notification de confirmation d'inscription
         */
        public void envoyerNotificationInscription(Candidature candidature) {
                String sujet = "Confirmation d'inscription - CandidaturePlus";
                String message = String.format(
                                "Bonjour %s %s,\n\n" +
                                                "Votre candidature a été enregistrée avec succès dans notre système.\n\n"
                                                +
                                                "Détails de votre candidature :\n" +
                                                "- Numéro unique : %s\n" +
                                                "- Concours : %s\n" +
                                                "- Spécialité : %s\n" +
                                                "- Centre d'examen : %s\n" +
                                                "- Date de soumission : %s\n\n" +
                                                "Vous pouvez suivre l'état de votre candidature en utilisant votre numéro unique sur notre plateforme.\n\n"
                                                +
                                                "Votre candidature sera examinée par nos équipes dans les plus brefs délais.\n\n"
                                                +
                                                "Cordialement,\n" +
                                                "L'équipe CandidaturePlus",
                                candidature.getCandidat().getPrenom(),
                                candidature.getCandidat().getNom(),
                                candidature.getCandidat().getNumeroUnique(),
                                candidature.getConcours().getNom(),
                                candidature.getSpecialite().getNom(),
                                candidature.getCentre().getNom(),
                                candidature.getDateSoumission()
                                                .format(DateTimeFormatter.ofPattern("dd/MM/yyyy à HH:mm")));

                envoyerNotification(
                                Notification.TypeDestinataire.Candidat,
                                candidature.getCandidat().getId(),
                                Notification.TypeNotification.Email,
                                sujet,
                                message,
                                candidature.getCandidat().getEmail());
        }

        /**
         * Méthode générique pour envoyer une notification
         */
        private void envoyerNotification(Notification.TypeDestinataire typeDestinataire,
                        Integer destinataireId,
                        Notification.TypeNotification typeNotification,
                        String sujet,
                        String message,
                        String emailDestinataire) {

                // Créer l'enregistrement de notification
                Notification notification = new Notification();
                notification.setTypeDestinataire(typeDestinataire);
                notification.setDestinataireId(destinataireId);
                notification.setTypeNotification(typeNotification);
                notification.setSujet(sujet);
                notification.setMessage(message);
                notification.setEtat(Notification.Etat.En_Attente);
                notification.setDateCreation(LocalDateTime.now());
                notification.setTentativesEnvoi(0);

                notification = notificationRepository.save(notification);

                // Envoyer l'email
                try {
                        SimpleMailMessage mailMessage = new SimpleMailMessage();
                        mailMessage.setTo(emailDestinataire);
                        mailMessage.setSubject(sujet);
                        mailMessage.setText(message);
                        mailMessage.setFrom("noreply@candidatureplus.ma");

                        mailSender.send(mailMessage);

                        // Marquer comme envoyé
                        notification.setEtat(Notification.Etat.Envoye);
                        notification.setDateEnvoi(LocalDateTime.now());

                        logActionService.logSystemAction("EMAIL_ENVOYE",
                                        "Email envoyé à " + emailDestinataire + " - Sujet: " + sujet);

                } catch (Exception e) {
                        // Marquer comme échec
                        notification.setEtat(Notification.Etat.Echec);
                        notification.setTentativesEnvoi(notification.getTentativesEnvoi() + 1);

                        logActionService.logSystemAction("EMAIL_ECHEC",
                                        "Échec envoi email à " + emailDestinataire + " - Erreur: " + e.getMessage());
                }

                notificationRepository.save(notification);
        }

        /**
         * Relance l'envoi des notifications en échec
         */
        public void relancerNotificationsEchec() {
                // Récupérer toutes les notifications en échec
                List<Notification> notificationsEchec = notificationRepository.findByEtat(Notification.Etat.Echec);

                // Filtrer celles avec moins de 3 tentatives
                List<Notification> notificationsARelancer = notificationsEchec.stream()
                                .filter(n -> n.getTentativesEnvoi() < 3)
                                .toList();

                logActionService.logSystemAction("RELANCE_NOTIFICATIONS",
                                "Début de relance pour " + notificationsARelancer.size() + " notifications en échec");

                for (Notification notification : notificationsARelancer) {
                        try {
                                // Pour une implémentation complète, il faudrait récupérer l'email du
                                // destinataire
                                // En attendant, on simule la relance en marquant simplement les tentatives

                                notification.setTentativesEnvoi(notification.getTentativesEnvoi() + 1);

                                // Si c'était la dernière tentative, on peut éventuellement marquer comme
                                // définitivement échoué
                                if (notification.getTentativesEnvoi() >= 3) {
                                        logActionService.logSystemAction("EMAIL_ABANDON",
                                                        "Abandon notification ID: " + notification.getId()
                                                                        + " après 3 tentatives");
                                } else {
                                        logActionService.logSystemAction("EMAIL_TENTATIVE_RELANCE",
                                                        "Tentative " + notification.getTentativesEnvoi()
                                                                        + " pour notification ID: "
                                                                        + notification.getId());
                                }

                                notificationRepository.save(notification);

                        } catch (Exception e) {
                                logActionService.logSystemAction("EMAIL_RELANCE_ERREUR",
                                                "Erreur relance notification ID: " + notification.getId() + " - "
                                                                + e.getMessage());
                        }
                }

                logActionService.logSystemAction("RELANCE_NOTIFICATIONS_TERMINE",
                                "Fin de relance pour " + notificationsARelancer.size() + " notifications");
        }
}
