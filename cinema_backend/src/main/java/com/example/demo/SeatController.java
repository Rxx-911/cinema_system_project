package com.example.demo;

import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api")
@CrossOrigin
public class SeatController {

    private final SeatRepository seatRepository;

    public SeatController(SeatRepository seatRepository) {
        this.seatRepository = seatRepository;
    }

    // 获取某个影厅的所有座位
    @GetMapping("/halls/{hallId}/seats")
    public List<SeatEntity> getSeatsByHall(@PathVariable Long hallId) {
        return seatRepository.findByHallId(hallId);
    }

    // 锁座接口
    @PostMapping("/seats/{id}/lock")
    public SeatEntity lockSeat(@PathVariable Long id) {

        SeatEntity seat = seatRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Seat not found"));

        if (!seat.getStatus().equals("AVAILABLE")) {
            throw new RuntimeException("Seat is not available");
        }

        seat.setStatus("LOCKED");
        return seatRepository.save(seat);
    }
}