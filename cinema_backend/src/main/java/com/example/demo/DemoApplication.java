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

    /// ⭐⭐⭐ 初始化完整电影排片数据（答辩版）
    @Bean
    CommandLineRunner initData(ShowingRepository repo) {
        return args -> {

            System.out.println("🔥 INIT DATA RUNNING");

            // ❗ 每次启动清空（保证数据一致）
            repo.deleteAll();

            /// 🎬 所有电影（和你前端保持一致）
            String[] movies = {
                "Inception",
                "Dune",
                "Zootopia",
                "Interstellar",
                "Avatar",
                "Avengers",
                "Harry Potter",
                "Forrest Gump"
            };

            /// 🎟 自动生成排片
            for (int i = 0; i < movies.length; i++) {

                ShowingEntity s = new ShowingEntity();

                s.setMovie(movies[i]);

                // 日期循环
                s.setDate("2026-04-" + (20 + i % 5));

                // 时间自动变化
                s.setTime((16 + i) + ":00");

                // 影厅循环
                s.setHall("Hall " + ((i % 3) + 1));

                // 价格递增
                s.setPrice(40.0 + i * 5);

                repo.save(s);
            }

            System.out.println("✅ INIT DONE: " + repo.count() + " showings inserted");
        };
    }
}