package com.example.candidatureplus.repository;

import com.example.candidatureplus.entity.Centre;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface CentreRepository extends JpaRepository<Centre, Integer> {

    List<Centre> findByActifTrue();

    List<Centre> findByVille(String ville);

    @Query("SELECT c, cc.placesDisponibles FROM Centre c " +
            "JOIN ConcoursCentre cc ON c.id = cc.centre.id " +
            "WHERE cc.concours.id = :concoursId")
    List<Object[]> findCentresByConcoursId(@Param("concoursId") Integer concoursId);
}
