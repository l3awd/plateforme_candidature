package com.example.candidatureplus.service;

import com.example.candidatureplus.entity.*;
import com.example.candidatureplus.repository.*;
import com.example.candidatureplus.dto.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.time.LocalDateTime;
import java.util.*;
import java.util.stream.Collectors;

@Service
@Transactional
public class CandidatureEnhancedService {

    @Autowired
    private CandidatureRepository candidatureRepository;
    @Autowired
    private CandidatRepository candidatRepository;
    @Autowired
    private ConcoursRepository concoursRepository;
    @Autowired
    private SpecialiteRepository specialiteRepository;
    @Autowired
    private CentreRepository centreRepository;
    @Autowired
    private ConcoursSpecialiteRepository concoursSpecialiteRepository;
    @Autowired
    private ConcoursCentreRepository concoursCentreRepository;

    private final String UPLOAD_DIR = "uploads/cv/";

    /**
     * Soumettre une candidature avec upload CV
     */
    public CandidatureResponse soumettreAvecCV(CandidatureRequest request, MultipartFile cvFile) {
        try {
            // Valider les données
            validateCandidatureRequest(request);

            // Vérifier concours/spécialité/centre
            validateConcoursSpecialiteCentre(request.getConcoursId(), request.getSpecialiteId(), request.getCentreId());

            // Créer ou récupérer candidat
            Candidat candidat = createOrUpdateCandidat(request);

            // Créer candidature
            Candidature candidature = new Candidature();
            candidature.setCandidat(candidat);
            candidature.setConcours(concoursRepository.findById(request.getConcoursId()).orElseThrow());
            candidature.setSpecialite(specialiteRepository.findById(request.getSpecialiteId()).orElseThrow());
            candidature.setCentre(centreRepository.findById(request.getCentreId()).orElseThrow());
            candidature.setEtat(Candidature.Etat.Soumise);
            candidature.setDateSoumission(LocalDateTime.now());

            // Upload CV si fourni
            if (cvFile != null && !cvFile.isEmpty()) {
                String cvPath = uploadCV(cvFile, candidat.getNumeroUnique());
                candidature.setCvFichier(cvPath);
                candidature.setCvType(cvFile.getContentType());
                candidature.setCvTailleOctets(cvFile.getSize());
            }

            candidature = candidatureRepository.save(candidature);

            return CandidatureResponse.builder()
                    .success(true)
                    .message("Candidature soumise avec succès")
                    .numeroUnique(candidat.getNumeroUnique())
                    .candidatureId(candidature.getId())
                    .build();

        } catch (Exception e) {
            return CandidatureResponse.builder()
                    .success(false)
                    .message("Erreur: " + e.getMessage())
                    .build();
        }
    }

    /**
     * Upload CV
     */
    private String uploadCV(MultipartFile file, String numeroUnique) throws IOException {
        // Créer le répertoire s'il n'existe pas
        Path uploadPath = Paths.get(UPLOAD_DIR);
        if (!Files.exists(uploadPath)) {
            Files.createDirectories(uploadPath);
        }

        // Générer nom fichier unique
        String extension = getFileExtension(file.getOriginalFilename());
        String fileName = "CV_" + numeroUnique + "_" + System.currentTimeMillis() + "." + extension;
        Path filePath = uploadPath.resolve(fileName);

        // Sauvegarder fichier
        Files.copy(file.getInputStream(), filePath);

        return fileName;
    }

    private String getFileExtension(String fileName) {
        if (fileName == null || fileName.lastIndexOf(".") == -1) {
            return "pdf";
        }
        return fileName.substring(fileName.lastIndexOf(".") + 1).toLowerCase();
    }

