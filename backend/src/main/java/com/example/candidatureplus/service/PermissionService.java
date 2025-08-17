package com.example.candidatureplus.service;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;

import java.util.HashSet;
import java.util.List;
import java.util.Set;
import java.util.concurrent.ConcurrentHashMap;

@Service
public class PermissionService {

    private final JdbcTemplate jdbcTemplate;
    private final ConcurrentHashMap<String, Set<String>> rolePermissionsCache = new ConcurrentHashMap<>();

    public PermissionService(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    private Set<String> loadPermissionsForRole(String role) {
        List<String> codes = jdbcTemplate.queryForList(
                "SELECT p.code FROM Permission p JOIN Role_Permission rp ON p.id = rp.permission_id WHERE rp.role = ? AND p.actif = TRUE",
                String.class, role);
        return new HashSet<>(codes);
    }

    public boolean roleHas(String role, String permissionCode) {
        if (role == null)
            return false;
        Set<String> perms = rolePermissionsCache.computeIfAbsent(role, this::loadPermissionsForRole);
        return perms.contains(permissionCode);
    }

    public void evictRole(String role) {
        rolePermissionsCache.remove(role);
    }

    public void evictAll() {
        rolePermissionsCache.clear();
    }
}
