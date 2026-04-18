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

    // 注册用户
    @PostMapping
    public UserEntity create(@RequestBody UserEntity user) {
        return repo.save(user);
    }

    // 登录接口
@PostMapping("/login")
public String login(@RequestBody UserEntity user) {

    List<UserEntity> users = repo.findAll();

    for (UserEntity u : users) {
        if (u.getUsername().equals(user.getUsername()) &&
            u.getPassword().equals(user.getPassword())) {
            return "success";
        }
    }

    return "Invalid username or password";
}

}