    /**
     * Valider la compatibilité concours/spécialité/centre
     */
    private void validateConcoursSpecialiteCentre(Integer concoursId, Integer specialiteId, Integer centreId) {
        // Vérifier que la spécialité est disponible pour ce concours
        ConcoursSpecialite cs = concoursSpecialiteRepository.findByConcoursIdAndSpecialiteId(concoursId, specialiteId);
        if (cs == null) {
            throw new RuntimeException("Cette spécialité n'est pas disponible pour ce concours");
        }

        // Vérifier que le centre est disponible pour ce concours
        ConcoursCentre cc = concoursCentreRepository.findByConcoursIdAndCentreId(concoursId, centreId);
        if (cc == null) {
            throw new RuntimeException("Ce centre n'est pas disponible pour ce concours");
        }

        // Vérifier les places disponibles
        long candidaturesExistantes = candidatureRepository.countByConcoursIdAndSpecialiteIdAndCentreId(concoursId,
                specialiteId, centreId);
        if (candidaturesExistantes >= cs.getNombrePlaces()) {
            throw new RuntimeException("Plus de places disponibles pour cette spécialité dans ce centre");
        }
    }

    /**
     * Récupérer spécialités par concours
     */
    public List<SpecialiteDto> getSpecialitesByConcoursId(Integer concoursId) {
        return concoursSpecialiteRepository.findSpecialitesByConcoursId(concoursId)
                .stream()
                .map(this::convertToSpecialiteDto)
                .collect(Collectors.toList());
    }

    /**
     * Récupérer centres par concours
     */
    public List<CentreDto> getCentresByConcoursId(Integer concoursId) {
        return concoursCentreRepository.findCentresByConcoursId(concoursId)
                .stream()
                .map(this::convertToCentreDto)
                .collect(Collectors.toList());
    }

    /**
     * Récupérer candidatures par centre (pour gestionnaires)
     */
    public List<CandidatureDetailDto> getCandidaturesByGestionnaire(Integer gestionnaireId) {
        try {
            // Récupérer centres assignés au gestionnaire
            List<Integer> centresAssignes = getCentresAssignes(gestionnaireId);

            if (centresAssignes.isEmpty()) {
                return new ArrayList<>();
            }

            return candidatureRepository.findByCentreIdIn(centresAssignes)
                    .stream()
                    .map(this::convertToCandidatureDetailDto)
                    .collect(Collectors.toList());

        } catch (Exception e) {
            throw new RuntimeException("Erreur lors du chargement des candidatures: " + e.getMessage());
        }
    }

    /**
     * Récupérer centres assignés à un gestionnaire
     */
    private List<Integer> getCentresAssignes(Integer gestionnaireId) {
        try {
            // Cette méthode devrait être dans UtilisateurService, mais pour simplifier...
            // En réalité, on ferait un appel à UtilisateurRepository
            return Arrays.asList(1, 2); // Exemple: centres 1 et 2
        } catch (Exception e) {
            return new ArrayList<>();
        }
    }

    // Méthodes de conversion DTOs
    private SpecialiteDto convertToSpecialiteDto(Specialite specialite) {
        return SpecialiteDto.builder()
                .id(specialite.getId())
                .nom(specialite.getNom())
                .domaine(specialite.getDomaine())
                .build();
    }

    private CentreDto convertToCentreDto(Centre centre) {
        return CentreDto.builder()
                .id(centre.getId())
                .nom(centre.getNom())
                .ville(centre.getVille())
                .adresse(centre.getAdresse())
                .build();
    }

