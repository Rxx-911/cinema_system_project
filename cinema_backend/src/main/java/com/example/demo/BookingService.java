package com.example.demo;

import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.Map;
import java.util.NoSuchElementException;

//@Service
public class BookingService {

    private final Map<Long, Booking> bookings = new HashMap<>();
    private long nextId = 1;

    public Booking book(long seatId, String user) {

        Booking booking = new Booking(nextId++, seatId, user);
        bookings.put(booking.getId(), booking);

        return booking;
    }

    public Booking refund(long bookingId) {

        Booking booking = bookings.remove(bookingId);

        if (booking == null) {
            throw new NoSuchElementException("Booking not found");
        }

        return booking;
    }

    public Booking getBooking(long id) {

        Booking booking = bookings.get(id);

        if (booking == null) {
            throw new NoSuchElementException("Booking not found");
        }

        return booking;
    }
}