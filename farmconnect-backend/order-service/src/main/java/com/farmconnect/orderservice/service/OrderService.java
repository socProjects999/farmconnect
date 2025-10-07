package com.farmconnect.orderservice.service;

import com.farmconnect.orderservice.dto.OrderItemDTO;
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
        // Validate order request
        if (orderRequest.getCustomerId() == null) {
            throw new RuntimeException("Customer ID cannot be null");
        }
        if (orderRequest.getFarmerId() == null) {
            throw new RuntimeException("Farmer ID cannot be null");
        }
        if (orderRequest.getDeliveryAddress() == null || orderRequest.getDeliveryAddress().trim().isEmpty()) {
            throw new RuntimeException("Delivery address cannot be empty");
        }
        if (orderRequest.getOrderItems() == null || orderRequest.getOrderItems().isEmpty()) {
            throw new RuntimeException("Order must contain at least one item");
        }

        // Create order
        Order order = new Order();
        order.setCustomerId(orderRequest.getCustomerId());
        order.setFarmerId(orderRequest.getFarmerId());
        order.setDeliveryAddress(orderRequest.getDeliveryAddress());
        order.setCustomerNotes(orderRequest.getCustomerNotes());

        // Add order items and calculate total
        BigDecimal totalAmount = BigDecimal.ZERO;

        for (OrderItemDTO itemDTO : orderRequest.getOrderItems()) {
            // Validate each item
            if (itemDTO.getProductId() == null) {
                throw new RuntimeException("Product ID cannot be null");
            }
            if (itemDTO.getQuantity() == null || itemDTO.getQuantity() <= 0) {
                throw new RuntimeException("Quantity must be greater than 0");
            }
            if (itemDTO.getPriceAtPurchase() == null || itemDTO.getPriceAtPurchase().compareTo(BigDecimal.ZERO) <= 0) {
                throw new RuntimeException("Price must be greater than 0");
            }

            // Create order item
            OrderItem orderItem = new OrderItem();
            orderItem.setProductId(itemDTO.getProductId());
            orderItem.setQuantity(itemDTO.getQuantity());
            orderItem.setPriceAtPurchase(itemDTO.getPriceAtPurchase());

            // Calculate subtotal manually
            BigDecimal subtotal = itemDTO.getPriceAtPurchase()
                    .multiply(BigDecimal.valueOf(itemDTO.getQuantity()));
            orderItem.setSubtotal(subtotal);

            // Add to total
            totalAmount = totalAmount.add(subtotal);

            // Add item to order (this sets the bidirectional relationship)
            order.addOrderItem(orderItem);
        }

        order.setTotalAmount(totalAmount);

        // Save order (cascade will save order items)
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
                .orElseThrow(() -> new RuntimeException("Order not found with ID: " + orderId));
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

    @Transactional
    public OrderResponse updateOrderStatus(Long orderId, Order.OrderStatus status) {
        Order order = orderRepository.findById(orderId)
                .orElseThrow(() -> new RuntimeException("Order not found with ID: " + orderId));

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
                .orElseThrow(() -> new RuntimeException("Order not found with ID: " + orderId));

        if (order.getStatus() == Order.OrderStatus.DELIVERED ||
                order.getStatus() == Order.OrderStatus.SHIPPED) {
            throw new RuntimeException("Cannot cancel order that is already shipped or delivered");
        }

        order.setStatus(Order.OrderStatus.CANCELLED);
        orderRepository.save(order);
    }
}