    private CandidatureDetailDto convertToCandidatureDetailDto(Candidature candidature) {
        Candidat candidat = candidature.getCandidat();
        Concours concours = candidature.getConcours();
        Specialite specialite = candidature.getSpecialite();
        Centre centre = candidature.getCentre();

        return CandidatureDetailDto.builder()
                .id(candidature.getId())
                // Informations candidature
                .etat(candidature.getEtat().toString())
                .dateSoumission(candidature.getDateSoumission())
                .dateTraitement(candidature.getDateTraitement())
                .motifRejet(candidature.getMotifRejet())
                .commentaireGestionnaire(candidature.getCommentaireGestionnaire())
                .numeroPlace(candidature.getNumeroPlace())

                // Informations candidat
                .candidatId(candidat.getId())
                .candidatNumeroUnique(candidat.getNumeroUnique())
                .candidatNom(candidat.getNom())
                .candidatPrenom(candidat.getPrenom())
                .candidatEmail(candidat.getEmail())
                .candidatTelephone(candidat.getTelephone())
                .candidatCin(candidat.getCin())
                .candidatDateNaissance(candidat.getDateNaissance())
                .candidatLieuNaissance(candidat.getLieuNaissance())
                .candidatVille(candidat.getVille())
                .candidatGenre(candidat.getGenre().toString())
                .candidatExperienceProfessionnelle(candidat.getExperienceProfessionnelle())
                .candidatNiveauEtudes(candidat.getNiveauEtudes())
                .candidatDiplome(candidat.getDiplomePrincipal())
                .candidatEtablissement(candidat.getEtablissement())
                .candidatAnneeObtention(
                        candidat.getAnneeObtention() != null ? candidat.getAnneeObtention().toString() : null)

                // Informations concours
                .concoursId(concours.getId())
                .concoursNom(concours.getNom())
                .concoursDescription(concours.getDescription())
                .concoursDateLimite(concours.getDateFinCandidature())
                .concoursStatut(concours.getActif() ? "Actif" : "Inactif")

                // Informations spécialité
                .specialiteId(specialite.getId())
                .specialiteNom(specialite.getNom())
                .specialiteDescription(specialite.getDescription())

                // Informations centre
                .centreId(centre.getId())
                .centreNom(centre.getNom())
                .centreVille(centre.getVille())
                .centreAdresse(centre.getAdresse())

                // Documents
                .cvUploaded(candidature.getCvFichier() != null)
                .build();
    }

    private CandidatDto convertToCandidatDto(Candidat candidat) {
        return CandidatDto.builder()
                .id(candidat.getId())
                .nom(candidat.getNom())
                .prenom(candidat.getPrenom())
                .cin(candidat.getCin())
                .email(candidat.getEmail())
                .telephone(candidat.getTelephone())
                .ville(candidat.getVille())
                .lieuNaissance(candidat.getLieuNaissance())
                .build();
    }

    private ConcoursDto convertToConcoursDto(Concours concours) {
        return ConcoursDto.builder()
                .id(concours.getId())
                .nom(concours.getNom())
                .description(concours.getDescription())
                .dateDebut(concours.getDateDebutCandidature())
                .dateFin(concours.getDateFinCandidature())
                .build();
    }

    // Méthodes utilitaires
    private void validateCandidatureRequest(CandidatureRequest request) {
        if (request.getConcoursId() == null) {
            throw new RuntimeException("Le concours est obligatoire");
        }
        if (request.getSpecialiteId() == null) {
            throw new RuntimeException("La spécialité est obligatoire");
        }
        if (request.getCentreId() == null) {
            throw new RuntimeException("Le centre d'examen est obligatoire");
        }

        if (request.getCandidat() == null) {
            throw new RuntimeException("Les données du candidat sont obligatoires");
        }

        CandidatureRequest.CandidatData candidat = request.getCandidat();

        // Validation CIN
        if (!validateCIN(candidat.getCin())) {
            throw new RuntimeException("Format CIN invalide. Format attendu: 1-2 lettres suivies de 5-6 chiffres");
        }

        // Validation téléphone
        if (!validateTelephone(candidat.getTelephone())) {
            throw new RuntimeException("Format téléphone invalide. Format attendu: 06 ou 07 suivi de 8 chiffres");
        }

        // Autres validations
        if (candidat.getNom() == null || candidat.getNom().trim().isEmpty()) {
            throw new RuntimeException("Le nom est obligatoire");
        }

        if (candidat.getPrenom() == null || candidat.getPrenom().trim().isEmpty()) {
            throw new RuntimeException("Le prénom est obligatoire");
        }

        if (candidat.getEmail() == null || !isValidEmail(candidat.getEmail())) {
            throw new RuntimeException("Email invalide");
        }
    }

