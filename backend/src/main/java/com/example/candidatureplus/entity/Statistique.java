package com.example.candidatureplus.entity;

import jakarta.persistence.*;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;
import java.time.LocalDateTime;

@Entity
@Table(name = "Statistique")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Statistique {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;
    
    @Column(name = "type_statistique", nullable = false, length = 100)
    private String typeStatistique;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "concours_id")
    private Concours concours;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "specialite_id")
    private Specialite specialite;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "centre_id")
    private Centre centre;
    
    @Column(nullable = false)
    private Integer valeur;
    
    @Column(columnDefinition = "JSON")
    private String details;
    
    @Column(name = "date_calcul", nullable = false)
    private LocalDateTime dateCalcul = LocalDateTime.now();
}
