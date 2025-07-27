package com.example.candidatureplus.repository;

import com.example.candidatureplus.entity.Candidat;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.Optional;

@Repository
public interface CandidatRepository extends JpaRepository<Candidat, Integer> {
    
    Optional<Candidat> findByNumeroUnique(String numeroUnique);
    
    Optional<Candidat> findByCin(String cin);
    
    Optional<Candidat> findByEmail(String email);
    
    boolean existsByNumeroUnique(String numeroUnique);
    
    boolean existsByCin(String cin);
    
    boolean existsByEmail(String email);
}
