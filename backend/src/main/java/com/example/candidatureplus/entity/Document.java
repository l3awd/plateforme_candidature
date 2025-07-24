package com.example.candidatureplus.entity;

import jakarta.persistence.*;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;
import java.time.LocalDateTime;

@Entity
@Table(name = "Document")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Document {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "candidature_id", nullable = false)
    private Candidature candidature;
    
    @Enumerated(EnumType.STRING)
    @Column(name = "type_document", nullable = false)
    private TypeDocument typeDocument;
    
    @Column(name = "nom_fichier", nullable = false, length = 255)
    private String nomFichier;
    
    @Column(name = "chemin_fichier", nullable = false, length = 500)
    private String cheminFichier;
    
    @Column(name = "taille_fichier")
    private Long tailleFichier;
    
    @Column(name = "type_mime", length = 100)
    private String typeMime;
    
    @Column(name = "date_upload", nullable = false)
    private LocalDateTime dateUpload = LocalDateTime.now();
    
    public enum TypeDocument {
        CIN, CV, Diplome, Releve_Notes, Photo, Autre
    }
}
