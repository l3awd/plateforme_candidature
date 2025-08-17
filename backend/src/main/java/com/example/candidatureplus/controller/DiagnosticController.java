package com.example.candidatureplus.controller;

import com.example.candidatureplus.repository.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import jakarta.servlet.http.HttpSession;
import javax.sql.DataSource;
import java.sql.Connection;
import java.sql.DatabaseMetaData;
import java.sql.ResultSet;
import java.util.*;

@RestController
@RequestMapping("/api/diagnostic")
@CrossOrigin(origins = "http://localhost:3000")
public class DiagnosticController {

    @Autowired
    private CandidatRepository candidatRepository;

    @Autowired
    private UtilisateurRepository utilisateurRepository;

    @Autowired
    private CentreRepository centreRepository;

    @Autowired
    private ConcoursRepository concoursRepository;

    @Autowired
    private SpecialiteRepository specialiteRepository;

    @Autowired
    private CandidatureRepository candidatureRepository;

    @Autowired
    private DocumentRepository documentRepository;

    @Autowired
    private LogActionRepository logActionRepository;

    @Autowired
    private NotificationRepository notificationRepository;

    @Autowired
    private DataSource dataSource;

    /**
     * Diagnostic complet de la base de données
     */
    @GetMapping("/database")
    public ResponseEntity<Map<String, Object>> diagnosticDatabase(HttpSession session) {
        try {
            // Vérifier l'authentification admin
            Integer userId = (Integer) session.getAttribute("userId");
            if (userId == null) {
                return ResponseEntity.status(401).build();
            }

            Map<String, Object> diagnostic = new HashMap<>();

            // 1. Informations générales
            diagnostic.put("timestamp", System.currentTimeMillis());
            diagnostic.put("database", getDatabaseInfo());

            // 2. Comptages des tables
            diagnostic.put("tableCounts", getTableCounts());

            // 3. Vérifications critiques
            diagnostic.put("criticalChecks", getCriticalChecks());

            // 4. Vérification des relations
            diagnostic.put("relationChecks", getRelationChecks());

            // 5. Problèmes détectés
            diagnostic.put("issues", getDetectedIssues());

            // 6. Recommandations
            diagnostic.put("recommendations", getRecommendations());

            return ResponseEntity.ok(diagnostic);
        } catch (Exception e) {
            e.printStackTrace();
            Map<String, Object> error = new HashMap<>();
            error.put("error", "Erreur lors du diagnostic: " + e.getMessage());
            return ResponseEntity.badRequest().body(error);
        }
    }

    /**
     * Diagnostic rapide - statut général
     */
    @GetMapping("/status")
    public ResponseEntity<Map<String, Object>> getStatus() {
        try {
            Map<String, Object> status = new HashMap<>();

            // Comptages rapides
            status.put("candidats", candidatRepository.count());
            status.put("utilisateurs", utilisateurRepository.count());
            status.put("centres", centreRepository.count());
            status.put("concours", concoursRepository.count());
            status.put("specialites", specialiteRepository.count());
            status.put("candidatures", candidatureRepository.count());

            // Statut critique
            long adminActifs = utilisateurRepository.findAll().stream()
                    .filter(u -> u.getRole().toString().equals("Administrateur") && u.getActif())
                    .count();

            long concoursActifs = concoursRepository.findByActifTrue().size();
            long centresActifs = centreRepository.findByActifTrue().size();
            long specialitesActives = specialiteRepository.findByActifTrue().size();

            status.put("adminsActifs", adminActifs);
            status.put("concoursActifs", concoursActifs);
            status.put("centresActifs", centresActifs);
            status.put("specialitesActives", specialitesActives);

            // Statut général
            boolean healthy = adminActifs > 0 && concoursActifs > 0 && centresActifs > 0 && specialitesActives > 0;
            status.put("healthy", healthy);
            status.put("status", healthy ? "OK" : "WARNING");

            return ResponseEntity.ok(status);
        } catch (Exception e) {
            e.printStackTrace();
            Map<String, Object> error = new HashMap<>();
            error.put("status", "ERROR");
            error.put("error", e.getMessage());
            return ResponseEntity.badRequest().body(error);
        }
    }

