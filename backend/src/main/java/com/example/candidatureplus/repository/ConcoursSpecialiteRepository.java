package com.example.candidatureplus.repository;

import com.example.candidatureplus.entity.ConcoursSpecialite;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface ConcoursSpecialiteRepository extends JpaRepository<ConcoursSpecialite, Integer> {

    List<ConcoursSpecialite> findByConcoursId(Integer concoursId);

    List<ConcoursSpecialite> findBySpecialiteId(Integer specialiteId);

    @Query("SELECT cs FROM ConcoursSpecialite cs WHERE cs.concours.id = :concoursId AND cs.specialite.id = :specialiteId")
    ConcoursSpecialite findByConcoursIdAndSpecialiteId(@Param("concoursId") Integer concoursId,
            @Param("specialiteId") Integer specialiteId);

    @Query("SELECT cs.specialite FROM ConcoursSpecialite cs WHERE cs.concours.id = :concoursId")
    List<com.example.candidatureplus.entity.Specialite> findSpecialitesByConcoursId(
            @Param("concoursId") Integer concoursId);
}
