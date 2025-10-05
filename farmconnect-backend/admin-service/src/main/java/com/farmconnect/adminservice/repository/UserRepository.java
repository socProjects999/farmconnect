package com.farmconnect.adminservice.repository;

import com.farmconnect.adminservice.model.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

@Repository
public interface UserRepository extends JpaRepository<User, Long> {
    
    @Query("SELECT COUNT(u) FROM User u WHERE u.role = 'CUSTOMER'")
    Long countCustomers();
    
    @Query("SELECT COUNT(u) FROM User u WHERE u.role = 'FARMER'")
    Long countFarmers();
    
    @Query("SELECT COUNT(u) FROM User u WHERE u.role = 'RIDER'")
    Long countRiders();
}