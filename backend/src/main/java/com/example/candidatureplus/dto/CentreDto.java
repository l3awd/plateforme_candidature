package com.example.candidatureplus.dto;

import lombok.Data;
import lombok.Builder;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class CentreDto {
    private Integer id;
    private String nom;
    private String ville;
    private String adresse;
    private String telephone;
    private String email;
    private Boolean actif;
}
