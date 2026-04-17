package com.example.demo;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/orders")
@CrossOrigin(origins = "*")
public class OrderController {

    @Autowired
    private OrderRepository orderRepository;

    @PostMapping("/create")
    public String createOrder(@RequestBody OrderEntity order) {
        order.setStatus("PAID");
        orderRepository.save(order);
        return "Order created successfully";
    }

    @GetMapping("/{username}")
    public List<OrderEntity> getOrdersByUsername(@PathVariable String username) {
        return orderRepository.findByUsername(username);
    }

    @PostMapping("/refund/{id}")
    public String refundOrder(@PathVariable Integer id) {
        OrderEntity order = orderRepository.findById(id).orElse(null);

        if (order == null) {
            return "Order not found";
        }

        order.setStatus("REFUNDED");
        orderRepository.save(order);
        return "Refund success";
    }
}