    /**
     * Vérification de tables spécifiques
     */
    @GetMapping("/tables")
    public ResponseEntity<Map<String, Object>> checkTables() {
        try {
            Map<String, Object> tableInfo = new HashMap<>();

            try (Connection conn = dataSource.getConnection()) {
                DatabaseMetaData metaData = conn.getMetaData();

                // Tables attendues
                String[] expectedTables = {
                        "Candidat", "Utilisateur", "Centre", "Concours", "Specialite",
                        "Candidature", "Document", "LogAction", "Notification",
                        "ConcoursSpecialite", "ConcoursCentre", "CentreSpecialite"
                };

                Map<String, Boolean> tableExists = new HashMap<>();
                Map<String, Long> tableRows = new HashMap<>();

                for (String tableName : expectedTables) {
                    // Vérifier existence
                    ResultSet rs = metaData.getTables(null, null, tableName, new String[] { "TABLE" });
                    boolean exists = rs.next();
                    tableExists.put(tableName, exists);

                    if (exists) {
                        // Compter les lignes via repository
                        long count = getTableRowCount(tableName);
                        tableRows.put(tableName, count);
                    }
                    rs.close();
                }

                tableInfo.put("existence", tableExists);
                tableInfo.put("rowCounts", tableRows);
                tableInfo.put("expectedTables", Arrays.asList(expectedTables));

                // Tables manquantes
                List<String> missingTables = new ArrayList<>();
                for (Map.Entry<String, Boolean> entry : tableExists.entrySet()) {
                    if (!entry.getValue()) {
                        missingTables.add(entry.getKey());
                    }
                }
                tableInfo.put("missingTables", missingTables);
            }

            return ResponseEntity.ok(tableInfo);
        } catch (Exception e) {
            e.printStackTrace();
            Map<String, Object> error = new HashMap<>();
            error.put("error", "Erreur lors de la vérification des tables: " + e.getMessage());
            return ResponseEntity.badRequest().body(error);
        }
    }

    /**
     * Diagnostic des données incohérentes
     */
    @GetMapping("/inconsistencies")
    public ResponseEntity<Map<String, Object>> checkInconsistencies() {
        try {
            Map<String, Object> inconsistencies = new HashMap<>();

            // Candidatures orphelines
            long candidaturesSansCandidat = candidatureRepository.findAll().stream()
                    .filter(c -> c.getCandidat() == null)
                    .count();

            long candidaturesSansConcours = candidatureRepository.findAll().stream()
                    .filter(c -> c.getConcours() == null)
                    .count();

            long candidaturesSansCentre = candidatureRepository.findAll().stream()
                    .filter(c -> c.getCentre() == null)
                    .count();

            long candidaturesSansSpecialite = candidatureRepository.findAll().stream()
                    .filter(c -> c.getSpecialite() == null)
                    .count();

            // Utilisateurs problématiques
            long gestionnairesSansCentre = utilisateurRepository.findAll().stream()
                    .filter(u -> u.getRole().toString().equals("GestionnaireLocal") && u.getCentre() == null)
                    .count();

            // Doublons emails
            Map<String, Long> emailCounts = new HashMap<>();
            utilisateurRepository.findAll().forEach(u -> {
                String email = u.getEmail();
                emailCounts.put(email, emailCounts.getOrDefault(email, 0L) + 1);
            });
            long emailDoublons = emailCounts.values().stream().filter(count -> count > 1).count();

            inconsistencies.put("candidaturesSansCandidat", candidaturesSansCandidat);
            inconsistencies.put("candidaturesSansConcours", candidaturesSansConcours);
            inconsistencies.put("candidaturesSansCentre", candidaturesSansCentre);
            inconsistencies.put("candidaturesSansSpecialite", candidaturesSansSpecialite);
            inconsistencies.put("gestionnairesSansCentre", gestionnairesSansCentre);
            inconsistencies.put("emailDoublons", emailDoublons);

            // Score de santé
            long totalProblems = candidaturesSansCandidat + candidaturesSansConcours +
                    candidaturesSansCentre + candidaturesSansSpecialite +
                    gestionnairesSansCentre + emailDoublons;

            inconsistencies.put("totalProblems", totalProblems);
            inconsistencies.put("healthScore", totalProblems == 0 ? 100 : Math.max(0, 100 - (totalProblems * 10)));

            return ResponseEntity.ok(inconsistencies);
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.badRequest().build();
        }
    }

