package com.example.candidatureplus.repository;

import com.example.candidatureplus.entity.ConcoursCentre;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface ConcoursCentreRepository extends JpaRepository<ConcoursCentre, Integer> {

    List<ConcoursCentre> findByConcoursId(Integer concoursId);

    List<ConcoursCentre> findByCentreId(Integer centreId);

    @Query("SELECT cc FROM ConcoursCentre cc WHERE cc.concours.id = :concoursId AND cc.centre.id = :centreId")
    ConcoursCentre findByConcoursIdAndCentreId(@Param("concoursId") Integer concoursId,
            @Param("centreId") Integer centreId);

    @Query("SELECT cc.centre FROM ConcoursCentre cc WHERE cc.concours.id = :concoursId")
    List<com.example.candidatureplus.entity.Centre> findCentresByConcoursId(@Param("concoursId") Integer concoursId);
}
