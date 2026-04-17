package com.example.demo;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/rules")
public class PricingRuleController {

    @Autowired
    private PricingRuleRepository repo;

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