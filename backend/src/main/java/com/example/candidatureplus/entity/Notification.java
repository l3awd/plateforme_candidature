package com.example.candidatureplus.entity;

import jakarta.persistence.*;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;
import java.time.LocalDateTime;

@Entity
@Table(name = "Notification")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Notification {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;
    
    @Enumerated(EnumType.STRING)
    @Column(name = "type_destinataire", nullable = false)
    private TypeDestinataire typeDestinataire;
    
    @Column(name = "destinataire_id", nullable = false)
    private Integer destinataireId;
    
    @Enumerated(EnumType.STRING)
    @Column(name = "type_notification", nullable = false)
    private TypeNotification typeNotification;
    
    @Column(length = 200)
    private String sujet;
    
    @Column(nullable = false, columnDefinition = "TEXT")
    private String message;
    
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private Etat etat = Etat.En_Attente;
    
    @Column(name = "date_creation", nullable = false)
    private LocalDateTime dateCreation = LocalDateTime.now();
    
    @Column(name = "date_envoi")
    private LocalDateTime dateEnvoi;
    
    @Column(name = "tentatives_envoi")
    private Integer tentativesEnvoi = 0;
    
    public enum TypeDestinataire {
        Candidat, Utilisateur
    }
    
    public enum TypeNotification {
        Email, SMS, Systeme
    }
    
    public enum Etat {
        En_Attente, Envoye, Echec
    }
}
