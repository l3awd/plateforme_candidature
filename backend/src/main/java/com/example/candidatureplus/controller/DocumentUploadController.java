package com.example.candidatureplus.controller;

import com.example.candidatureplus.entity.Document;
import com.example.candidatureplus.service.DocumentService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/documents")
@CrossOrigin(origins = "http://localhost:3000")
public class DocumentUploadController {

    @Autowired
    private DocumentService documentService;

    /**
     * Upload d'un document
     */
    @PostMapping("/upload")
    public ResponseEntity<?> uploadDocument(
            @RequestParam("file") MultipartFile file,
            @RequestParam("candidatureId") Integer candidatureId,
            @RequestParam("typeDocument") String typeDocument) {

        try {
            Document.TypeDocument type = Document.TypeDocument.valueOf(typeDocument);

            // Vérifier la validité du document
            if (!documentService.verifierValiditeDocument(file, type)) {
                return ResponseEntity.badRequest().body(Map.of(
                        "success", false,
                        "message", "Document invalide (taille ou format)"));
            }

            Document document = documentService.sauvegarderDocument(file, candidatureId, type);

            return ResponseEntity.ok(Map.of(
                    "success", true,
                    "message", "Document uploadé avec succès",
                    "documentId", document.getId()));

        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of(
                    "success", false,
                    "message", "Erreur lors de l'upload: " + e.getMessage()));
        }
    }

    /**
     * Récupérer les documents d'une candidature
     */
    @GetMapping("/candidature/{candidatureId}")
    public ResponseEntity<List<Document>> getDocuments(@PathVariable Integer candidatureId) {
        List<Document> documents = documentService.getDocumentsByCandidature(candidatureId);
        return ResponseEntity.ok(documents);
    }

    /**
     * Vérifier si les documents sont complets
     */
    @GetMapping("/candidature/{candidatureId}/complets")
    public ResponseEntity<?> verifierDocumentsComplets(@PathVariable Integer candidatureId) {
        boolean complets = documentService.verifierDocumentsComplets(candidatureId);
        return ResponseEntity.ok(Map.of(
                "complets", complets,
                "message", complets ? "Documents complets" : "Documents manquants"));
    }

    /**
     * Supprimer un document
     */
    @DeleteMapping("/{documentId}")
    public ResponseEntity<?> supprimerDocument(@PathVariable Integer documentId) {
        try {
            documentService.supprimerDocument(documentId);
            return ResponseEntity.ok(Map.of(
                    "success", true,
                    "message", "Document supprimé avec succès"));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of(
                    "success", false,
                    "message", "Erreur lors de la suppression: " + e.getMessage()));
        }
    }
}
