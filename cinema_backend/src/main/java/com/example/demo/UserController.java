package com.example.demo;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/users")
@CrossOrigin(origins = "*")
public class UserController {

    @Autowired
    private UserRepository userRepository;

    // 注册
    @PostMapping("/register")
    public String register(@RequestBody UserEntity user) {

        System.out.println("USER: " + user.getUsername());

        if (userRepository.findByUsername(user.getUsername()) != null) {
            return "Username already exists";
        }

        userRepository.save(user);
        return "Register success";
    }

    // 登录
    @PostMapping("/login")
    public String login(@RequestBody UserEntity user) {

        UserEntity dbUser = userRepository.findByUsername(user.getUsername());

        if (dbUser == null) {
            return "User not found";
        }

        if (!dbUser.getPassword().equals(user.getPassword())) {
            return "Wrong password";
        }

        return "Login success";
    }
}