    /**
     * Suggestions de réparation
     */
    @GetMapping("/repair-suggestions")
    public ResponseEntity<List<Map<String, Object>>> getRepairSuggestions() {
        try {
            List<Map<String, Object>> suggestions = new ArrayList<>();

            // Vérifier et suggérer des réparations
            long adminCount = utilisateurRepository.findAll().stream()
                    .filter(u -> u.getRole().toString().equals("Administrateur") && u.getActif())
                    .count();

            if (adminCount == 0) {
                Map<String, Object> suggestion = new HashMap<>();
                suggestion.put("priority", "HIGH");
                suggestion.put("type", "MISSING_ADMIN");
                suggestion.put("description", "Aucun administrateur actif trouvé");
                suggestion.put("action", "Créer un utilisateur administrateur");
                suggestion.put("sql",
                        "INSERT INTO Utilisateur (nom, prenom, email, mot_de_passe, role, actif, date_creation) VALUES ('Admin', 'System', 'admin@candidature.ma', 'admin123', 'Administrateur', 1, NOW());");
                suggestions.add(suggestion);
            }

            long concoursActifs = concoursRepository.findByActifTrue().size();
            if (concoursActifs == 0) {
                Map<String, Object> suggestion = new HashMap<>();
                suggestion.put("priority", "MEDIUM");
                suggestion.put("type", "NO_ACTIVE_CONCOURS");
                suggestion.put("description", "Aucun concours actif");
                suggestion.put("action", "Activer ou créer des concours");
                suggestions.add(suggestion);
            }

            long centresActifs = centreRepository.findByActifTrue().size();
            if (centresActifs == 0) {
                Map<String, Object> suggestion = new HashMap<>();
                suggestion.put("priority", "MEDIUM");
                suggestion.put("type", "NO_ACTIVE_CENTRES");
                suggestion.put("description", "Aucun centre actif");
                suggestion.put("action", "Activer ou créer des centres d'examen");
                suggestions.add(suggestion);
            }

            return ResponseEntity.ok(suggestions);
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.badRequest().build();
        }
    }

    /**
     * Liste des gestionnaires avec informations essentielles pour debug
     */
    @GetMapping("/gestionnaires")
    public ResponseEntity<List<Map<String, Object>>> listerGestionnaires() {
        try {
            List<Map<String, Object>> gestionnaires = utilisateurRepository.findAll().stream()
                    .filter(u -> u.getRole() != null && (u.getRole().toString().startsWith("Gestionnaire")
                            || u.getRole().toString().equals("Administrateur")))
                    .map(u -> {
                        Map<String, Object> m = new HashMap<>();
                        m.put("id", u.getId());
                        m.put("nom", u.getNom());
                        m.put("prenom", u.getPrenom());
                        m.put("email", u.getEmail());
                        m.put("role", u.getRole().toString());
                        m.put("centreId", u.getCentre() != null ? u.getCentre().getId() : null);
                        m.put("centreNom", u.getCentre() != null ? u.getCentre().getNom() : null);
                        m.put("actif", u.getActif());
                        m.put("derniereConnexion", u.getDerniereConnexion());
                        // Mot de passe non renvoyé pour sécurité (même si en clair).
                        return m;
                    }).toList();
            return ResponseEntity.ok(gestionnaires);
        } catch (Exception e) {
            return ResponseEntity.badRequest().build();
        }
    }

