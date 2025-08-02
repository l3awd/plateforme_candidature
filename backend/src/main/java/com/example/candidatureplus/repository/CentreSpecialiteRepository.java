package com.example.candidatureplus.repository;

import com.example.candidatureplus.entity.CentreSpecialite;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import java.util.List;
import java.util.Optional;

@Repository
public interface CentreSpecialiteRepository extends JpaRepository<CentreSpecialite, Integer> {

    List<CentreSpecialite> findByCentre_Id(Integer centreId);

    List<CentreSpecialite> findBySpecialite_Id(Integer specialiteId);

    List<CentreSpecialite> findByConcours_Id(Integer concoursId);

    @Query("SELECT cs FROM CentreSpecialite cs WHERE cs.centre.id = :centreId AND cs.specialite.id = :specialiteId AND cs.concours.id = :concoursId")
    Optional<CentreSpecialite> findByCentreIdAndSpecialiteIdAndConcoursId(
            @Param("centreId") Integer centreId,
            @Param("specialiteId") Integer specialiteId,
            @Param("concoursId") Integer concoursId);

    @Query("SELECT cs FROM CentreSpecialite cs WHERE cs.centre.id = :centreId AND cs.concours.id = :concoursId")
    List<CentreSpecialite> findByCentreIdAndConcoursId(
            @Param("centreId") Integer centreId,
            @Param("concoursId") Integer concoursId);
}
