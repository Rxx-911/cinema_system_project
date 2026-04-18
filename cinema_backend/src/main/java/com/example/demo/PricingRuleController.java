package com.example.demo;

import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/rules")
@CrossOrigin(origins = "*")
public class PricingRuleController {

    private final PricingRuleRepository repo;

    public PricingRuleController(PricingRuleRepository repo) {
        this.repo = repo;
    }

    @GetMapping
    public List<PricingRule> getAll() {
        return repo.findAll();
    }

    @PutMapping("/{id}")
    public PricingRule update(@PathVariable Integer id, @RequestBody PricingRule rule) {
        rule.setId(id);
        return repo.save(rule);
    }
}