    // Méthodes utilitaires

    private Map<String, Object> getDatabaseInfo() {
        Map<String, Object> info = new HashMap<>();
        try (Connection conn = dataSource.getConnection()) {
            DatabaseMetaData metaData = conn.getMetaData();
            info.put("databaseProductName", metaData.getDatabaseProductName());
            info.put("databaseProductVersion", metaData.getDatabaseProductVersion());
            info.put("url", metaData.getURL());
            info.put("userName", metaData.getUserName());
        } catch (Exception e) {
            info.put("error", e.getMessage());
        }
        return info;
    }

    private Map<String, Long> getTableCounts() {
        Map<String, Long> counts = new HashMap<>();
        counts.put("candidats", candidatRepository.count());
        counts.put("utilisateurs", utilisateurRepository.count());
        counts.put("centres", centreRepository.count());
        counts.put("concours", concoursRepository.count());
        counts.put("specialites", specialiteRepository.count());
        counts.put("candidatures", candidatureRepository.count());
        counts.put("documents", documentRepository.count());
        counts.put("logs", logActionRepository.count());
        counts.put("notifications", notificationRepository.count());
        return counts;
    }

    private Map<String, Object> getCriticalChecks() {
        Map<String, Object> checks = new HashMap<>();

        long adminActifs = utilisateurRepository.findAll().stream()
                .filter(u -> u.getRole().toString().equals("Administrateur") && u.getActif())
                .count();
        checks.put("adminActifs", adminActifs);

        long concoursActifs = concoursRepository.findByActifTrue().size();
        checks.put("concoursActifs", concoursActifs);

        long centresActifs = centreRepository.findByActifTrue().size();
        checks.put("centresActifs", centresActifs);

        long specialitesActives = specialiteRepository.findByActifTrue().size();
        checks.put("specialitesActives", specialitesActives);

        return checks;
    }

    private Map<String, Object> getRelationChecks() {
        Map<String, Object> relations = new HashMap<>();
        // À implémenter selon les besoins
        return relations;
    }

    private List<String> getDetectedIssues() {
        List<String> issues = new ArrayList<>();

        long adminCount = utilisateurRepository.findAll().stream()
                .filter(u -> u.getRole().toString().equals("Administrateur") && u.getActif())
                .count();
        if (adminCount == 0) {
            issues.add("Aucun administrateur actif");
        }

        if (concoursRepository.findByActifTrue().isEmpty()) {
            issues.add("Aucun concours actif");
        }

        if (centreRepository.findByActifTrue().isEmpty()) {
            issues.add("Aucun centre actif");
        }

        return issues;
    }

    private List<String> getRecommendations() {
        List<String> recommendations = new ArrayList<>();

        if (getDetectedIssues().contains("Aucun administrateur actif")) {
            recommendations.add("Créer un compte administrateur");
        }

        if (getDetectedIssues().contains("Aucun concours actif")) {
            recommendations.add("Ajouter des concours avec dates valides");
        }

        if (candidatureRepository.count() == 0) {
            recommendations.add("Système prêt pour recevoir des candidatures");
        }

        return recommendations;
    }

    private long getTableRowCount(String tableName) {
        switch (tableName) {
            case "Candidat":
                return candidatRepository.count();
            case "Utilisateur":
                return utilisateurRepository.count();
            case "Centre":
                return centreRepository.count();
            case "Concours":
                return concoursRepository.count();
            case "Specialite":
                return specialiteRepository.count();
            case "Candidature":
                return candidatureRepository.count();
            case "Document":
                return documentRepository.count();
            case "LogAction":
                return logActionRepository.count();
            case "Notification":
                return notificationRepository.count();
            default:
                return 0;
        }
    }
}
