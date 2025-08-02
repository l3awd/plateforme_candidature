package com.example.candidatureplus.repository;

import com.example.candidatureplus.entity.Notification;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface NotificationRepository extends JpaRepository<Notification, Integer> {

        List<Notification> findByTypeDestinataire(Notification.TypeDestinataire typeDestinataire);

        List<Notification> findByDestinataireId(Integer destinataireId);

        List<Notification> findByEtat(Notification.Etat etat);

        // Nouvelle méthode pour chercher par type de destinataire ET ID de destinataire
        List<Notification> findByTypeDestinataireAndDestinataireId(
                        Notification.TypeDestinataire typeDestinataire, Integer destinataireId);

        // Nouvelle méthode pour compter par état
        long countByEtat(Notification.Etat etat);

        @Query("SELECT n FROM Notification n WHERE n.typeDestinataire = :typeDestinataire AND n.destinataireId = :destinataireId ORDER BY n.dateCreation DESC")
        List<Notification> findByTypeDestinataireAndDestinataireIdOrderByDateCreationDesc(
                        @Param("typeDestinataire") Notification.TypeDestinataire typeDestinataire,
                        @Param("destinataireId") Integer destinataireId);

        @Query("SELECT n FROM Notification n WHERE n.etat = :etat AND n.tentativesEnvoi < 3")
        List<Notification> findByEtatAndTentativesEnvoiLessThan(
                        @Param("etat") Notification.Etat etat);
}
