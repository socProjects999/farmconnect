package com.farmconnect.adminservice.repository;

import com.farmconnect.adminservice.model.Product;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface ProductRepository extends JpaRepository<Product, Long> {
    
    Long countByIsAvailableTrue();
}