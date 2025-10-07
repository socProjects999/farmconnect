package com.farmconnect.adminservice.service;

import com.farmconnect.adminservice.dto.DashboardStatistics;
import com.farmconnect.adminservice.model.Order;
import com.farmconnect.adminservice.model.Product;
import com.farmconnect.adminservice.model.User;
import com.farmconnect.adminservice.repository.OrderRepository;
import com.farmconnect.adminservice.repository.ProductRepository;
import com.farmconnect.adminservice.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.util.List;

@Service
public class AdminService {

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private ProductRepository productRepository;

    @Autowired
    private OrderRepository orderRepository;

    public DashboardStatistics getDashboardStatistics() {
        DashboardStatistics stats = new DashboardStatistics();

        // User statistics
        stats.setTotalUsers(userRepository.count());
        stats.setTotalCustomers(userRepository.countCustomers());
        stats.setTotalFarmers(userRepository.countFarmers());
        stats.setTotalRiders(userRepository.countRiders());

        // Product statistics
        stats.setTotalProducts(productRepository.count());
        stats.setAvailableProducts(productRepository.countByIsAvailableTrue());

        // Order statistics
        stats.setTotalOrders(orderRepository.count());
        stats.setPendingOrders(orderRepository.countByStatus(Order.OrderStatus.PENDING));
        stats.setDeliveredOrders(orderRepository.countByStatus(Order.OrderStatus.DELIVERED));

        // Revenue statistics
        BigDecimal totalRevenue = orderRepository.getTotalRevenue();
        BigDecimal deliveredRevenue = orderRepository.getDeliveredOrdersRevenue();
        
        stats.setTotalRevenue(totalRevenue != null ? totalRevenue : BigDecimal.ZERO);
        stats.setDeliveredRevenue(deliveredRevenue != null ? deliveredRevenue : BigDecimal.ZERO);

        return stats;
    }

    public List<User> getAllUsers() {
        return userRepository.findAll();
    }

    public List<Product> getAllProducts() {
        return productRepository.findAll();
    }

    public List<Order> getAllOrders() {
        return orderRepository.findAll();
    }

    public void deleteUser(Long userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found!"));
        
        if (user.getRole() == User.Role.ADMIN) {
            throw new RuntimeException("Cannot delete admin user!");
        }
        
        userRepository.delete(user);
    }

    public void deleteProduct(Long productId) {
        Product product = productRepository.findById(productId)
                .orElseThrow(() -> new RuntimeException("Product not found!"));
        productRepository.delete(product);
    }

    public User getUserById(Long userId) {
        return userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found!"));
    }

    public Product getProductById(Long productId) {
        return productRepository.findById(productId)
                .orElseThrow(() -> new RuntimeException("Product not found!"));
    }

    public Order getOrderById(Long orderId) {
        return orderRepository.findById(orderId)
                .orElseThrow(() -> new RuntimeException("Order not found!"));
    }
}