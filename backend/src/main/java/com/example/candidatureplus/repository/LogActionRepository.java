package com.example.candidatureplus.repository;

import com.example.candidatureplus.entity.LogAction;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface LogActionRepository extends JpaRepository<LogAction, Integer> {

        List<LogAction> findByTypeActeur(LogAction.TypeActeur typeActeur);

        List<LogAction> findByActeurId(Integer acteurId);

        List<LogAction> findByAction(String action);

        @Query("SELECT l FROM LogAction l WHERE l.dateAction BETWEEN :dateDebut AND :dateFin")
        List<LogAction> findByDateActionBetween(
                        @Param("dateDebut") LocalDateTime dateDebut,
                        @Param("dateFin") LocalDateTime dateFin);

        @Query("SELECT l FROM LogAction l WHERE l.typeActeur = :typeActeur AND l.acteurId = :acteurId ORDER BY l.dateAction DESC")
        List<LogAction> findByTypeActeurAndActeurIdOrderByDateActionDesc(
                        @Param("typeActeur") LogAction.TypeActeur typeActeur,
                        @Param("acteurId") Integer acteurId);

        // Nouvelles méthodes pour les contrôleurs et diagnostics
        @Query(value = "SELECT * FROM Log_Action ORDER BY date_action DESC LIMIT 50", nativeQuery = true)
        List<LogAction> findTop50ByOrderByDateActionDesc();

        List<LogAction> findByActionOrderByDateActionDesc(String action);

        List<LogAction> findByDateActionAfterOrderByDateActionDesc(LocalDateTime dateAction);

        long countByTypeActeur(LogAction.TypeActeur typeActeur);

        long countByDateActionAfter(LocalDateTime dateAction);

        @Query("SELECT l FROM LogAction l WHERE l.action LIKE %:keyword% OR l.details LIKE %:keyword% ORDER BY l.dateAction DESC")
        List<LogAction> findByActionContainingOrDetailsContainingOrderByDateActionDesc(
                        @Param("keyword") String keyword);
}
