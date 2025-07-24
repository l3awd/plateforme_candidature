package com.example.candidatureplus.controller;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class WebController {

    @GetMapping("/")
    public String home(Model model) {
        model.addAttribute("message", "Bienvenue sur CandidaturePlus");
        model.addAttribute("description", "Plateforme de gestion des candidatures");
        return "index";
    }

    @GetMapping("/login")
    public String login() {
        return "login";
    }
}
