package com.example.candidatureplus.entity;

import jakarta.persistence.*;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

@Entity
@Table(name = "Concours_Specialite")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class ConcoursSpecialite {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "concours_id", nullable = false)
    private Concours concours;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "specialite_id", nullable = false)
    private Specialite specialite;
    
    @Column(name = "nombre_places")
    private Integer nombrePlaces = 0;
}
