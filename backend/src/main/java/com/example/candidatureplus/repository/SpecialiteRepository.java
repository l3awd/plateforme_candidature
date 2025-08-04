package com.example.candidatureplus.repository;

import com.example.candidatureplus.entity.Specialite;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import java.util.List;
import java.util.Optional;

@Repository
public interface SpecialiteRepository extends JpaRepository<Specialite, Integer> {

    List<Specialite> findByActifTrue();

    Optional<Specialite> findByCode(String code);

    boolean existsByCode(String code);

    @Query("SELECT s, cs.nombrePlaces FROM Specialite s " +
            "JOIN ConcoursSpecialite cs ON s.id = cs.specialite.id " +
            "WHERE cs.concours.id = :concoursId")
    List<Object[]> findSpecialitesByConcoursId(@Param("concoursId") Integer concoursId);
}
