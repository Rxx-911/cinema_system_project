package com.example.demo;

import jakarta.persistence.*;

@Entity
@Table(name = "seat")
public class SeatEntity {
    public enum Type {
        ORDINARY,
        VIP
    }
    public enum Status {
        AVAILABLE,
        LOCKED
    }
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private int id;

    @Column(name = "hall_id")
    private int hallId;

    @Column(name = "row_num")
    private int rowNum;

    @Column(name = "col_num")
    private int colNum;

    private Type type;
    private Status status;

    public int getId() { return id; }
    public int getHallId() { return hallId; }
    public int getRowNum() { return rowNum; }
    public int getColNum() { return colNum; }
    public Type getType() { return type; }
    public String getStatus() { return status; }

    public void setHallId(int hallId) { this.hallId = hallId; }
    public void setRowNum(int rowNum) { this.rowNum = rowNum; }
    public void setColNum(int colNum) { this.colNum = colNum; }
    public void setType(Type type) { this.type = type; }
    public void setStatus(Status status) { this.status = status; }
}
