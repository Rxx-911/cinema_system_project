package com.example.demo;

import org.springframework.data.jpa.repository.JpaRepository;

public interface UserRepository extends JpaRepository<UserEntity, Integer> {

    // ⭐ 用 userId 查（关键）
    UserEntity findByUserId(String userId);
}