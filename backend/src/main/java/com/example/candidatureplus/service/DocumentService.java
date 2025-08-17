package com.example.candidatureplus.service;

import com.example.candidatureplus.entity.Document;
import com.example.candidatureplus.repository.DocumentRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@Service
public class DocumentService {

    @Autowired
    private DocumentRepository documentRepository;

    private final String uploadDir = "uploads/documents/";

    /**
     * Sauvegarde un document uploadé
     */
    public Document sauvegarderDocument(MultipartFile file, Integer candidatureId,
            Document.TypeDocument typeDocument) throws IOException {

        // Créer le répertoire s'il n'existe pas
        Path uploadPath = Paths.get(uploadDir);
        if (!Files.exists(uploadPath)) {
            Files.createDirectories(uploadPath);
        }

        // Générer un nom unique pour le fichier
        String originalFilename = file.getOriginalFilename();
        String extension = originalFilename.substring(originalFilename.lastIndexOf("."));
        String uniqueFilename = UUID.randomUUID().toString() + extension;

        // Chemin complet du fichier
        Path filePath = uploadPath.resolve(uniqueFilename);

        // Sauvegarder le fichier
        Files.copy(file.getInputStream(), filePath);

        // Créer l'enregistrement en base
        Document document = new Document();
        if (candidatureId != null) { // éviter de créer une entité Candidature fantôme lors du pré-upload
            document.setCandidature(new com.example.candidatureplus.entity.Candidature());
            document.getCandidature().setId(candidatureId);
        } else {
            document.setCandidature(null);
        }
        document.setTypeDocument(typeDocument);
        document.setNomFichier(originalFilename);
        document.setCheminFichier(filePath.toString());
        document.setTailleFichier(file.getSize());
        document.setTypeMime(file.getContentType());
        document.setDateUpload(LocalDateTime.now());

        return documentRepository.save(document);
    }

    /**
     * Vérifie si tous les documents requis sont présents
     */
    public boolean verifierDocumentsComplets(Integer candidatureId) {
        List<Document> documents = documentRepository.findByCandidature_Id(candidatureId);

        // Documents obligatoires
        boolean hasCIN = documents.stream()
                .anyMatch(d -> d.getTypeDocument() == Document.TypeDocument.CIN);
        boolean hasCV = documents.stream()
                .anyMatch(d -> d.getTypeDocument() == Document.TypeDocument.CV);
        boolean hasDiplome = documents.stream()
                .anyMatch(d -> d.getTypeDocument() == Document.TypeDocument.Diplome);
        // Photo devient optionnelle -> ne plus l'exiger
        return hasCIN && hasCV && hasDiplome;
    }

    /**
     * Vérifie la validité d'un document (taille, type, etc.)
     */
    public boolean verifierValiditeDocument(MultipartFile file, Document.TypeDocument typeDocument) {
        if (file.isEmpty()) {
            return false;
        }

        // Vérifier la taille (max 5MB)
        if (file.getSize() > 5 * 1024 * 1024) {
            return false;
        }

        // Vérifier le type MIME selon le type de document
        String contentType = file.getContentType();
        switch (typeDocument) {
            case Photo:
                return contentType != null && contentType.startsWith("image/");
            case CIN:
            case CV:
            case Diplome:
            case Releve_Notes:
                return contentType != null &&
                        (contentType.equals("application/pdf") ||
                                contentType.startsWith("image/"));
            default:
                return true;
        }
    }

    /**
     * Récupère les documents d'une candidature
     */
    public List<Document> getDocumentsByCandidature(Integer candidatureId) {
        return documentRepository.findByCandidature_Id(candidatureId);
    }

    /**
     * Supprime un document
     */
    public void supprimerDocument(Integer documentId) throws IOException {
        Document document = documentRepository.findById(documentId)
                .orElseThrow(() -> new RuntimeException("Document non trouvé"));

        // Supprimer le fichier physique
        Path filePath = Paths.get(document.getCheminFichier());
        if (Files.exists(filePath)) {
            Files.delete(filePath);
        }

        // Supprimer l'enregistrement en base
        documentRepository.delete(document);
    }

    /**
     * Upload multiple standard documents in one request (CIN, CV, Diplome,
     * Releve_Notes, Photo)
     */
    public Map<String, Object> sauvegarderDocumentsMultiples(Integer candidatureId,
            MultipartFile cin,
            MultipartFile cv,
            MultipartFile diplome,
            MultipartFile releveNotes,
            MultipartFile photo) throws IOException {
        Map<String, Object> result = new HashMap<>();
        List<String> sauvegardes = new ArrayList<>();
        if (cin != null && !cin.isEmpty()) {
            sauvegarderDocument(cin, candidatureId, Document.TypeDocument.CIN);
            sauvegardes.add("CIN");
        }
        if (cv != null && !cv.isEmpty()) {
            sauvegarderDocument(cv, candidatureId, Document.TypeDocument.CV);
            sauvegardes.add("CV");
        }
        if (diplome != null && !diplome.isEmpty()) {
            sauvegarderDocument(diplome, candidatureId, Document.TypeDocument.Diplome);
            sauvegardes.add("Diplome");
        }
        if (releveNotes != null && !releveNotes.isEmpty()) {
            sauvegarderDocument(releveNotes, candidatureId, Document.TypeDocument.Releve_Notes);
            sauvegardes.add("Releve_Notes");
        }
        if (photo != null && !photo.isEmpty()) {
            sauvegarderDocument(photo, candidatureId, Document.TypeDocument.Photo);
            sauvegardes.add("Photo");
        }
        boolean complets = verifierDocumentsComplets(candidatureId);
        result.put("success", true);
        result.put("documentsSauvegardes", sauvegardes);
        result.put("documentsComplets", complets);
        if (!complets) {
            result.put("documentsManquants", getDocumentsManquants(candidatureId));
        }
        return result;
    }

    /**
     * Liste les documents manquants pour les obligatoires.
     */
    public List<String> getDocumentsManquants(Integer candidatureId) {
        List<Document> documents = documentRepository.findByCandidature_Id(candidatureId);
        List<String> manquants = new ArrayList<>();
        if (documents.stream().noneMatch(d -> d.getTypeDocument() == Document.TypeDocument.CIN))
            manquants.add("CIN");
        if (documents.stream().noneMatch(d -> d.getTypeDocument() == Document.TypeDocument.CV))
            manquants.add("CV");
        if (documents.stream().noneMatch(d -> d.getTypeDocument() == Document.TypeDocument.Diplome))
            manquants.add("Diplome");
        return manquants;
    }

    public Document preUploadDocument(MultipartFile file, String cinTemp, Document.TypeDocument type)
            throws IOException {
        Document doc = sauvegarderDocument(file, null, type);
        doc.setCinTemp(cinTemp);
        doc.setCandidature(null);
        return documentRepository.save(doc);
    }

    public int rattacherPreUploadedDocuments(String cinTemp, Integer candidatureId) {
        List<Document> temporaires = documentRepository.findByCinTemp(cinTemp);
        int count = 0;
        for (Document d : temporaires) {
            if (d.getCandidature() == null) {
                com.example.candidatureplus.entity.Candidature c = new com.example.candidatureplus.entity.Candidature();
                c.setId(candidatureId);
                d.setCandidature(c);
                d.setCinTemp(null);
                documentRepository.save(d);
                count++;
            }
        }
        return count;
    }
}
