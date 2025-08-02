package com.example.candidatureplus.dto;

import lombok.Data;
import lombok.AllArgsConstructor;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class ValidationResponse {
    private boolean success;
    private String message;
    private Integer numeroPlace;

    public static ValidationResponse success(Integer numeroPlace) {
        return new ValidationResponse(true, "Candidature validée avec succès", numeroPlace);
    }

    public static ValidationResponse failure(String message) {
        return new ValidationResponse(false, message, null);
    }
}