    private boolean isValidEmail(String email) {
        if (email == null)
            return false;
        return email.matches("^[A-Za-z0-9+_.-]+@(.+)$");
    }

    private boolean validateCIN(String cin) {
        if (cin == null || cin.trim().isEmpty())
            return false;
        // Format: 1-2 lettres + 5-6 chiffres
        return cin.matches("^[A-Za-z]{1,2}\\d{5,6}$");
    }

    private boolean validateTelephone(String telephone) {
        if (telephone == null || telephone.trim().isEmpty())
            return false;
        // Format: 06 ou 07 + 8 chiffres
        return telephone.matches("^(06|07)\\d{8}$");
    }

    private Candidat createOrUpdateCandidat(CandidatureRequest request) {
        CandidatureRequest.CandidatData candidatData = request.getCandidat();

        // Vérifier si candidat existe déjà
        Optional<Candidat> existant = candidatRepository.findByCin(candidatData.getCin());

        if (existant.isPresent()) {
            // Mettre à jour candidat existant
            Candidat candidat = existant.get();
            updateCandidatFromRequest(candidat, candidatData);
            return candidatRepository.save(candidat);
        } else {
            // Créer nouveau candidat
            return createNewCandidatFromRequest(candidatData);
        }
    }

    private void updateCandidatFromRequest(Candidat candidat, CandidatureRequest.CandidatData request) {
        candidat.setNom(request.getNom());
        candidat.setPrenom(request.getPrenom());
        candidat.setGenre(request.getGenre());
        candidat.setEmail(request.getEmail());
        candidat.setTelephone(request.getTelephone());
        candidat.setTelephoneUrgence(request.getTelephoneUrgence());
        candidat.setVille(request.getVille());
        candidat.setLieuNaissance(request.getLieuNaissance());
        candidat.setDateNaissance(request.getDateNaissance());
        candidat.setNiveauEtudes(request.getNiveauEtudes());
        candidat.setDiplomePrincipal(request.getDiplomePrincipal());
        candidat.setSpecialiteDiplome(request.getSpecialiteDiplome());
        candidat.setEtablissement(request.getEtablissement());
        candidat.setAnneeObtention(request.getAnneeObtention());
        candidat.setExperienceProfessionnelle(request.getExperienceProfessionnelle());
        candidat.setConditionsAcceptees(request.getConditionsAcceptees());
    }

    private Candidat createNewCandidatFromRequest(CandidatureRequest.CandidatData request) {
        Candidat candidat = new Candidat();
        candidat.setNumeroUnique(generateNumeroUnique());
        candidat.setNom(request.getNom());
        candidat.setPrenom(request.getPrenom());
        candidat.setGenre(request.getGenre());
        candidat.setCin(request.getCin());
        candidat.setEmail(request.getEmail());
        candidat.setTelephone(request.getTelephone());
        candidat.setTelephoneUrgence(request.getTelephoneUrgence());
        candidat.setVille(request.getVille());
        candidat.setLieuNaissance(request.getLieuNaissance());
        candidat.setDateNaissance(request.getDateNaissance());
        candidat.setNiveauEtudes(request.getNiveauEtudes());
        candidat.setDiplomePrincipal(request.getDiplomePrincipal());
        candidat.setSpecialiteDiplome(request.getSpecialiteDiplome());
        candidat.setEtablissement(request.getEtablissement());
        candidat.setAnneeObtention(request.getAnneeObtention());
        candidat.setExperienceProfessionnelle(request.getExperienceProfessionnelle());
        candidat.setConditionsAcceptees(request.getConditionsAcceptees());
        candidat.setDateCreation(LocalDateTime.now());

        return candidatRepository.save(candidat);
    }

    private String generateNumeroUnique() {
        return "CAND" + System.currentTimeMillis() + (int) (Math.random() * 1000);
    }
}
