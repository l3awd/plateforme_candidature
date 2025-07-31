package com.example.candidatureplus.dto;

import com.example.candidatureplus.entity.Candidat.Genre;
import lombok.Data;
import java.time.LocalDate;

@Data
public class CandidatureRequest {
    private CandidatData candidat;
    private Integer concoursId;
    private Integer specialiteId;
    private Integer centreId;

    @Data
    public static class CandidatData {
        // Informations personnelles
        private String nom;
        private String prenom;
        private Genre genre;
        private String cin;
        private LocalDate dateNaissance;
        private String lieuNaissance;
        private String ville;
        private String email;
        private String telephone;
        private String telephoneUrgence;

        // Formation
        private String niveauEtudes;
        private String diplomePrincipal;
        private String specialiteDiplome;
        private String etablissement;
        private Integer anneeObtention;
        private String experienceProfessionnelle;
        private Boolean conditionsAcceptees;
    }
}
