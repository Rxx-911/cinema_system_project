package com.example.demo;

import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;

import java.util.Map;
import java.util.NoSuchElementException;

@RestController
@RequestMapping("/tickets")
public class TicketController {

    private final BookingService bookingService;

    public TicketController(BookingService bookingService) {
        this.bookingService = bookingService;
    }

    // 订票：POST /tickets/book
    @PostMapping("/book")
    public Booking book(@RequestBody BookingRequest req) {
        return bookingService.book(req.seatId(), req.user());
    }

    // 退票：POST /tickets/refund
    @PostMapping("/refund")
    public Booking refund(@RequestBody RefundRequest req) {
        return bookingService.refund(req.bookingId());
    }

    // 查询订单：GET /tickets/order/{id}  （关键：避免和 /book 冲突）
    @GetMapping("/order/{id}")
    public Booking get(@PathVariable long id) {
        return bookingService.getBooking(id);
    }

    // ========= 统一错误返回（简洁版） =========

    @ExceptionHandler(IllegalArgumentException.class)
    @ResponseStatus(HttpStatus.BAD_REQUEST)
    public Map<String, Object> badRequest(Exception e) {
        return Map.of("error", e.getMessage());
    }

    @ExceptionHandler(NoSuchElementException.class)
    @ResponseStatus(HttpStatus.NOT_FOUND)
    public Map<String, Object> notFound(Exception e) {
        return Map.of("error", e.getMessage());
    }

    @ExceptionHandler(IllegalStateException.class)
    @ResponseStatus(HttpStatus.CONFLICT)
    public Map<String, Object> conflict(Exception e) {
        return Map.of("error", e.getMessage());
    }
}