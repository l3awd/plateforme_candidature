package com.example.candidatureplus.controller;

import com.example.candidatureplus.entity.Document;
import com.example.candidatureplus.service.DocumentService;
import com.example.candidatureplus.dto.ApiResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.HashMap;
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
    public ResponseEntity<ApiResponse<Map<String, Object>>> uploadDocument(
            @RequestParam("file") MultipartFile file,
            @RequestParam("candidatureId") Integer candidatureId,
            @RequestParam("typeDocument") String typeDocument) {

        try {
            Document.TypeDocument type = Document.TypeDocument.valueOf(typeDocument);

            // Vérifier la validité du document
            if (!documentService.verifierValiditeDocument(file, type)) {
                return ResponseEntity.badRequest().body(ApiResponse.error("Document invalide (taille ou format)"));
            }

            Document document = documentService.sauvegarderDocument(file, candidatureId, type);
            Map<String, Object> data = new HashMap<>();
            data.put("documentId", document.getId());
            return ResponseEntity.ok(ApiResponse.ok("Document uploadé", data));

        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }

    /**
     * Récupérer les documents d'une candidature
     */
    @GetMapping("/candidature/{candidatureId}")
    public ResponseEntity<ApiResponse<List<Document>>> getDocuments(@PathVariable Integer candidatureId) {
        return ResponseEntity.ok(ApiResponse.ok(documentService.getDocumentsByCandidature(candidatureId)));
    }

    /**
     * Vérifier si les documents sont complets
     */
    @GetMapping("/candidature/{candidatureId}/complets")
    public ResponseEntity<ApiResponse<Map<String, Object>>> verifierDocumentsComplets(
            @PathVariable Integer candidatureId) {
        boolean complets = documentService.verifierDocumentsComplets(candidatureId);
        Map<String, Object> data = Map.of("complets", complets);
        return ResponseEntity.ok(ApiResponse.ok(data));
    }

    /**
     * Supprimer un document
     */
    @DeleteMapping("/{documentId}")
    public ResponseEntity<ApiResponse<Void>> supprimerDocument(@PathVariable Integer documentId) {
        try {
            documentService.supprimerDocument(documentId);
            return ResponseEntity.ok(ApiResponse.ok("Document supprimé", null));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }

    /**
     * Upload multiple documents
     */
    @PostMapping(value = "/upload-multiples", consumes = { MediaType.MULTIPART_FORM_DATA_VALUE })
    public ResponseEntity<ApiResponse<Map<String, Object>>> uploadDocumentsMultiples(
            @RequestParam("candidatureId") Integer candidatureId,
            @RequestPart(value = "cin", required = false) MultipartFile cin,
            @RequestPart(value = "cv", required = false) MultipartFile cv,
            @RequestPart(value = "diplome", required = false) MultipartFile diplome,
            @RequestPart(value = "releveNotes", required = false) MultipartFile releveNotes,
            @RequestPart(value = "photo", required = false) MultipartFile photo) {
        try {
            Map<String, Object> resultat = documentService.sauvegarderDocumentsMultiples(candidatureId, cin, cv,
                    diplome, releveNotes, photo);
            return ResponseEntity.ok(ApiResponse.ok(resultat));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }

    /**
     * Pré-upload d'un document (CIN / CV / Diplome)
     */
    @PostMapping(value = "/pre-upload", consumes = { MediaType.MULTIPART_FORM_DATA_VALUE })
    public ResponseEntity<ApiResponse<Map<String, Object>>> preUpload(
            @RequestParam("cin") String cin,
            @RequestParam("typeDocument") String typeDocument,
            @RequestPart("file") MultipartFile file) {
        try {
            Document.TypeDocument type = Document.TypeDocument.valueOf(typeDocument);
            if (!documentService.verifierValiditeDocument(file, type)) {
                return ResponseEntity.badRequest().body(ApiResponse.error("Document invalide"));
            }
            Document doc = documentService.preUploadDocument(file, cin, type);
            return ResponseEntity.ok(ApiResponse.ok(Map.of("documentId", doc.getId())));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }
}
