package com.example.candidatureplus.service;

import com.example.candidatureplus.dto.StatistiquesDto;
import com.example.candidatureplus.repository.CandidatureRepository;
import com.example.candidatureplus.repository.ConcoursRepository;
import com.example.candidatureplus.repository.CentreRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class StatistiquesService {

    private final CandidatureRepository candidatureRepository;
    private final ConcoursRepository concoursRepository;
    private final CentreRepository centreRepository;

    public StatistiquesDto getStatistiquesGenerales() {
        long total = candidatureRepository.count();

        // Pour le moment, on simule les statistiques
        // Dans une vraie implémentation, on ferait des requêtes SQL spécifiques

        return StatistiquesDto.builder()
                .totalCandidatures(total)
                .acceptees(total / 4)
                .refusees(total / 6)
                .enAttente(total / 2)
                .enCours(total / 8)
                .parStatut(List.of(
                        StatistiquesDto.StatutCount.builder().name("En attente").value(total / 2).build(),
                        StatistiquesDto.StatutCount.builder().name("Acceptées").value(total / 4).build(),
                        StatistiquesDto.StatutCount.builder().name("Refusées").value(total / 6).build(),
                        StatistiquesDto.StatutCount.builder().name("En cours").value(total / 8).build()))
                .parConcours(List.of(
                        StatistiquesDto.ConcoursCount.builder().nom("Concours A").candidatures(total / 3).build(),
                        StatistiquesDto.ConcoursCount.builder().nom("Concours B").candidatures(total / 4).build()))
                .centresPopulaires(List.of(
                        StatistiquesDto.CentrePopulaire.builder()
                                .nom("Centre Rabat").ville("Rabat").candidatures(total / 3).capacite(100).build(),
                        StatistiquesDto.CentrePopulaire.builder()
                                .nom("Centre Casablanca").ville("Casablanca").candidatures(total / 4).capacite(150)
                                .build()))
                .build();
    }

    public List<StatistiquesDto.StatutCount> getStatistiquesParStatut() {
        long total = candidatureRepository.count();
        return List.of(
                StatistiquesDto.StatutCount.builder().name("En attente").value(total / 2).build(),
                StatistiquesDto.StatutCount.builder().name("Acceptées").value(total / 4).build(),
                StatistiquesDto.StatutCount.builder().name("Refusées").value(total / 6).build(),
                StatistiquesDto.StatutCount.builder().name("En cours").value(total / 8).build());
    }

    public List<StatistiquesDto.ConcoursCount> getStatistiquesParConcours() {
        long total = candidatureRepository.count();
        return List.of(
                StatistiquesDto.ConcoursCount.builder().nom("Concours A").candidatures(total / 3).build(),
                StatistiquesDto.ConcoursCount.builder().nom("Concours B").candidatures(total / 4).build(),
                StatistiquesDto.ConcoursCount.builder().nom("Concours C").candidatures(total / 5).build());
    }

    public List<StatistiquesDto.CentrePopulaire> getCentresPopulaires() {
        long total = candidatureRepository.count();
        return List.of(
                StatistiquesDto.CentrePopulaire.builder()
                        .nom("Centre Rabat").ville("Rabat").candidatures(total / 3).capacite(100).build(),
                StatistiquesDto.CentrePopulaire.builder()
                        .nom("Centre Casablanca").ville("Casablanca").candidatures(total / 4).capacite(150).build(),
                StatistiquesDto.CentrePopulaire.builder()
                        .nom("Centre Fès").ville("Fès").candidatures(total / 5).capacite(80).build());
    }
}
