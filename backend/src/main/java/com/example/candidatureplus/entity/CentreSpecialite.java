package com.example.candidatureplus.entity;

import jakarta.persistence.*;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

@Entity
@Table(name = "Centre_Specialite")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class CentreSpecialite {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "centre_id", nullable = false)
    private Centre centre;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "specialite_id", nullable = false)
    private Specialite specialite;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "concours_id", nullable = false)
    private Concours concours;

    @Column(name = "nombre_places_disponibles")
    private Integer nombrePlacesDisponibles = 0;

    @Column(name = "places_occupees")
    private Integer placesOccupees = 0; // suivi des places utilisées
}
