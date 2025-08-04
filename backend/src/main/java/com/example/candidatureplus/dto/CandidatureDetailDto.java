package com.example.candidatureplus.dto;

import lombok.Data;
import lombok.AllArgsConstructor;
import lombok.NoArgsConstructor;
import lombok.Builder;
import java.time.LocalDateTime;
import java.time.LocalDate;

@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class CandidatureDetailDto {

    // Informations de la candidature
    private Integer id;
    private String etat;
    private LocalDateTime dateSoumission;
    private LocalDateTime dateTraitement;
    private String motifRejet;
    private String commentaireGestionnaire;
    private Integer numeroPlace;

    // Informations du candidat
    private Integer candidatId;
    private String candidatNumeroUnique;
    private String candidatNom;
    private String candidatPrenom;
    private String candidatEmail;
    private String candidatTelephone;
    private String candidatCin;
    private LocalDate candidatDateNaissance;
    private String candidatLieuNaissance;
    private String candidatVille;
    private String candidatGenre;
    private String candidatNationalite;
    private String candidatSituationFamiliale;

    // Informations professionnelles du candidat
    private String candidatProfession;
    private String candidatEmployeur;
    private String candidatExperienceProfessionnelle;

    // Informations académiques du candidat
    private String candidatNiveauEtudes;
    private String candidatDiplome;
    private String candidatEtablissement;
    private String candidatAnneeObtention;
    private String candidatMention;

    // Informations du concours
    private Integer concoursId;
    private String concoursNom;
    private String concoursDescription;
    private LocalDate concoursDateLimite;
    private String concoursStatut;

    // Informations de la spécialité
    private Integer specialiteId;
    private String specialiteNom;
    private String specialiteDescription;

    // Informations du centre
    private Integer centreId;
    private String centreNom;
    private String centreVille;
    private String centreAdresse;

    // Informations du gestionnaire
    private Integer gestionnaireId;
    private String gestionnaireNom;
    private String gestionnairePrenom;

    // Documents associés
    private Integer nombreDocuments;
    private boolean cvUploaded;
    private boolean diplomeUploaded;
    private boolean photoUploaded;
}
