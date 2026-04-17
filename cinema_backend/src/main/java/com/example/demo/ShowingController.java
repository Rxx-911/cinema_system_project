/*
package com.example.demo;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/showings")
@CrossOrigin(origins = "*")
public class ShowingController {

    @Autowired
    private ShowingRepository repo;

    @GetMapping
    public List<ShowingEntity> getAll() {
        return repo.findAll();
    }

    @PostMapping
    public ShowingEntity create(@RequestBody ShowingEntity showing) {
        return repo.save(showing);
    }

    @DeleteMapping("/{id}")
    public void delete(@PathVariable Integer id) {
        repo.deleteById(id);
    }
}
*/