package com.farmconnect.orderservice.service;

import com.farmconnect.orderservice.dto.OrderRequest;
import com.farmconnect.orderservice.dto.OrderResponse;
import com.farmconnect.orderservice.model.Delivery;
import com.farmconnect.orderservice.model.Order;
import com.farmconnect.orderservice.model.OrderItem;
import com.farmconnect.orderservice.repository.DeliveryRepository;
import com.farmconnect.orderservice.repository.OrderRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.List;
import java.util.stream.Collectors;

@Service
public class OrderService {

    @Autowired
    private OrderRepository orderRepository;

    @Autowired
    private DeliveryRepository deliveryRepository;

    @Transactional
    public OrderResponse createOrder(OrderRequest orderRequest) {
        // Create order
        Order order = new Order();
        order.setCustomerId(orderRequest.getCustomerId());
        order.setFarmerId(orderRequest.getFarmerId());
        order.setDeliveryAddress(orderRequest.getDeliveryAddress());
        order.setCustomerNotes(orderRequest.getCustomerNotes());

        // Add order items
        BigDecimal totalAmount = BigDecimal.ZERO;
        for (var itemDTO : orderRequest.getOrderItems()) {
            OrderItem orderItem = new OrderItem(
                    itemDTO.getProductId(),
                    itemDTO.getQuantity(),
                    itemDTO.getPriceAtPurchase()
            );
            orderItem.calculateSubtotal();
            order.addOrderItem(orderItem);
            totalAmount = totalAmount.add(orderItem.getSubtotal());
        }

        order.setTotalAmount(totalAmount);

        // Save order
        Order savedOrder = orderRepository.save(order);

        // Create delivery record
        Delivery delivery = new Delivery(savedOrder.getOrderId());
        deliveryRepository.save(delivery);

        return new OrderResponse(savedOrder);
    }

    public List<OrderResponse> getAllOrders() {
        return orderRepository.findAll().stream()
                .map(OrderResponse::new)
                .collect(Collectors.toList());
    }

    public OrderResponse getOrderById(Long orderId) {
        Order order = orderRepository.findById(orderId)
                .orElseThrow(() -> new RuntimeException("Order not found!"));
        return new OrderResponse(order);
    }

    public List<OrderResponse> getOrdersByCustomer(Long customerId) {
        return orderRepository.findByCustomerIdOrderByOrderDateDesc(customerId).stream()
                .map(OrderResponse::new)
                .collect(Collectors.toList());
    }

    public List<OrderResponse> getOrdersByFarmer(Long farmerId) {
        return orderRepository.findByFarmerIdOrderByOrderDateDesc(farmerId).stream()
                .map(OrderResponse::new)
                .collect(Collectors.toList());
    }

    public OrderResponse updateOrderStatus(Long orderId, Order.OrderStatus status) {
        Order order = orderRepository.findById(orderId)
                .orElseThrow(() -> new RuntimeException("Order not found!"));
        
        order.setStatus(status);
        Order updatedOrder = orderRepository.save(order);
        
        return new OrderResponse(updatedOrder);
    }

    public List<OrderResponse> getOrdersByStatus(Order.OrderStatus status) {
        return orderRepository.findByStatus(status).stream()
                .map(OrderResponse::new)
                .collect(Collectors.toList());
    }

    @Transactional
    public void cancelOrder(Long orderId) {
        Order order = orderRepository.findById(orderId)
                .orElseThrow(() -> new RuntimeException("Order not found!"));
        
        if (order.getStatus() == Order.OrderStatus.DELIVERED || 
            order.getStatus() == Order.OrderStatus.SHIPPED) {
            throw new RuntimeException("Cannot cancel order that is already shipped or delivered!");
        }
        
        order.setStatus(Order.OrderStatus.CANCELLED);
        orderRepository.save(order);
    }
}