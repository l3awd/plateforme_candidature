package com.example.candidatureplus.dto;

import lombok.Data;
import lombok.Builder;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class SpecialiteDto {
    private Integer id;
    private String nom;
    private String domaine;
    private Boolean actif;
    private String description;
}
