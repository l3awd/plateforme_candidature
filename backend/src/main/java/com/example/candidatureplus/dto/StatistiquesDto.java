package com.example.candidatureplus.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class StatistiquesDto {
    private long totalCandidatures;
    private long acceptees;
    private long refusees;
    private long enAttente;
    private long enCours;

    // Statistiques par statut pour les graphiques
    private List<StatutCount> parStatut;

    // Statistiques par concours
    private List<ConcoursCount> parConcours;

    // Centres les plus demandés
    private List<CentrePopulaire> centresPopulaires;

    // Statistiques par spécialité
    private List<SpecialiteCount> parSpecialite;

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class StatutCount {
        private String name;
        private long value;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class ConcoursCount {
        private String nom;
        private long candidatures;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class CentrePopulaire {
        private String nom;
        private String ville;
        private long candidatures;
        private long capacite;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class SpecialiteCount {
        private String nom;
        private long candidatures;
    }
}
