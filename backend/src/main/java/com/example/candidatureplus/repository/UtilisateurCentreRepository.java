package com.example.candidatureplus.repository;

import com.example.candidatureplus.entity.UtilisateurCentre;
import com.example.candidatureplus.entity.Centre;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;

public interface UtilisateurCentreRepository extends JpaRepository<UtilisateurCentre, Integer> {
    List<UtilisateurCentre> findByUtilisateurIdAndActifTrue(Integer utilisateurId);

    List<UtilisateurCentre> findByCentreIdAndActifTrue(Integer centreId);

    Optional<UtilisateurCentre> findByUtilisateurIdAndCentreId(Integer utilisateurId, Integer centreId);

    @Query("SELECT uc.centre FROM UtilisateurCentre uc WHERE uc.utilisateur.id = :userId AND uc.actif = true")
    List<Centre> findCentresActifsByUtilisateur(@Param("userId") Integer userId);
}
