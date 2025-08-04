package com.example.candidatureplus.entity;

import jakarta.persistence.*;
import lombok.Data;
import lombok.AllArgsConstructor;
import lombok.NoArgsConstructor;
import java.time.LocalDateTime;

@Entity
@Table(name = "ConcoursCentre")
@Data
@AllArgsConstructor
@NoArgsConstructor
public class ConcoursCentre {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @ManyToOne
    @JoinColumn(name = "concours_id", nullable = false)
    private Concours concours;

    @ManyToOne
    @JoinColumn(name = "centre_id", nullable = false)
    private Centre centre;

    @Column(name = "places_disponibles")
    private Integer placesDisponibles = 100;

    @Column(name = "date_creation")
    private LocalDateTime dateCreation = LocalDateTime.now();
}
