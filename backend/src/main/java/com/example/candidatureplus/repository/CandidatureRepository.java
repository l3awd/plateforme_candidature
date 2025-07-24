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
    
    List<Candidature> findByEtat(Candidature.Etat etat);
    
    @Query("SELECT c FROM Candidature c WHERE c.centre.id = :centreId AND c.etat = :etat")
    List<Candidature> findByCentreIdAndEtat(@Param("centreId") Integer centreId, @Param("etat") Candidature.Etat etat);
    
    boolean existsByCandidat_IdAndConcours_Id(Integer candidatId, Integer concoursId);
}
