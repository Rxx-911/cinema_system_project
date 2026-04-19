package com.example.demo;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Bean;
import org.springframework.boot.CommandLineRunner;

@SpringBootApplication
public class DemoApplication {

    public static void main(String[] args) {
        SpringApplication.run(DemoApplication.class, args);
    }

    /// ⭐⭐⭐ 初始化数据（必须有）
    @Bean
    CommandLineRunner initData(ShowingRepository repo) {
        return args -> {

            System.out.println("🔥 INIT DATA RUNNING");

            repo.deleteAll(); // 清空旧数据（防止冲突）

            ShowingEntity s1 = new ShowingEntity();
            s1.setMovie("Inception");
            s1.setDate("2026-04-20");
            s1.setTime("18:00");
            s1.setHall("Hall 1");
            s1.setPrice(50.0);

            ShowingEntity s2 = new ShowingEntity();
            s2.setMovie("Dune");
            s2.setDate("2026-04-20");
            s2.setTime("20:00");
            s2.setHall("Hall 2");
            s2.setPrice(60.0);

            ShowingEntity s3 = new ShowingEntity();
            s3.setMovie("Zootopia");
            s3.setDate("2026-04-21");
            s3.setTime("16:00");
            s3.setHall("Hall 3");
            s3.setPrice(40.0);

            repo.save(s1);
            repo.save(s2);
            repo.save(s3);
        };
    }
}