package com.example.candidatureplus.service;

import com.example.candidatureplus.entity.LogAction;
import com.example.candidatureplus.repository.LogActionRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;

@Service
public class LogActionService {

    @Autowired
    private LogActionRepository logActionRepository;

    /**
     * Enregistre une action dans les logs
     */
    public void logAction(LogAction.TypeActeur typeActeur, Integer acteurId, String action,
            String tableCible, Long enregistrementId) {
        logAction(typeActeur, acteurId, action, tableCible, enregistrementId, null);
    }

    /**
     * Enregistre une action dans les logs avec des détails supplémentaires
     */
    public void logAction(LogAction.TypeActeur typeActeur, Integer acteurId, String action,
            String tableCible, Long enregistrementId, String details) {
        LogAction log = new LogAction();
        log.setTypeActeur(typeActeur);
        log.setActeurId(acteurId);
        log.setAction(action);
        log.setTableCible(tableCible);
        log.setEnregistrementId(enregistrementId);
        log.setDetails(details);
        log.setDateAction(LocalDateTime.now());

        logActionRepository.save(log);
    }

    /**
     * Enregistre une action système
     */
    public void logSystemAction(String action, String details) {
        logAction(LogAction.TypeActeur.Systeme, null, action, null, null, details);
    }

    /**
     * Enregistre une action de candidat
     */
    public void logCandidatAction(Integer candidatId, String action, String tableCible, Long enregistrementId) {
        logAction(LogAction.TypeActeur.Candidat, candidatId, action, tableCible, enregistrementId);
    }
}
