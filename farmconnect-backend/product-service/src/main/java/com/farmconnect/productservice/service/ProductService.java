package com.farmconnect.productservice.service;

import org.springframework.beans.factory.annotation.Autowired;
import com.farmconnect.productservice.dto.ProductRequest;
import com.farmconnect.productservice.dto.ProductResponse;
import com.farmconnect.productservice.model.Product;
import com.farmconnect.productservice.repository.ProductRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service
public class ProductService {

    @Autowired
    private ProductRepository productRepository;

    @Autowired
    private FileStorageService fileStorageService;

    public ProductResponse updateProductImage(Long productId, String imageUrl) {
    Product product = productRepository.findById(productId)
            .orElseThrow(() -> new RuntimeException("Product not found!"));
    
    // Delete old image if exists
    if (product.getImageUrl() != null && !product.getImageUrl().isEmpty()) {
        String oldFileName = extractFileNameFromUrl(product.getImageUrl());
        if (oldFileName != null) {
            fileStorageService.deleteFile(oldFileName);
        }
    }
    
        product.setImageUrl(imageUrl);
        Product updatedProduct = productRepository.save(product);
        return new ProductResponse(updatedProduct);
    }

    // Helper method to extract filename from URL
    private String extractFileNameFromUrl(String url) {
        if (url == null || url.isEmpty()) {
            return null;
        }
        int lastSlashIndex = url.lastIndexOf('/');
        if (lastSlashIndex != -1 && lastSlashIndex < url.length() - 1) {
            return url.substring(lastSlashIndex + 1);
        }
        return null;
    }
    
    public ProductResponse createProduct(ProductRequest productRequest) {
        Product product = new Product();
        product.setFarmerId(productRequest.getFarmerId());
        product.setProductName(productRequest.getProductName());
        product.setDescription(productRequest.getDescription());
        product.setPrice(productRequest.getPrice());
        product.setQuantityAvailable(productRequest.getQuantityAvailable());
        product.setCategory(productRequest.getCategory());
        product.setImageUrl(productRequest.getImageUrl());
        product.setIsAvailable(productRequest.getIsAvailable());

        Product savedProduct = productRepository.save(product);
        return new ProductResponse(savedProduct);
    }

    public List<ProductResponse> getAllProducts() {
        return productRepository.findAll().stream()
                .map(ProductResponse::new)
                .collect(Collectors.toList());
    }

    public List<ProductResponse> getAvailableProducts() {
        return productRepository.findByIsAvailableTrue().stream()
                .map(ProductResponse::new)
                .collect(Collectors.toList());
    }

    public ProductResponse getProductById(Long productId) {
        Product product = productRepository.findById(productId)
                .orElseThrow(() -> new RuntimeException("Product not found!"));
        return new ProductResponse(product);
    }

    public List<ProductResponse> getProductsByFarmer(Long farmerId) {
        return productRepository.findByFarmerId(farmerId).stream()
                .map(ProductResponse::new)
                .collect(Collectors.toList());
    }

    public List<ProductResponse> searchProducts(String keyword) {
        return productRepository.findByProductNameContainingIgnoreCase(keyword).stream()
                .map(ProductResponse::new)
                .collect(Collectors.toList());
    }

    public List<ProductResponse> getProductsByCategory(String category) {
        return productRepository.findByCategory(category).stream()
                .map(ProductResponse::new)
                .collect(Collectors.toList());
    }

    public ProductResponse updateProduct(Long productId, ProductRequest productRequest) {
        Product product = productRepository.findById(productId)
                .orElseThrow(() -> new RuntimeException("Product not found!"));

        product.setProductName(productRequest.getProductName());
        product.setDescription(productRequest.getDescription());
        product.setPrice(productRequest.getPrice());
        product.setQuantityAvailable(productRequest.getQuantityAvailable());
        product.setCategory(productRequest.getCategory());
        product.setImageUrl(productRequest.getImageUrl());
        product.setIsAvailable(productRequest.getIsAvailable());

        Product updatedProduct = productRepository.save(product);
        return new ProductResponse(updatedProduct);
    }

    public void deleteProduct(Long productId) {
        Product product = productRepository.findById(productId)
                .orElseThrow(() -> new RuntimeException("Product not found!"));
        productRepository.delete(product);
    }

    public void updateProductQuantity(Long productId, Integer quantity) {
        Product product = productRepository.findById(productId)
                .orElseThrow(() -> new RuntimeException("Product not found!"));
        product.setQuantityAvailable(quantity);
        productRepository.save(product);
    }
}