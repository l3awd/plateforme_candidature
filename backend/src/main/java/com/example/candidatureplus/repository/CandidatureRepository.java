package com.example.candidatureplus.repository;

import com.example.candidatureplus.entity.Candidature;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface CandidatureRepository extends JpaRepository<Candidature, Integer> {

        List<Candidature> findByCandidat_Id(Integer candidatId);

        List<Candidature> findByConcours_Id(Integer concoursId);

        List<Candidature> findByCentre_Id(Integer centreId);

        List<Candidature> findBySpecialite_Id(Integer specialiteId);

        List<Candidature> findByEtat(Candidature.Etat etat);

        boolean existsByCandidat_IdAndConcours_Id(Integer candidatId, Integer concoursId);

        @Query("SELECT c FROM Candidature c WHERE c.centre.id = :centreId AND c.etat = :etat")
        List<Candidature> findByCentreIdAndEtat(@Param("centreId") Integer centreId,
                        @Param("etat") Candidature.Etat etat);

        @Query("SELECT c FROM Candidature c WHERE c.concours.id = :concoursId AND c.specialite.id = :specialiteId")
        List<Candidature> findByConcoursIdAndSpecialiteId(@Param("concoursId") Integer concoursId,
                        @Param("specialiteId") Integer specialiteId);

        @Query("SELECT c FROM Candidature c WHERE c.centre.id = :centreId AND c.specialite.id = :specialiteId AND c.etat = :etat")
        List<Candidature> findByCentreIdAndSpecialiteIdAndEtat(
                        @Param("centreId") Integer centreId,
                        @Param("specialiteId") Integer specialiteId,
                        @Param("etat") Candidature.Etat etat);

        // Count methods for statistics
        long countByEtat(Candidature.Etat etat);

        long countByCentre_Id(Integer centreId);

        long countByCentre_IdAndEtat(Integer centreId, Candidature.Etat etat);

        // Nouvelles méthodes pour la validation avancée
        List<Candidature> findByCentreIdIn(List<Integer> centreIds);

        @Query("SELECT COUNT(c) FROM Candidature c WHERE c.concours.id = :concoursId AND c.specialite.id = :specialiteId AND c.centre.id = :centreId")
        long countByConcoursIdAndSpecialiteIdAndCentreId(@Param("concoursId") Integer concoursId,
                        @Param("specialiteId") Integer specialiteId,
                        @Param("centreId") Integer centreId);

        // Méthode pour filtrer avec des paramètres optionnels
        @Query("SELECT c FROM Candidature c WHERE " +
                        "(:concoursId IS NULL OR c.concours.id = :concoursId) AND " +
                        "(:specialiteId IS NULL OR c.specialite.id = :specialiteId) AND " +
                        "(:centreId IS NULL OR c.centre.id = :centreId) AND " +
                        "(:statut IS NULL OR CAST(c.etat AS string) = :statut)")
        List<Candidature> findWithFilters(@Param("concoursId") Long concoursId,
                        @Param("specialiteId") Long specialiteId,
                        @Param("centreId") Long centreId,
                        @Param("statut") String statut);

        @Query("SELECT c.gestionnaire.id, COUNT(c) FROM Candidature c WHERE c.gestionnaire IS NOT NULL GROUP BY c.gestionnaire.id")
        List<Object[]> countByGestionnaire();

        @Query("SELECT c.gestionnaire.id, c.etat, COUNT(c) FROM Candidature c WHERE c.gestionnaire IS NOT NULL GROUP BY c.gestionnaire.id, c.etat")
        List<Object[]> countByGestionnaireAndEtat();
}
