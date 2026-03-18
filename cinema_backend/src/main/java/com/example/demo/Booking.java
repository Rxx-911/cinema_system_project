package com.example.demo;

public class Booking {

    private long id;
    private long seatId;
    private String user;

    public Booking(long id, long seatId, String user) {
        this.id = id;
        this.seatId = seatId;
        this.user = user;
    }

    public long getId() {
        return id;
    }

    public long getSeatId() {
        return seatId;
    }

    public String getUser() {
        return user;
    }
}