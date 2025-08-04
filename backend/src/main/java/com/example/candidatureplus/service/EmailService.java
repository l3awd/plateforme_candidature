package com.example.candidatureplus.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.MimeMessageHelper;
import org.springframework.stereotype.Service;

import com.example.candidatureplus.entity.Candidature;
import com.example.candidatureplus.entity.Candidat;

import jakarta.mail.MessagingException;
import jakarta.mail.internet.MimeMessage;
import java.time.format.DateTimeFormatter;

@Service
public class EmailService {

    @Autowired
    private JavaMailSender mailSender;

    @Value("${spring.mail.username:noreply@candidature.com}")
    private String fromEmail;

    public void sendCandidatureConfirmation(Candidat candidat, Candidature candidature) {
        try {
            MimeMessage mimeMessage = mailSender.createMimeMessage();
            MimeMessageHelper helper = new MimeMessageHelper(mimeMessage, true, "UTF-8");

            helper.setFrom(fromEmail);
            helper.setTo(candidat.getEmail());
            helper.setSubject("Confirmation de votre candidature");

            String htmlContent = buildConfirmationEmail(candidat, candidature);
            helper.setText(htmlContent, true);

            mailSender.send(mimeMessage);
        } catch (MessagingException e) {
            throw new RuntimeException("Erreur lors de l'envoi de l'email de confirmation", e);
        }
    }

    public void sendStatusUpdateNotification(Candidat candidat, Candidature candidature, String previousStatus) {
        try {
            MimeMessage mimeMessage = mailSender.createMimeMessage();
            MimeMessageHelper helper = new MimeMessageHelper(mimeMessage, true, "UTF-8");

            helper.setFrom(fromEmail);
            helper.setTo(candidat.getEmail());
            helper.setSubject("Mise à jour de votre candidature");

            String htmlContent = buildStatusUpdateEmail(candidat, candidature, previousStatus);
            helper.setText(htmlContent, true);

            mailSender.send(mimeMessage);
        } catch (MessagingException e) {
            throw new RuntimeException("Erreur lors de l'envoi de l'email de mise à jour", e);
        }
    }

    private String buildConfirmationEmail(Candidat candidat, Candidature candidature) {
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("dd/MM/yyyy à HH:mm");

        return "<!DOCTYPE html>" +
                "<html>" +
                "<head>" +
                "<style>" +
                "body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }" +
                ".container { max-width: 600px; margin: 0 auto; padding: 20px; }" +
                ".header { background-color: #1976d2; color: white; padding: 20px; text-align: center; }" +
                ".content { padding: 20px; background-color: #f9f9f9; }" +
                ".info-box { background-color: white; padding: 15px; margin: 10px 0; border-left: 4px solid #1976d2; }"
                +
                ".footer { text-align: center; padding: 20px; color: #666; font-size: 12px; }" +
                "</style>" +
                "</head>" +
                "<body>" +
                "<div class='container'>" +
                "<div class='header'>" +
                "<h1>Confirmation de candidature</h1>" +
                "</div>" +
                "<div class='content'>" +
                "<p>Bonjour <strong>" + candidat.getPrenom() + " " + candidat.getNom() + "</strong>,</p>" +
                "<p>Nous avons bien reçu votre candidature. Voici les détails :</p>" +
                "<div class='info-box'>" +
                "<p><strong>Numéro de candidature :</strong> " + candidature.getId() + "</p>" +
                "<p><strong>Concours :</strong> " + candidature.getConcours().getNom() + "</p>" +
                "<p><strong>Date de soumission :</strong> " + candidature.getDateSoumission().format(formatter) + "</p>"
                +
                "<p><strong>Statut :</strong> " + candidature.getEtat() + "</p>" +
                "</div>" +
                "<p>Votre candidature est actuellement en cours de traitement. Vous recevrez une notification par email à chaque mise à jour de statut.</p>"
                +
                "<p>Vous pouvez suivre l'évolution de votre candidature en vous connectant à votre espace candidat.</p>"
                +
                "</div>" +
                "<div class='footer'>" +
                "<p>Ceci est un email automatique, merci de ne pas y répondre.</p>" +
                "<p>© 2024 Plateforme de Candidature - Tous droits réservés</p>" +
                "</div>" +
                "</div>" +
                "</body>" +
                "</html>";
    }

    private String buildStatusUpdateEmail(Candidat candidat, Candidature candidature, String previousStatus) {
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("dd/MM/yyyy à HH:mm");

        return "<!DOCTYPE html>" +
                "<html>" +
                "<head>" +
                "<style>" +
                "body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }" +
                ".container { max-width: 600px; margin: 0 auto; padding: 20px; }" +
                ".header { background-color: #1976d2; color: white; padding: 20px; text-align: center; }" +
                ".content { padding: 20px; background-color: #f9f9f9; }" +
                ".status-box { background-color: white; padding: 15px; margin: 10px 0; border-left: 4px solid #4caf50; }"
                +
                ".footer { text-align: center; padding: 20px; color: #666; font-size: 12px; }" +
                "</style>" +
                "</head>" +
                "<body>" +
                "<div class='container'>" +
                "<div class='header'>" +
                "<h1>Mise à jour de votre candidature</h1>" +
                "</div>" +
                "<div class='content'>" +
                "<p>Bonjour <strong>" + candidat.getPrenom() + " " + candidat.getNom() + "</strong>,</p>" +
                "<p>Le statut de votre candidature a été mis à jour :</p>" +
                "<div class='status-box'>" +
                "<p><strong>Numéro de candidature :</strong> " + candidature.getId() + "</p>" +
                "<p><strong>Concours :</strong> " + candidature.getConcours().getNom() + "</p>" +
                "<p><strong>Ancien statut :</strong> " + previousStatus + "</p>" +
                "<p><strong>Nouveau statut :</strong> " + candidature.getEtat() + "</p>" +
                "<p><strong>Date de mise à jour :</strong> " + candidature.getDateTraitement().format(formatter)
                + "</p>" +
                "</div>" +
                "<p>Connectez-vous à votre espace candidat pour plus de détails.</p>" +
                "</div>" +
                "<div class='footer'>" +
                "<p>Ceci est un email automatique, merci de ne pas y répondre.</p>" +
                "<p>© 2024 Plateforme de Candidature - Tous droits réservés</p>" +
                "</div>" +
                "</div>" +
                "</body>" +
                "</html>";
    }
}
