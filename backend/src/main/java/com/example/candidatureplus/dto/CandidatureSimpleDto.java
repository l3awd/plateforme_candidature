package com.example.candidatureplus.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.time.LocalDate;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class CandidatureSimpleDto {
    private Integer id;
    private String etat;
    private LocalDateTime dateSoumission;

    // Informations candidat
    private String nom;
    private String prenom;
    private String cin;
    private String email;
    private String telephone;
    private String ville;
    private String genre;
    private String lieuNaissance;
    private LocalDate dateNaissance;
    private String diplomePrincipal;
    private String specialiteDiplome;
    private String etablissement;
    private String anneeObtention;

    // Informations concours
    private Integer concoursId;
    private String concoursNom;
    private Integer specialiteId;
    private String specialiteNom;
    private Integer centreId;
    private String centreNom;
    private String centreVille;

    // CV
    private boolean cvFichier;
    private String cvType;
    private Long cvTailleOctets;

    // Pour l'interface
    private String numeroUnique;
    private String statut; // Alias pour etat
    private LocalDateTime dateCreation; // Alias pour dateSoumission
}
