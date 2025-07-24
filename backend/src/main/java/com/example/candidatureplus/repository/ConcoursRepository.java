package com.example.candidatureplus.repository;

import com.example.candidatureplus.entity.Concours;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;
import java.time.LocalDate;
import java.util.List;

@Repository
public interface ConcoursRepository extends JpaRepository<Concours, Integer> {
    
    List<Concours> findByActifTrue();
    
    @Query("SELECT c FROM Concours c WHERE c.dateDebutCandidature <= :date AND c.dateFinCandidature >= :date AND c.actif = true")
    List<Concours> findConcoursActifs(LocalDate date);
    
    @Query("SELECT c FROM Concours c WHERE c.dateFinCandidature < :date")
    List<Concours> findConcoursFermes(LocalDate date);
}
