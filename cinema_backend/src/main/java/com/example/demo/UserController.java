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

    // ⭐⭐⭐ 登录接口（关键修复）
    @PostMapping("/login")
    public String login(@RequestBody UserEntity user) {

        System.out.println("Login try: " + user.getUserId());

        UserEntity found = repo.findByUserId(user.getUserId());

        if (found != null) {
            System.out.println("DB user: " + found.getUserId());

            if (found.getPassword().equals(user.getPassword())) {
                return "success";
            }
        }

        return "Invalid username or password";
    }
}