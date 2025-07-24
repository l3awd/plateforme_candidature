package com.example.candidatureplus.entity;

import jakarta.persistence.*;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Entity
@Table(name = "Concours")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Concours {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;
    
    @Column(nullable = false, length = 100)
    private String nom;
    
    @Column(columnDefinition = "TEXT")
    private String description;
    
    @Column(name = "date_debut_candidature", nullable = false)
    private LocalDate dateDebutCandidature;
    
    @Column(name = "date_fin_candidature", nullable = false)
    private LocalDate dateFinCandidature;
    
    @Column(name = "date_examen")
    private LocalDate dateExamen;
    
    @Column(name = "conditions_participation", columnDefinition = "TEXT")
    private String conditionsParticipation;
    
    @Column(name = "documents_requis", columnDefinition = "TEXT")
    private String documentsRequis;
    
    @Column(nullable = false)
    private Boolean actif = true;
    
    @Column(name = "date_creation", nullable = false)
    private LocalDateTime dateCreation = LocalDateTime.now();
    
    // Note: Relation bidirectionnelle commentée pour éviter les références circulaires
    // Utiliser CandidatureRepository.findByConcours_Id(concoursId) pour récupérer les candidatures
    // @OneToMany(mappedBy = "concours", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    // private List<Candidature> candidatures;
}
