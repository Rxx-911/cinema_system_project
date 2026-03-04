package com.example.demo;

import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface SeatRepository extends JpaRepository<SeatEntity, Long> {

    List<SeatEntity> findByHallId(Long hallId);
}