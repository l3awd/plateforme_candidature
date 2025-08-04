package com.example.candidatureplus.dto;

import lombok.Data;
import lombok.Builder;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;
import java.time.LocalDate;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class CandidatDto {
    private Integer id;
    private String numeroUnique;
    private String nom;
    private String prenom;
    private String genre;
    private String cin;
    private LocalDate dateNaissance;
    private String lieuNaissance;
    private String ville;
    private String email;
    private String telephone;
    private String telephoneUrgence;
    private String diplome;
    private String specialiteDiplome;
    private String etablissement;
    private Integer anneeObtention;
}
