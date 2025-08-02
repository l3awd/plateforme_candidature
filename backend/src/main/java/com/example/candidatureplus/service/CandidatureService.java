package com.example.candidatureplus.service;

import com.example.candidatureplus.entity.*;
import com.example.candidatureplus.repository.*;
import com.example.candidatureplus.dto.ValidationRequest;
import com.example.candidatureplus.dto.ValidationResponse;
import com.example.candidatureplus.dto.RejetRequest;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.*;
import java.util.stream.Collectors;

@Service
@Transactional
public class CandidatureService {

    @Autowired
    private CandidatureRepository candidatureRepository;

    @Autowired
    private DocumentRepository documentRepository;

    @Autowired
    private CentreSpecialiteRepository centreSpecialiteRepository;

    @Autowired
    private LogActionService logActionService;

    @Autowired
    private NotificationService notificationService;

    /**
     * Récupère les candidatures par centre et état
     */
    public List<Candidature> getCandidaturesByCentreAndEtat(Integer centreId, Candidature.Etat etat) {
        return candidatureRepository.findByCentreIdAndEtat(centreId, etat);
    }

    /**
     * Valide une candidature après vérification des documents
     */
    public void validerCandidature(Integer candidatureId, Integer gestionnaireId) {
        // Récupérer la candidature
        Candidature candidature = candidatureRepository.findById(candidatureId)
                .orElseThrow(() -> new RuntimeException("Candidature non trouvée"));

        // Vérifier les documents
        List<Document> documents = documentRepository.findByCandidature_Id(candidatureId);
        if (!verifierDocumentsComplets(documents)) {
            throw new RuntimeException("Documents incomplets ou non conformes");
        }

        // Réserver une place
        Integer numeroPlace = reserverPlace(candidature.getCentre().getId(),
                candidature.getSpecialite().getId(),
                candidature.getConcours().getId());

        // Mettre à jour la candidature
        candidature.setEtat(Candidature.Etat.Validee);
        candidature.setDateTraitement(LocalDateTime.now());
        candidature.setNumeroPlace(numeroPlace);

        // Associer le gestionnaire qui a validé
        if (gestionnaireId != null) {
            candidature.setGestionnaire(new Utilisateur());
            candidature.getGestionnaire().setId(gestionnaireId);
        }

        candidatureRepository.save(candidature);

        // Logger l'action
        logActionService.logAction(LogAction.TypeActeur.Utilisateur, gestionnaireId,
                "VALIDATION_CANDIDATURE", "Candidature", candidatureId.longValue());

        // Envoyer notification
        notificationService.envoyerNotificationValidation(candidature, numeroPlace);
    }

    /**
     * Rejette une candidature avec motif
     */
    public void rejeterCandidature(Integer candidatureId, String motif, Integer gestionnaireId) {
        // Récupérer la candidature
        Candidature candidature = candidatureRepository.findById(candidatureId)
                .orElseThrow(() -> new RuntimeException("Candidature non trouvée"));

        // Mettre à jour la candidature
        candidature.setEtat(Candidature.Etat.Rejetee);
        candidature.setMotifRejet(motif);
        candidature.setDateTraitement(LocalDateTime.now());

        // Associer le gestionnaire qui a rejeté
        if (gestionnaireId != null) {
            candidature.setGestionnaire(new Utilisateur());
            candidature.getGestionnaire().setId(gestionnaireId);
        }

        candidatureRepository.save(candidature);

        // Logger l'action
        logActionService.logAction(LogAction.TypeActeur.Utilisateur, gestionnaireId,
                "REJET_CANDIDATURE", "Candidature", candidatureId.longValue());

        // Envoyer notification
        notificationService.envoyerNotificationRejet(candidature, motif);
    }

    /**
     * Vérifie si tous les documents requis sont présents et valides
     */
    private boolean verifierDocumentsComplets(List<Document> documents) {
        // Documents requis : CIN, CV, Diplome
        boolean cinPresent = documents.stream()
                .anyMatch(doc -> doc.getTypeDocument() == Document.TypeDocument.CIN);
        boolean cvPresent = documents.stream()
                .anyMatch(doc -> doc.getTypeDocument() == Document.TypeDocument.CV);
        boolean diplomePresent = documents.stream()
                .anyMatch(doc -> doc.getTypeDocument() == Document.TypeDocument.Diplome);

        return cinPresent && cvPresent && diplomePresent;
    }

    /**
     * Réserve une place dans un centre pour une spécialité
     */
    private Integer reserverPlace(Integer centreId, Integer specialiteId, Integer concoursId) {
        Optional<CentreSpecialite> centreSpecialiteOpt = centreSpecialiteRepository
                .findByCentreIdAndSpecialiteIdAndConcoursId(
                        centreId, specialiteId, concoursId);

        if (centreSpecialiteOpt.isPresent()) {
            CentreSpecialite centreSpecialite = centreSpecialiteOpt.get();

            if (centreSpecialite.getNombrePlacesDisponibles() > 0) {
                // Décrémenter le nombre de places disponibles
                centreSpecialite.setNombrePlacesDisponibles(
                        centreSpecialite.getNombrePlacesDisponibles() - 1);
                centreSpecialiteRepository.save(centreSpecialite);

                // Générer un numéro de place (simple séquence)
                return generateNumeroPlace(centreId, specialiteId);
            } else {
                throw new RuntimeException("Plus de places disponibles pour cette spécialité");
            }
        } else {
            throw new RuntimeException("Configuration centre/spécialité non trouvée");
        }
    }

