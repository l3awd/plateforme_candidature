package com.example.candidatureplus.dto;

import lombok.Data;
import lombok.Builder;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class CandidatureResponse {
    private boolean success;
    private String message;
    private String numeroUnique;
    private Integer candidatureId;
    private String errorCode;
}
