package com.example.candidatureplus.dto;

import com.example.candidatureplus.entity.Utilisateur;
import lombok.Data;
import lombok.AllArgsConstructor;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class LoginResponse {
    private boolean success;
    private String message;
    private Integer userId;
    private String nom;
    private String prenom;
    private String email;
    private String role;
    private Integer centreId;
    private String centreNom;

    public static LoginResponse success(Utilisateur utilisateur) {
        LoginResponse response = new LoginResponse();
        response.setSuccess(true);
        response.setMessage("Authentification réussie");
        response.setUserId(utilisateur.getId());
        response.setNom(utilisateur.getNom());
        response.setPrenom(utilisateur.getPrenom());
        response.setEmail(utilisateur.getEmail());
        response.setRole(utilisateur.getRole().toString());

        if (utilisateur.getCentre() != null) {
            response.setCentreId(utilisateur.getCentre().getId());
            response.setCentreNom(utilisateur.getCentre().getNom());
        }

        return response;
    }

    public static LoginResponse failure(String message) {
        return new LoginResponse(false, message, null, null, null, null, null, null, null);
    }
}
