package com.example.demo;

import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/orders")
@CrossOrigin(origins = "*")
public class OrderController {

    private final OrderRepository repo;

    public OrderController(OrderRepository repo) {
        this.repo = repo;
    }

    // 获取所有订单
    @GetMapping
    public List<OrderEntity> getAll() {
        return repo.findAll();
    }

    // 创建订单（购票）
    @PostMapping
    public OrderEntity create(@RequestBody OrderEntity order) {
        order.setStatus("CONFIRMED"); // 简单模拟下单成功
        return repo.save(order);
    }
}