    /**
     * Génère un numéro de place unique
     */
    private Integer generateNumeroPlace(Integer centreId, Integer specialiteId) {
        // Compter les candidatures validées pour cette combinaison centre/spécialité
        List<Candidature> candidaturesValidees = candidatureRepository
                .findByCentreIdAndSpecialiteIdAndEtat(centreId, specialiteId, Candidature.Etat.Validee);

        return candidaturesValidees.size() + 1; // Simple incrémentation
    }

    /**
     * Libère une place (en cas d'annulation ou de rejet après validation)
     */
    public void libererPlace(Integer centreId, Integer specialiteId, Integer concoursId) {
        Optional<CentreSpecialite> centreSpecialiteOpt = centreSpecialiteRepository
                .findByCentreIdAndSpecialiteIdAndConcoursId(
                        centreId, specialiteId, concoursId);

        if (centreSpecialiteOpt.isPresent()) {
            CentreSpecialite centreSpecialite = centreSpecialiteOpt.get();
            centreSpecialite.setNombrePlacesDisponibles(
                    centreSpecialite.getNombrePlacesDisponibles() + 1);
            centreSpecialiteRepository.save(centreSpecialite);
        }
    }

    /**
     * Récupère les candidatures en attente pour un centre
     */
    public List<Candidature> getCandidaturesEnAttente(Integer centreId) {
        return candidatureRepository.findByCentreIdAndEtat(centreId, Candidature.Etat.Soumise);
    }

    /**
     * Récupère les candidatures en cours de validation pour un centre
     */
    public List<Candidature> getCandidaturesEnCours(Integer centreId) {
        return candidatureRepository.findByCentreIdAndEtat(centreId, Candidature.Etat.En_Cours_Validation);
    }

    /**
     * Marque une candidature comme en cours de validation
     */
    public void marquerEnCoursValidation(Integer candidatureId, Integer gestionnaireId) {
        Candidature candidature = candidatureRepository.findById(candidatureId)
                .orElseThrow(() -> new RuntimeException("Candidature non trouvée"));

        candidature.setEtat(Candidature.Etat.En_Cours_Validation);
        candidatureRepository.save(candidature);

        // Logger l'action
        logActionService.logAction(LogAction.TypeActeur.Utilisateur, gestionnaireId,
                "MISE_EN_COURS_VALIDATION", "Candidature", candidatureId.longValue());
    }

    /**
     * Récupère les candidatures par centre avec informations détaillées
     */
    public List<Map<String, Object>> getCandidaturesByCentre(Integer centreId) {
        List<Candidature> candidatures = candidatureRepository.findByCentre_Id(centreId);
        return candidatures.stream().map(this::convertToMap).collect(Collectors.toList());
    }

    /**
     * Valide une candidature avec ValidationRequest
     */
    public ValidationResponse validerCandidature(Integer candidatureId, ValidationRequest request,
            Integer gestionnaireId) {
        try {
            validerCandidature(candidatureId, gestionnaireId);
            Candidature candidature = candidatureRepository.findById(candidatureId).orElse(null);
            Integer numeroPlace = candidature != null ? candidature.getNumeroPlace() : null;
            return ValidationResponse.success(numeroPlace);
        } catch (RuntimeException e) {
            return ValidationResponse.failure(e.getMessage());
        }
    }

    /**
     * Rejette une candidature avec RejetRequest
     */
    public ValidationResponse rejeterCandidature(Integer candidatureId, RejetRequest request, Integer gestionnaireId) {
        try {
            rejeterCandidature(candidatureId, request.getMotif(), gestionnaireId);
            return ValidationResponse.success(null);
        } catch (RuntimeException e) {
            return ValidationResponse.failure(e.getMessage());
        }
    }

    /**
     * Récupère les statistiques globales
     */
    public Map<String, Object> getStatistiquesGlobales() {
        Map<String, Object> stats = new HashMap<>();
        stats.put("total", candidatureRepository.count());
        stats.put("soumises", candidatureRepository.countByEtat(Candidature.Etat.Soumise));
        stats.put("enCours", candidatureRepository.countByEtat(Candidature.Etat.En_Cours_Validation));
        stats.put("validees", candidatureRepository.countByEtat(Candidature.Etat.Validee));
        stats.put("rejetees", candidatureRepository.countByEtat(Candidature.Etat.Rejetee));
        return stats;
    }

