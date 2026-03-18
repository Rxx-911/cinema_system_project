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

    // 选座（锁座）
    @PostMapping("/seats/{id}/lock")
    public SeatEntity lockSeat(@PathVariable long id) {

        SeatEntity seat = seatRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Seat not found"));

        if (!"AVAILABLE".equals(seat.getStatus())) {
            throw new RuntimeException("Seat is not available");
        }

        seat.setStatus("LOCKED");
        return seatRepository.save(seat);
    }

    // 取消选座（解锁）
    @PostMapping("/seats/{id}/unlock")
    public SeatEntity unlockSeat(@PathVariable long id) {

        SeatEntity seat = seatRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Seat not found"));

        if (!"LOCKED".equals(seat.getStatus())) {
            throw new RuntimeException("Seat is not locked");
        }

        seat.setStatus("AVAILABLE");
        return seatRepository.save(seat);
    }

    // 确认订票
    @PostMapping("/seats/{id}/book")
    public SeatEntity bookSeat(@PathVariable long id) {

        SeatEntity seat = seatRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Seat not found"));

        if (!"LOCKED".equals(seat.getStatus())) {
            throw new RuntimeException("Seat must be locked before booking");
        }

        seat.setStatus("BOOKED");
        return seatRepository.save(seat);
    }

    // 退票
    @PostMapping("/seats/{id}/refund")
    public SeatEntity refundSeat(@PathVariable long id) {

        SeatEntity seat = seatRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Seat not found"));

        if (!"BOOKED".equals(seat.getStatus())) {
            throw new RuntimeException("Seat is not booked");
        }

        seat.setStatus("AVAILABLE");
        return seatRepository.save(seat);
    }
}