package com.example.candidatureplus.entity;

import jakarta.persistence.*;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;
import java.time.LocalDateTime;

@Entity
@Table(name = "ConcourSpecialite")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class ConcourSpecialite {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Column(name = "concours_id", nullable = false)
    private Integer concoursId;

    @Column(name = "specialite_id", nullable = false)
    private Integer specialiteId;

    @Column(name = "places_disponibles")
    private Integer placesDisponibles = 50;

    @Column(name = "date_creation", nullable = false)
    private LocalDateTime dateCreation = LocalDateTime.now();

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "concours_id", insertable = false, updatable = false)
    private Concours concours;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "specialite_id", insertable = false, updatable = false)
    private Specialite specialite;
}
