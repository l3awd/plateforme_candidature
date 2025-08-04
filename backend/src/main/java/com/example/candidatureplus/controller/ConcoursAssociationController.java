package com.example.candidatureplus.controller;

import com.example.candidatureplus.entity.*;
import com.example.candidatureplus.repository.*;
import com.example.candidatureplus.dto.SpecialiteDto;
import com.example.candidatureplus.dto.CentreDto;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/concours")
@CrossOrigin(origins = "http://localhost:3000")
public class ConcoursAssociationController {

    @Autowired
    private ConcoursRepository concoursRepository;

    @Autowired
    private SpecialiteRepository specialiteRepository;

    @Autowired
    private CentreRepository centreRepository;

    @GetMapping("/{concoursId}/specialites")
    public ResponseEntity<List<SpecialiteDto>> getSpecialitesByConcours(@PathVariable Integer concoursId) {
        try {
            // Pour l'instant, retourner toutes les spécialités actives
            // TODO: Implémenter les associations via ConcourSpecialite
            List<Specialite> specialites = specialiteRepository.findByActifTrue();

            List<SpecialiteDto> specialiteDtos = specialites.stream()
                    .map(this::convertToSpecialiteDto)
                    .collect(Collectors.toList());

            return ResponseEntity.ok(specialiteDtos);
        } catch (Exception e) {
            return ResponseEntity.badRequest().build();
        }
    }

    @GetMapping("/{concoursId}/centres")
    public ResponseEntity<List<CentreDto>> getCentresByConcours(@PathVariable Integer concoursId) {
        try {
            // Pour l'instant, retourner tous les centres actifs
            // TODO: Implémenter les associations via ConcoursCentre
            List<Centre> centres = centreRepository.findByActifTrue();

            List<CentreDto> centreDtos = centres.stream()
                    .map(this::convertToCentreDto)
                    .collect(Collectors.toList());

            return ResponseEntity.ok(centreDtos);
        } catch (Exception e) {
            return ResponseEntity.badRequest().build();
        }
    }

    private SpecialiteDto convertToSpecialiteDto(Specialite specialite) {
        return SpecialiteDto.builder()
                .id(specialite.getId())
                .nom(specialite.getNom())
                .domaine(specialite.getDomaine())
                .description(specialite.getDescription())
                .actif(specialite.getActif())
                .build();
    }

    private CentreDto convertToCentreDto(Centre centre) {
        return CentreDto.builder()
                .id(centre.getId())
                .nom(centre.getNom())
                .ville(centre.getVille())
                .adresse(centre.getAdresse())
                .telephone(centre.getTelephone())
                .email(centre.getEmail())
                .actif(centre.getActif())
                .build();
    }
}
