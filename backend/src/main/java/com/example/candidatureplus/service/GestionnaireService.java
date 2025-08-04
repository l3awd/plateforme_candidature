package com.example.candidatureplus.service;

import com.example.candidatureplus.dto.CandidatureSimpleDto;
import com.example.candidatureplus.entity.Candidature;
import com.example.candidatureplus.repository.CandidatureRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class GestionnaireService {

    private final CandidatureRepository candidatureRepository;

    public Page<CandidatureSimpleDto> getAllCandidatures(Pageable pageable) {
        Page<Candidature> candidatures = candidatureRepository.findAll(pageable);
        return candidatures.map(this::convertToSimpleDto);
    }

    public List<CandidatureSimpleDto> getCandidaturesByFilters(
            Long concoursId, Long specialiteId, Long centreId, String statut) {

        List<Candidature> candidatures;

        if (concoursId != null || specialiteId != null || centreId != null || statut != null) {
            candidatures = candidatureRepository.findWithFilters(concoursId, specialiteId, centreId, statut);
        } else {
            candidatures = candidatureRepository.findAll();
        }

        return candidatures.stream()
                .map(this::convertToSimpleDto)
                .toList();
    }

    public Optional<CandidatureSimpleDto> getCandidatureDetails(Integer candidatureId) {
        return candidatureRepository.findById(candidatureId)
                .map(this::convertToSimpleDto);
    }

    public byte[] getCandidatureCV(Integer candidatureId) {
        return candidatureRepository.findById(candidatureId)
                .map(candidature -> {
                    // Ici nous devrions lire le fichier depuis le système de fichiers
                    // Pour l'instant retournons null si pas de CV
                    return candidature.getCvFichier() != null ? new byte[0] : null;
                })
                .orElse(null);
    }

    public String getCandidatureCVType(Integer candidatureId) {
        return candidatureRepository.findById(candidatureId)
                .map(Candidature::getCvType)
                .orElse("application/pdf");
    }

    public boolean updateCandidatureStatut(Integer candidatureId, String nouveauStatut) {
        Optional<Candidature> optionalCandidature = candidatureRepository.findById(candidatureId);
        if (optionalCandidature.isPresent()) {
            Candidature candidature = optionalCandidature.get();
            // Convertir le statut string en enum si nécessaire
            try {
                Candidature.Etat etat = Candidature.Etat.valueOf(nouveauStatut);
                candidature.setEtat(etat);
                candidatureRepository.save(candidature);
                return true;
            } catch (IllegalArgumentException e) {
                return false;
            }
        }
        return false;
    }

    private CandidatureSimpleDto convertToSimpleDto(Candidature candidature) {
        return CandidatureSimpleDto.builder()
                .id(candidature.getId())
                .etat(candidature.getEtat().name())
                .dateSoumission(candidature.getDateSoumission())
                .nom(candidature.getCandidat().getNom())
                .prenom(candidature.getCandidat().getPrenom())
                .cin(candidature.getCandidat().getCin())
                .email(candidature.getCandidat().getEmail())
                .telephone(candidature.getCandidat().getTelephone())
                .ville(candidature.getCandidat().getVille())
                .genre(candidature.getCandidat().getGenre().name())
                .lieuNaissance(candidature.getCandidat().getLieuNaissance())
                .dateNaissance(candidature.getCandidat().getDateNaissance())
                .diplomePrincipal(candidature.getCandidat().getDiplomePrincipal())
                .specialiteDiplome(candidature.getCandidat().getSpecialiteDiplome())
                .etablissement(candidature.getCandidat().getEtablissement())
                .anneeObtention(candidature.getCandidat().getAnneeObtention().toString())
                .concoursId(candidature.getConcours().getId())
                .concoursNom(candidature.getConcours().getNom())
                .specialiteId(candidature.getSpecialite().getId())
                .specialiteNom(candidature.getSpecialite().getNom())
                .centreId(candidature.getCentre().getId())
                .centreNom(candidature.getCentre().getNom())
                .centreVille(candidature.getCentre().getVille())
                .cvFichier(candidature.getCvFichier() != null)
                .cvType(candidature.getCvType())
                .cvTailleOctets(candidature.getCvTailleOctets())
                // Aliases pour compatibilité frontend
                .numeroUnique("CAND-" + candidature.getId())
                .statut(candidature.getEtat().name())
                .dateCreation(candidature.getDateSoumission())
                .build();
    }
}
