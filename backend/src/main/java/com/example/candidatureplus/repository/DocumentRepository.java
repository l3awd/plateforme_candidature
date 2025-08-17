package com.example.candidatureplus.repository;

import com.example.candidatureplus.entity.Document;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface DocumentRepository extends JpaRepository<Document, Integer> {

    List<Document> findByCandidature_Id(Integer candidatureId);

    List<Document> findByTypeDocument(Document.TypeDocument typeDocument);

    boolean existsByCandidature_IdAndTypeDocument(Integer candidatureId, Document.TypeDocument typeDocument);

    List<Document> findByCinTemp(String cinTemp);

    void deleteByCinTemp(String cinTemp);
}
