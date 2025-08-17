package com.example.candidatureplus.service;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;

import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

@Service
public class ParametreService {

    private final JdbcTemplate jdbcTemplate;
    private final Map<String, String> cache = new ConcurrentHashMap<>();

    public ParametreService(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    public String getValeur(String cle, String valeurDefaut) {
        return cache.computeIfAbsent(cle, k -> {
            try {
                return jdbcTemplate.queryForObject("SELECT valeur FROM Parametre WHERE cle = ? AND actif = TRUE",
                        String.class, k);
            } catch (Exception ex) {
                return valeurDefaut;
            }
        });
    }

    public int getInt(String cle, int defaut) {
        try {
            return Integer.parseInt(getValeur(cle, String.valueOf(defaut)));
        } catch (NumberFormatException e) {
            return defaut;
        }
    }

    public boolean getBoolean(String cle, boolean defaut) {
        String v = getValeur(cle, String.valueOf(defaut));
        return "true".equalsIgnoreCase(v) || "1".equals(v);
    }

    public void recharger(String cle) {
        cache.remove(cle);
    }

    public void rechargerTout() {
        cache.clear();
    }
}
