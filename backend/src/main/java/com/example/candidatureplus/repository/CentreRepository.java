package com.example.candidatureplus.repository;

import com.example.candidatureplus.entity.Centre;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface CentreRepository extends JpaRepository<Centre, Integer> {
    
    List<Centre> findByActifTrue();
    
    List<Centre> findByVille(String ville);
}