    /**
     * Récupère les statistiques d'un centre
     */
    public Map<String, Object> getStatistiquesCentre(Integer centreId) {
        Map<String, Object> stats = new HashMap<>();
        stats.put("total", candidatureRepository.countByCentre_Id(centreId));
        stats.put("soumises", candidatureRepository.countByCentre_IdAndEtat(centreId, Candidature.Etat.Soumise));
        stats.put("enCours",
                candidatureRepository.countByCentre_IdAndEtat(centreId, Candidature.Etat.En_Cours_Validation));
        stats.put("validees", candidatureRepository.countByCentre_IdAndEtat(centreId, Candidature.Etat.Validee));
        stats.put("rejetees", candidatureRepository.countByCentre_IdAndEtat(centreId, Candidature.Etat.Rejetee));
        return stats;
    }

    /**
     * Exporte les candidatures en CSV
     */
    public String exporterCandidaturesCSV(Integer centreId, String statut) {
        StringBuilder csv = new StringBuilder();
        csv.append("Numéro Unique,Nom,Prénom,CIN,Email,Centre,Spécialité,État,Date Soumission\n");

        List<Candidature> candidatures;
        if (centreId != null) {
            candidatures = candidatureRepository.findByCentre_Id(centreId);
        } else {
            candidatures = candidatureRepository.findAll();
        }

        if (statut != null && !statut.isEmpty()) {
            Candidature.Etat etat = Candidature.Etat.valueOf(statut);
            candidatures = candidatures.stream()
                    .filter(c -> c.getEtat() == etat)
                    .collect(Collectors.toList());
        }

        for (Candidature candidature : candidatures) {
            csv.append(String.format("%s,%s,%s,%s,%s,%s,%s,%s,%s\n",
                    candidature.getCandidat().getNumeroUnique(),
                    candidature.getCandidat().getNom(),
                    candidature.getCandidat().getPrenom(),
                    candidature.getCandidat().getCin(),
                    candidature.getCandidat().getEmail(),
                    candidature.getCentre().getNom(),
                    candidature.getSpecialite().getNom(),
                    candidature.getEtat(),
                    candidature.getDateSoumission()));
        }

        return csv.toString();
    }

    /**
     * Recherche des candidatures selon différents critères
     */
    public List<Map<String, Object>> rechercherCandidatures(String numeroUnique, String nom, String cin, String statut,
            Integer centreId) {
        List<Candidature> candidatures = candidatureRepository.findAll();

        if (numeroUnique != null && !numeroUnique.isEmpty()) {
            candidatures = candidatures.stream()
                    .filter(c -> c.getCandidat().getNumeroUnique().contains(numeroUnique))
                    .collect(Collectors.toList());
        }

        if (nom != null && !nom.isEmpty()) {
            candidatures = candidatures.stream()
                    .filter(c -> c.getCandidat().getNom().toLowerCase().contains(nom.toLowerCase()))
                    .collect(Collectors.toList());
        }

        if (cin != null && !cin.isEmpty()) {
            candidatures = candidatures.stream()
                    .filter(c -> c.getCandidat().getCin().contains(cin))
                    .collect(Collectors.toList());
        }

        if (statut != null && !statut.isEmpty()) {
            Candidature.Etat etat = Candidature.Etat.valueOf(statut);
            candidatures = candidatures.stream()
                    .filter(c -> c.getEtat() == etat)
                    .collect(Collectors.toList());
        }

        if (centreId != null) {
            candidatures = candidatures.stream()
                    .filter(c -> c.getCentre().getId().equals(centreId))
                    .collect(Collectors.toList());
        }

        return candidatures.stream().map(this::convertToMap).collect(Collectors.toList());
    }

    /**
     * Convertit une candidature en Map pour l'API
     */
    private Map<String, Object> convertToMap(Candidature candidature) {
        Map<String, Object> map = new HashMap<>();
        map.put("id", candidature.getId());
        map.put("candidat", Map.of(
                "id", candidature.getCandidat().getId(),
                "numeroUnique", candidature.getCandidat().getNumeroUnique(),
                "nom", candidature.getCandidat().getNom(),
                "prenom", candidature.getCandidat().getPrenom(),
                "cin", candidature.getCandidat().getCin(),
                "email", candidature.getCandidat().getEmail()));
        map.put("concours", Map.of(
                "id", candidature.getConcours().getId(),
                "nom", candidature.getConcours().getNom()));
        map.put("specialite", Map.of(
                "id", candidature.getSpecialite().getId(),
                "nom", candidature.getSpecialite().getNom()));
        map.put("centre", Map.of(
                "id", candidature.getCentre().getId(),
                "nom", candidature.getCentre().getNom()));
        map.put("etat", candidature.getEtat().toString());
        map.put("dateSoumission", candidature.getDateSoumission());
        map.put("dateTraitement", candidature.getDateTraitement());
        map.put("numeroPlace", candidature.getNumeroPlace());
        map.put("motifRejet", candidature.getMotifRejet());
        map.put("commentaireGestionnaire", candidature.getCommentaireGestionnaire());
        return map;
    }
}
