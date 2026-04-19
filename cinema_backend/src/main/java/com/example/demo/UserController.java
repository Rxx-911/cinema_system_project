package com.example.demo;

import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/users")
@CrossOrigin(origins = "*")
public class UserController {

    private final UserRepository repo;

    public UserController(UserRepository repo) {
        this.repo = repo;
    }

    // 获取所有用户
    @GetMapping
    public List<UserEntity> getAll() {
        return repo.findAll();
    }

    // 注册
    @PostMapping
    public UserEntity create(@RequestBody UserEntity user) {
        return repo.save(user);
    }

   @PostMapping("/login")
        public String login(@RequestBody UserEntity user) {

            UserEntity dbUser = repo.findByUserId(user.getUserId());

            if (dbUser == null) {
                return "User not found";
            }

            if (!dbUser.getPassword().equals(user.getPassword())) {
                return "Invalid username or password";
            }

            return "Login success";
        }
    }