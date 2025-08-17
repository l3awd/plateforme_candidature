package com.example.candidatureplus.service;

import com.example.candidatureplus.entity.Centre;
import com.example.candidatureplus.entity.Utilisateur;
import com.example.candidatureplus.entity.UtilisateurCentre;
import com.example.candidatureplus.repository.CentreRepository;
import com.example.candidatureplus.repository.UtilisateurCentreRepository;
import com.example.candidatureplus.repository.UtilisateurRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
public class UtilisateurCentreService {

    private final UtilisateurCentreRepository utilisateurCentreRepository;
    private final UtilisateurRepository utilisateurRepository;
    private final CentreRepository centreRepository;

    public UtilisateurCentreService(UtilisateurCentreRepository utilisateurCentreRepository,
            UtilisateurRepository utilisateurRepository,
            CentreRepository centreRepository) {
        this.utilisateurCentreRepository = utilisateurCentreRepository;
        this.utilisateurRepository = utilisateurRepository;
        this.centreRepository = centreRepository;
    }

    @Transactional
    public void ajouterRattachement(Integer utilisateurId, Integer centreId) {
        Utilisateur user = utilisateurRepository.findById(utilisateurId)
                .orElseThrow(() -> new RuntimeException("Utilisateur introuvable"));
        Centre centre = centreRepository.findById(centreId)
                .orElseThrow(() -> new RuntimeException("Centre introuvable"));
        utilisateurCentreRepository.findByUtilisateurIdAndCentreId(utilisateurId, centreId)
                .ifPresentOrElse(uc -> {
                    if (!uc.getActif()) {
                        uc.setActif(true);
                        utilisateurCentreRepository.save(uc);
                    }
                },
                        () -> utilisateurCentreRepository.save(UtilisateurCentre.builder()
                                .utilisateur(user).centre(centre).actif(true).build()));
    }

    @Transactional
    public void retirerRattachement(Integer utilisateurId, Integer centreId) {
        utilisateurCentreRepository.findByUtilisateurIdAndCentreId(utilisateurId, centreId)
                .ifPresent(uc -> {
                    uc.setActif(false);
                    utilisateurCentreRepository.save(uc);
                });
    }

    public List<Integer> centresIdsActifs(Integer utilisateurId) {
        return utilisateurCentreRepository.findByUtilisateurIdAndActifTrue(utilisateurId)
                .stream().map(uc -> uc.getCentre().getId()).collect(Collectors.toList());
    }

    public List<Centre> centresActifs(Integer utilisateurId) {
        return utilisateurCentreRepository.findCentresActifsByUtilisateur(utilisateurId);
    }
}
