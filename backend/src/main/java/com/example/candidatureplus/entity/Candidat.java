package com.example.candidatureplus.entity;

import jakarta.persistence.*;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

@Entity
@Table(name = "Candidat")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Candidat {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;
    
    @Column(name = "numero_unique", nullable = false, unique = true, length = 50)
    private String numeroUnique;
    
    // Informations personnelles
    @Column(nullable = false, length = 100)
    private String nom;
    
    @Column(nullable = false, length = 100)
    private String prenom;
    
    @Column(nullable = false, unique = true, length = 20)
    private String cin;
    
    @Column(name = "date_naissance", nullable = false)
    private LocalDate dateNaissance;
    
    @Column(name = "lieu_naissance", nullable = false, length = 100)
    private String lieuNaissance;
    
    @Column(nullable = false, columnDefinition = "TEXT")
    private String adresse;
    
    @Column(nullable = false, length = 100)
    private String ville;
    
    @Column(name = "code_postal", length = 10)
    private String codePostal;
    
    // Coordonnées
    @Column(nullable = false, length = 150)
    private String email;
    
    @Column(nullable = false, length = 20)
    private String telephone;
    
    @Column(name = "telephone_urgence", length = 20)
    private String telephoneUrgence;
    
    // Formation
    @Column(name = "niveau_etudes", nullable = false, length = 100)
    private String niveauEtudes;
    
    @Column(name = "diplome_principal", nullable = false, length = 200)
    private String diplomePrincipal;
    
    @Column(name = "specialite_diplome", nullable = false, length = 200)
    private String specialiteDiplome;
    
    @Column(length = 200)
    private String etablissement;
    
    @Column(name = "annee_obtention", columnDefinition = "INT")
    private Integer anneeObtention;
    
    // Expérience professionnelle
    @Column(name = "experience_professionnelle", columnDefinition = "TEXT")
    private String experienceProfessionnelle;
    
    // Métadonnées
    @Column(name = "conditions_acceptees", nullable = false)
    private Boolean conditionsAcceptees = false;
    
    @Column(name = "date_creation", nullable = false)
    private LocalDateTime dateCreation = LocalDateTime.now();
    
    @Column(name = "ip_creation", length = 45)
    private String ipCreation;
    
    @OneToMany(mappedBy = "candidat", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    private List<Candidature> candidatures;
}
