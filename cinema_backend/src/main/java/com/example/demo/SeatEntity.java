package com.example.demo;

import jakarta.persistence.*;

@Entity
@Table(name = "seat")
public class SeatEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "hall_id")
    private Long hallId;

    @Column(name = "row_num")
    private Integer rowNum;

    @Column(name = "col_num")
    private Integer colNum;

    private String type;
    private String status;

    public Long getId() { return id; }
    public Long getHallId() { return hallId; }
    public Integer getRowNum() { return rowNum; }
    public Integer getColNum() { return colNum; }
    public String getType() { return type; }
    public String getStatus() { return status; }

    public void setHallId(Long hallId) { this.hallId = hallId; }
    public void setRowNum(Integer rowNum) { this.rowNum = rowNum; }
    public void setColNum(Integer colNum) { this.colNum = colNum; }
    public void setType(String type) { this.type = type; }
    public void setStatus(String status) { this.status = status; }
}