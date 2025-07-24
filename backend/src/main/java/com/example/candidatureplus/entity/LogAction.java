package com.example.candidatureplus.entity;

import jakarta.persistence.*;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;
import java.time.LocalDateTime;

@Entity
@Table(name = "Log_Action")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class LogAction {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;
    
    @Enumerated(EnumType.STRING)
    @Column(name = "type_acteur", nullable = false)
    private TypeActeur typeActeur;
    
    @Column(name = "acteur_id")
    private Integer acteurId;
    
    @Column(nullable = false, length = 100)
    private String action;
    
    @Column(name = "table_cible", length = 50)
    private String tableCible;
    
    @Column(name = "enregistrement_id")
    private Long enregistrementId;
    
    @Column(columnDefinition = "JSON")
    private String details;
    
    @Column(name = "ip_adresse", length = 45)
    private String ipAdresse;
    
    @Column(name = "user_agent", columnDefinition = "TEXT")
    private String userAgent;
    
    @Column(name = "date_action", nullable = false)
    private LocalDateTime dateAction = LocalDateTime.now();
    
    public enum TypeActeur {
        Candidat, Utilisateur, Systeme
    }
}
