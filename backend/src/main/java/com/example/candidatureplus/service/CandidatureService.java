package com.example.candidatureplus.service;

import com.example.candidatureplus.entity.*;
import com.example.candidatureplus.repository.*;
import com.example.candidatureplus.dto.ValidationRequest;
import com.example.candidatureplus.dto.ValidationResponse;
import com.example.candidatureplus.dto.RejetRequest;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
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

    @Autowired
    private DocumentService documentService;

    @Autowired
    private UtilisateurRepository utilisateurRepository;

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
        if (gestionnaireId != null) {
            ensureCentreAccess(gestionnaireId, candidature.getCentre().getId());
        }

        // Vérifier les documents
        List<Document> documents = documentRepository.findByCandidature_Id(candidatureId);
        if (!verifierDocumentsComplets(documents)) {
            throw new RuntimeException("Documents incomplets ou non conformes");
        }

        // Vérification supplémentaire via service batch (défense en profondeur)
        if (!documentService.getDocumentsManquants(candidatureId).isEmpty()) {
            throw new RuntimeException("Documents obligatoires manquants (CIN/CV/Diplome)");
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
        if (gestionnaireId != null) {
            ensureCentreAccess(gestionnaireId, candidature.getCentre().getId());
        }
        boolean etaitValidee = candidature.getEtat() == Candidature.Etat.Validee
                && candidature.getNumeroPlace() != null;
        Integer centreId = candidature.getCentre().getId();
        Integer specialiteId = candidature.getSpecialite().getId();
        Integer concoursId = candidature.getConcours().getId();
        // Mettre à jour la candidature
        candidature.setEtat(Candidature.Etat.Rejetee);
        candidature.setMotifRejet(motif);
        candidature.setDateTraitement(LocalDateTime.now());
        if (etaitValidee) {
            // Libérer place et retirer numéro
            libererPlace(centreId, specialiteId, concoursId);
            candidature.setNumeroPlace(null);
        }
        // Associer le gestionnaire qui a rejeté
        if (gestionnaireId != null) {
            candidature.setGestionnaire(new Utilisateur());
            candidature.getGestionnaire().setId(gestionnaireId);
        }
        candidatureRepository.save(candidature);
        logActionService.logAction(LogAction.TypeActeur.Utilisateur, gestionnaireId,
                "REJET_CANDIDATURE", "Candidature", candidatureId.longValue());
        notificationService.envoyerNotificationRejet(candidature, motif);
    }

    /**
     * Vérifie si tous les documents requis sont présents et valides
     */
    private boolean verifierDocumentsComplets(List<Document> documents) {
        boolean cinPresent = documents.stream().anyMatch(doc -> doc.getTypeDocument() == Document.TypeDocument.CIN);
        boolean cvPresent = documents.stream().anyMatch(doc -> doc.getTypeDocument() == Document.TypeDocument.CV);
        boolean diplomePresent = documents.stream()
                .anyMatch(doc -> doc.getTypeDocument() == Document.TypeDocument.Diplome);
        return cinPresent && cvPresent && diplomePresent; // Photo non obligatoire
    }

    /**
     * Réserve une place dans un centre pour une spécialité
     */
    private Integer reserverPlace(Integer centreId, Integer specialiteId, Integer concoursId) {
        CentreSpecialite centreSpecialite = centreSpecialiteRepository
                .findByCentreIdAndSpecialiteIdAndConcoursId(centreId, specialiteId, concoursId)
                .orElseThrow(() -> new RuntimeException("Configuration centre/spécialité non trouvée"));
        if (centreSpecialite.getNombrePlacesDisponibles() == null) {
            centreSpecialite.setNombrePlacesDisponibles(0);
        }
        if (centreSpecialite.getPlacesOccupees() == null) {
            centreSpecialite.setPlacesOccupees(0);
        }
        if (centreSpecialite.getNombrePlacesDisponibles() <= 0) {
            throw new RuntimeException("Plus de places disponibles pour cette spécialité");
        }
        // Consommer une place
        centreSpecialite.setNombrePlacesDisponibles(centreSpecialite.getNombrePlacesDisponibles() - 1);
        centreSpecialite.setPlacesOccupees(centreSpecialite.getPlacesOccupees() + 1);
        centreSpecialiteRepository.save(centreSpecialite);
        // Numéro place = placesOccupees courant
        return centreSpecialite.getPlacesOccupees();
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
        if (gestionnaireId != null) {
            ensureCentreAccess(gestionnaireId, candidature.getCentre().getId());
        }

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
     * Récupère les candidatures par centre avec informations détaillées
     */
    public List<Map<String, Object>> getCandidaturesByCentre(Integer centreId, Integer userId) {
        if (userId != null)
            ensureCentreAccess(userId, centreId);
        return getCandidaturesByCentre(centreId);
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
     * Confirme une candidature validée
     */
    public ValidationResponse confirmerCandidature(Integer candidatureId, Integer gestionnaireId) {
        try {
            Candidature candidature = candidatureRepository.findById(candidatureId)
                    .orElseThrow(() -> new RuntimeException("Candidature non trouvée"));
            if (candidature.getEtat() != Candidature.Etat.Validee) {
                throw new RuntimeException("Seules les candidatures validées peuvent être confirmées");
            }
            if (gestionnaireId != null) {
                ensureCentreAccess(gestionnaireId, candidature.getCentre().getId());
            }
            candidature.setEtat(Candidature.Etat.Confirmee);
            candidature.setDateTraitement(java.time.LocalDateTime.now());
            candidatureRepository.save(candidature);
            logActionService.logAction(LogAction.TypeActeur.Utilisateur, gestionnaireId,
                    "CONFIRMATION_CANDIDATURE", "Candidature", candidatureId.longValue());
            return ValidationResponse.success(candidature.getNumeroPlace());
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

    public Map<String, Object> getStatistiquesGlobales(Integer userId) {
        if (userId == null)
            return getStatistiquesGlobales();
        Utilisateur u = utilisateurRepository.findById(userId).orElse(null);
        if (u == null)
            return getStatistiquesGlobales();
        if (u.getRole() == Utilisateur.Role.GestionnaireLocal && u.getCentre() != null) {
            Map<String, Object> centreStats = getStatistiquesCentre(u.getCentre().getId());
            centreStats.put("scope", "centre");
            centreStats.put("centreId", u.getCentre().getId());
            return centreStats;
        }
        Map<String, Object> global = getStatistiquesGlobales();
        global.put("scope", "global");
        return global;
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

    public Map<String, Object> getStatistiquesCentreSecure(Integer centreId, Integer userId) {
        ensureCentreAccess(userId, centreId);
        return getStatistiquesCentre(centreId);
    }

    /**
     * Exporte les candidatures en CSV
     */
    public String exporterCandidaturesCSV(Integer centreId, String statut) {
        StringBuilder csv = new StringBuilder();
        csv.append(
                "Numéro Unique,Nom,Prénom,CIN,Email,Centre,Spécialité,État,Date Soumission,Docs Complets,Numero Place\n");

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
            boolean docsComplets = verifierDocumentsComplets(
                    documentRepository.findByCandidature_Id(candidature.getId()));
            csv.append(String.format("%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s\n",
                    candidature.getCandidat().getNumeroUnique(),
                    candidature.getCandidat().getNom(),
                    candidature.getCandidat().getPrenom(),
                    candidature.getCandidat().getCin(),
                    candidature.getCandidat().getEmail(),
                    candidature.getCentre().getNom(),
                    candidature.getSpecialite().getNom(),
                    candidature.getEtat(),
                    candidature.getDateSoumission(),
                    docsComplets ? "OUI" : "NON",
                    candidature.getNumeroPlace() != null ? candidature.getNumeroPlace() : ""));
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
     * Recherche des candidatures selon différents critères, pour un utilisateur
     * donné
     */
    public List<Map<String, Object>> rechercherCandidaturesForUser(String numeroUnique, String nom, String cin,
            String statut,
            Integer centreId, Integer userId) {
        Utilisateur u = userId != null ? utilisateurRepository.findById(userId).orElse(null) : null;
        if (u != null && u.getRole() == Utilisateur.Role.GestionnaireLocal) {
            // Forcer sur son centre uniquement
            if (u.getCentre() == null)
                return List.of();
            if (centreId != null && !centreId.equals(u.getCentre().getId())) {
                // accès interdit à un autre centre
                throw new RuntimeException("Accès refusé à ce centre");
            }
            centreId = u.getCentre().getId();
        }
        return rechercherCandidatures(numeroUnique, nom, cin, statut, centreId);
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

    /**
     * Récupère les statistiques multi-axes sur les candidatures
     */
    public Map<String, Object> getStatistiquesMultiAxes(Integer concoursId) {
        LocalDate today = LocalDate.now();
        Map<LocalDate, Long> timeline = candidatureRepository.findAll().stream()
                .filter(c -> c.getDateSoumission() != null)
                .filter(c -> c.getDateSoumission().toLocalDate().isAfter(today.minusDays(14)))
                .collect(Collectors.groupingBy(c -> c.getDateSoumission().toLocalDate(), Collectors.counting()));

        List<Map<String, Object>> occupation = centreSpecialiteRepository.findAll().stream()
                .filter(cs -> concoursId == null || cs.getConcours().getId().equals(concoursId))
                .map(cs -> {
                    Map<String, Object> m = new HashMap<>();
                    m.put("centreId", cs.getCentre().getId());
                    m.put("centreNom", cs.getCentre().getNom());
                    m.put("specialiteId", cs.getSpecialite().getId());
                    m.put("specialiteNom", cs.getSpecialite().getNom());
                    m.put("concoursId", cs.getConcours().getId());
                    m.put("placesOccupees", cs.getPlacesOccupees());
                    m.put("placesRestantes", cs.getNombrePlacesDisponibles());
                    m.put("capaciteTotale", (cs.getPlacesOccupees() == null ? 0 : cs.getPlacesOccupees())
                            + (cs.getNombrePlacesDisponibles() == null ? 0 : cs.getNombrePlacesDisponibles()));
                    return m;
                })
                .collect(Collectors.toList());

        List<Map<String, Object>> completude = candidatureRepository.findAll().stream()
                .map(c -> {
                    Map<String, Object> m = new HashMap<>();
                    m.put("candidatureId", c.getId());
                    m.put("centreId", c.getCentre().getId());
                    m.put("specialiteId", c.getSpecialite().getId());
                    m.put("concoursId", c.getConcours().getId());
                    m.put("etat", c.getEtat().toString());
                    m.put("documentsComplets", documentService.verifierDocumentsComplets(c.getId()));
                    return m;
                })
                .collect(Collectors.toList());

        return Map.of(
                "timeline14Jours", timeline,
                "occupationQuotas", occupation,
                "completudeDocuments", completude);
    }

    /**
     * Récupère les statistiques avancées (par gestionnaire, par spécialité, par
     * ville)
     */
    public Map<String, Object> getStatistiquesAvancees() {
        Map<String, Object> res = new HashMap<>();
        Map<Integer, Map<String, Object>> gestionnaires = new HashMap<>();
        candidatureRepository.countByGestionnaire().forEach(arr -> {
            Integer gid = (Integer) arr[0];
            Long total = (Long) arr[1];
            gestionnaires.put(gid, new HashMap<>(Map.of("total", total)));
        });
        candidatureRepository.countByGestionnaireAndEtat().forEach(arr -> {
            Integer gid = (Integer) arr[0];
            Candidature.Etat etat = (Candidature.Etat) arr[1];
            Long nb = (Long) arr[2];
            gestionnaires.computeIfAbsent(gid, k -> new HashMap<>()).put(etat.toString(), nb);
        });
        // calcul taux validation = Validee / (Validee + Rejetee) si denom>0
        gestionnaires.forEach((gid, map) -> {
            long val = ((Number) map.getOrDefault("Validee", 0)).longValue();
            long rej = ((Number) map.getOrDefault("Rejetee", 0)).longValue();
            long denom = val + rej;
            map.put("tauxValidation", denom > 0 ? (double) val / denom : null);
        });
        res.put("parGestionnaire", gestionnaires);

        Map<String, Long> parSpecialite = candidatureRepository.findAll().stream()
                .collect(Collectors.groupingBy(c -> c.getSpecialite().getNom(), Collectors.counting()));
        res.put("parSpecialite", parSpecialite);
        Map<String, Long> parVilleCentre = candidatureRepository.findAll().stream()
                .collect(Collectors.groupingBy(c -> c.getCentre().getVille(), Collectors.counting()));
        res.put("parVilleCentre", parVilleCentre);
        return res;
    }

    public List<Map<String, Object>> getAllCandidaturesMaps() {
        return candidatureRepository.findAll().stream().map(this::convertToMap).toList();
    }

    private void ensureCentreAccess(Integer userId, Integer centreId) {
        if (userId == null)
            throw new RuntimeException("Non authentifié");
        Utilisateur u = utilisateurRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("Utilisateur non trouvé"));
        if (u.getRole() == Utilisateur.Role.GestionnaireLocal) {
            if (u.getCentre() == null || !u.getCentre().getId().equals(centreId)) {
                throw new RuntimeException("Accès refusé au centre");
            }
        }
    }

    public Map<String, Object> getKpiSynthese(Integer userId) {
        Utilisateur tmpUser = null;
        if (userId != null)
            tmpUser = utilisateurRepository.findById(userId).orElse(null);
        final Utilisateur u = tmpUser;
        List<Candidature> all = candidatureRepository.findAll();
        if (u != null && u.getRole() == Utilisateur.Role.GestionnaireLocal && u.getCentre() != null) {
            int cid = u.getCentre().getId();
            all = all.stream().filter(c -> c.getCentre().getId().equals(cid)).toList();
        }
        long total = all.size();
        long docsComplets = all.stream().filter(c -> documentService.verifierDocumentsComplets(c.getId())).count();
        double pctDocsComplets = total > 0 ? (double) docsComplets / total : 0d;
        long val = all.stream().filter(c -> c.getEtat() == Candidature.Etat.Validee).count();
        long rej = all.stream().filter(c -> c.getEtat() == Candidature.Etat.Rejetee).count();
        Double tauxValidation = (val + rej) > 0 ? (double) val / (val + rej) : null;
        List<Map<String, Object>> occupation = centreSpecialiteRepository.findAll().stream()
                .filter(cs -> u == null || u.getRole() != Utilisateur.Role.GestionnaireLocal
                        || (u.getCentre() != null && u.getCentre().getId().equals(cs.getCentre().getId())))
                .map(cs -> {
                    Map<String, Object> m = new HashMap<>();
                    m.put("centreId", cs.getCentre().getId());
                    m.put("centreNom", cs.getCentre().getNom());
                    m.put("specialiteId", cs.getSpecialite().getId());
                    m.put("specialiteNom", cs.getSpecialite().getNom());
                    Integer occ = cs.getPlacesOccupees() == null ? 0 : cs.getPlacesOccupees();
                    Integer rest = cs.getNombrePlacesDisponibles() == null ? 0 : cs.getNombrePlacesDisponibles();
                    int totalCap = occ + rest;
                    m.put("occupation", occ);
                    m.put("capaciteTotale", totalCap);
                    m.put("tauxOccupation", totalCap > 0 ? (double) occ / totalCap : null);
                    return m;
                }).toList();
        return Map.of(
                "totalCandidatures", total,
                "documentsCompletsPourcentage", pctDocsComplets,
                "tauxValidation", tauxValidation,
                "occupation", occupation);
    }

    public Map<String, Object> getTimeline30J(Integer userId) {
        Utilisateur tmpUser = null;
        if (userId != null)
            tmpUser = utilisateurRepository.findById(userId).orElse(null);
        final Utilisateur u = tmpUser;
        LocalDate today = LocalDate.now();
        Map<LocalDate, Long> timeline = candidatureRepository.findAll().stream()
                .filter(c -> c.getDateSoumission() != null
                        && c.getDateSoumission().toLocalDate().isAfter(today.minusDays(30)))
                .filter(c -> u == null || u.getRole() != Utilisateur.Role.GestionnaireLocal
                        || (u.getCentre() != null && c.getCentre().getId().equals(u.getCentre().getId())))
                .collect(Collectors.groupingBy(c -> c.getDateSoumission().toLocalDate(), Collectors.counting()));
        return Map.of("timeline30Jours", timeline);
    }

    public String exporterCandidaturesCSV(Integer centreId, String statut, Integer userId) {
        // Si gestionnaire local, forcer son centre
        if (userId != null) {
            Utilisateur u = utilisateurRepository.findById(userId).orElse(null);
            if (u != null && u.getRole() == Utilisateur.Role.GestionnaireLocal) {
                if (u.getCentre() == null) {
                    return ""; // aucun droit -> vide
                }
                if (centreId != null && !centreId.equals(u.getCentre().getId())) {
                    throw new RuntimeException("Accès refusé à ce centre");
                }
                centreId = u.getCentre().getId();
            }
        }
        return exporterCandidaturesCSV(centreId, statut);
    }

    public Map<String, Object> getStatistiquesMultiAxesForUser(Integer concoursId, Integer userId) {
        Utilisateur u = userId != null ? utilisateurRepository.findById(userId).orElse(null) : null;
        Map<String, Object> base = getStatistiquesMultiAxes(concoursId);
        if (u != null && u.getRole() == Utilisateur.Role.GestionnaireLocal && u.getCentre() != null) {
            Integer centreId = u.getCentre().getId();
            @SuppressWarnings("unchecked")
            List<Map<String, Object>> occupation = (List<Map<String, Object>>) base.get("occupationQuotas");
            occupation = occupation.stream().filter(m -> centreId.equals(m.get("centreId"))).toList();
            @SuppressWarnings("unchecked")
            List<Map<String, Object>> completude = (List<Map<String, Object>>) base.get("completudeDocuments");
            completude = completude.stream().filter(m -> centreId.equals(m.get("centreId"))).toList();
            Map<java.time.LocalDate, Long> timelineFiltre = candidatureRepository.findAll().stream()
                    .filter(c -> c.getCentre().getId().equals(centreId) && c.getDateSoumission() != null
                            && c.getDateSoumission().toLocalDate().isAfter(java.time.LocalDate.now().minusDays(14)))
                    .collect(Collectors.groupingBy(c -> c.getDateSoumission().toLocalDate(), Collectors.counting()));
            base = new HashMap<>(base);
            base.put("occupationQuotas", occupation);
            base.put("completudeDocuments", completude);
            base.put("timeline14Jours", timelineFiltre);
            base.put("scope", "centre");
            base.put("centreId", centreId);
        } else {
            base = new HashMap<>(base);
            base.put("scope", "global");
        }
        return base;
    }

    public Map<String, Object> getStatistiquesAvanceesForUser(Integer userId) {
        Utilisateur u = userId != null ? utilisateurRepository.findById(userId).orElse(null) : null;
        if (u != null && u.getRole() == Utilisateur.Role.GestionnaireLocal && u.getCentre() != null) {
            Integer centreId = u.getCentre().getId();
            // Limiter aux candidatures de son centre
            List<Candidature> list = candidatureRepository.findAll().stream()
                    .filter(c -> c.getCentre().getId().equals(centreId)).toList();
            Map<String, Object> res = new HashMap<>();
            // Pas de stats par gestionnaire global ici, seulement résumé centre
            long total = list.size();
            long validees = list.stream().filter(c -> c.getEtat() == Candidature.Etat.Validee).count();
            long rejetees = list.stream().filter(c -> c.getEtat() == Candidature.Etat.Rejetee).count();
            long soumises = list.stream().filter(c -> c.getEtat() == Candidature.Etat.Soumise).count();
            long enCours = list.stream().filter(c -> c.getEtat() == Candidature.Etat.En_Cours_Validation).count();
            Double tauxValidation = (validees + rejetees) > 0 ? (double) validees / (validees + rejetees) : null;
            res.put("scope", "centre");
            res.put("centreId", centreId);
            res.put("total", total);
            res.put("soumises", soumises);
            res.put("enCours", enCours);
            res.put("validees", validees);
            res.put("rejetees", rejetees);
            res.put("tauxValidation", tauxValidation);
            return res;
        }
        Map<String, Object> global = new HashMap<>(getStatistiquesAvancees());
        global.put("scope", "global");
        return global;
    }

    public String exporterQuotasOccupationCSV(Integer concoursId) {
        StringBuilder sb = new StringBuilder();
        sb.append(
                "ConcoursId,CentreId,Centre,SpecialiteId,Specialite,PlacesOccupees,PlacesRestantes,CapaciteTotale,TauxOccupation\n");
        centreSpecialiteRepository.findAll().stream()
                .filter(cs -> concoursId == null || cs.getConcours().getId().equals(concoursId))
                .forEach(cs -> {
                    int occ = cs.getPlacesOccupees() == null ? 0 : cs.getPlacesOccupees();
                    int rest = cs.getNombrePlacesDisponibles() == null ? 0 : cs.getNombrePlacesDisponibles();
                    int total = occ + rest;
                    Double taux = total > 0 ? (double) occ / total : null;
                    sb.append(cs.getConcours().getId()).append(',')
                            .append(cs.getCentre().getId()).append(',')
                            .append(escape(cs.getCentre().getNom())).append(',')
                            .append(cs.getSpecialite().getId()).append(',')
                            .append(escape(cs.getSpecialite().getNom())).append(',')
                            .append(occ).append(',')
                            .append(rest).append(',')
                            .append(total).append(',')
                            .append(taux != null ? String.format(java.util.Locale.US, "%.4f", taux) : "")
                            .append('\n');
                });
        return sb.toString();
    }

    private String escape(String v) {
        if (v == null)
            return "";
        if (v.contains(",") || v.contains("\"")) {
            return '"' + v.replace("\"", "\"\"") + '"';
        }
        return v;
    }
}
