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

    // Gets all seats of a hall
    @GetMapping("/halls/{hallId}/seats")
    public List<SeatEntity> getSeatsByHall(@PathVariable int hallId) {
        return seatRepository.findByHallId(hallId);
    }

    // Lock seat.
    @PostMapping("/seats/{id}/lock")
    public SeatEntity lockSeat(@PathVariable int id) {

        SeatEntity seat = seatRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Seat not found"));

        if (seat.getStatus() != SeatEntity.Status.AVAILABLE)) {
            throw new RuntimeException("Seat is not available.");
        }

        seat.setStatus(SeatEntity.Status.LOCKED);
        return seatRepository.save(seat);
    }

    // Release seat.
    @PostMapping("/seats/{id}/release")
    public SeatEntity releaseSeat(@PathVariable int id) {
        SeatEntity seat = seatRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Seat not found"));

        if (seat.getStatus() != SeatEntity.Status.LOCKED)) {
            throw new RuntimeException("Seat is not locked.");
        }

        seat.setStatus(SeatEntity.Status.AVAILABLE);
        return seatRepository.save(seat);
    }
}
