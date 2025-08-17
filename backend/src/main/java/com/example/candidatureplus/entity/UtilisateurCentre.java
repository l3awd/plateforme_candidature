package com.example.candidatureplus.entity;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "Utilisateur_Centre", uniqueConstraints = @UniqueConstraint(name = "uk_utilisateur_centre", columnNames = {
        "utilisateur_id", "centre_id" }))
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class UtilisateurCentre {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "utilisateur_id", nullable = false)
    private Utilisateur utilisateur;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "centre_id", nullable = false)
    private Centre centre;

    @Builder.Default
    @Column(nullable = false)
    private Boolean actif = true;

    @Builder.Default
    @Column(name = "date_attribution", nullable = false)
    private LocalDateTime dateAttribution = LocalDateTime.now();
}
