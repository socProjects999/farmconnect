-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Oct 05, 2025 at 07:19 PM
-- Generation Time: Oct 07, 2025 at 07:50 PM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `farmconnect_db`
--

-- --------------------------------------------------------

--
-- Table structure for table `deliveries`
--

CREATE TABLE `deliveries` (
  `delivery_id` bigint(20) NOT NULL,
  `order_id` bigint(20) NOT NULL,
  `rider_id` bigint(20) DEFAULT NULL,
  `assigned_at` timestamp NULL DEFAULT NULL,
  `pickup_time` timestamp NULL DEFAULT NULL,
  `delivery_time` timestamp NULL DEFAULT NULL,
  `status` enum('PENDING','ASSIGNED','PICKED_UP','IN_TRANSIT','DELIVERED','FAILED') DEFAULT 'PENDING',
  `delivery_notes` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `deliveries`
--

INSERT INTO `deliveries` (`delivery_id`, `order_id`, `rider_id`, `assigned_at`, `pickup_time`, `delivery_time`, `status`, `delivery_notes`) VALUES
(1, 1, NULL, NULL, NULL, NULL, 'PENDING', NULL),
(2, 2, NULL, NULL, NULL, NULL, 'PENDING', NULL),
(3, 3, NULL, NULL, NULL, NULL, 'PENDING', NULL),
(4, 4, NULL, NULL, NULL, NULL, 'PENDING', NULL),
(5, 5, NULL, NULL, NULL, NULL, 'PENDING', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `orders`
--

CREATE TABLE `orders` (
  `order_id` bigint(20) NOT NULL,
  `customer_id` bigint(20) NOT NULL,
  `farmer_id` bigint(20) NOT NULL,
  `total_amount` decimal(38,2) DEFAULT NULL,
  `status` enum('PENDING','CONFIRMED','PREPARING','READY_FOR_DELIVERY','SHIPPED','DELIVERED','CANCELLED') DEFAULT 'PENDING',
  `order_date` timestamp NOT NULL DEFAULT current_timestamp(),
  `delivery_address` text NOT NULL,
  `customer_notes` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `orders`
--

INSERT INTO `orders` (`order_id`, `customer_id`, `farmer_id`, `total_amount`, `status`, `order_date`, `delivery_address`, `customer_notes`) VALUES
(1, 5, 2, 680.00, 'CONFIRMED', '2025-10-02 06:37:23', 'No 45, Galle Road, Colombo 07', 'Please deliver before 6 PM'),
(2, 5, 2, 680.00, 'PENDING', '2025-10-03 01:00:07', 'No 123, Main Street, Colombo 07', 'Please call before delivery'),
(3, 12, 2, 180.00, 'PENDING', '2025-10-03 05:10:09', 'abc road, colombo', ''),
(4, 12, 2, 200.00, 'DELIVERED', '2025-10-03 05:13:28', 'gvytcytcyvy', ''),
(5, 12, 2, 340.00, 'PENDING', '2025-10-05 16:58:40', 'sfdvsdvsfs', '');

-- --------------------------------------------------------

--
-- Table structure for table `order_items`
--

CREATE TABLE `order_items` (
  `order_item_id` bigint(20) NOT NULL,
  `order_id` bigint(20) NOT NULL,
  `product_id` bigint(20) NOT NULL,
  `quantity` int(11) NOT NULL,
  `price_at_purchase` decimal(10,2) NOT NULL,
  `subtotal` decimal(10,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `order_items`
--

INSERT INTO `order_items` (`order_item_id`, `order_id`, `product_id`, `quantity`, `price_at_purchase`, `subtotal`) VALUES
(1, 1, 1, 2, 250.00, 500.00),
(2, 1, 2, 1, 180.00, 180.00),
(3, 2, 1, 2, 250.00, 500.00),
(4, 2, 2, 1, 180.00, 180.00),
(5, 3, 2, 1, 180.00, 180.00),
(6, 4, 3, 1, 200.00, 200.00),
(7, 5, 12, 1, 340.00, 340.00);

-- --------------------------------------------------------

--
-- Table structure for table `products`
--

CREATE TABLE `products` (
  `product_id` bigint(20) NOT NULL,
  `farmer_id` bigint(20) NOT NULL,
  `product_name` varchar(255) NOT NULL,
  `description` text DEFAULT NULL,
  `price` decimal(38,2) DEFAULT NULL,
  `quantity_available` int(11) NOT NULL DEFAULT 0,
  `category` varchar(100) DEFAULT NULL,
  `image_url` varchar(500) DEFAULT NULL,
  `is_available` tinyint(1) DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `products`
--

INSERT INTO `products` (`product_id`, `farmer_id`, `product_name`, `description`, `price`, `quantity_available`, `category`, `image_url`, `is_available`, `created_at`, `updated_at`) VALUES
(1, 2, 'Fresh Tomatoes', 'Organically grown fresh tomatoes', 250.00, 50, 'Vegetables', 'https://example.com/tomatoes.jpg', 1, '2025-10-02 06:37:00', '2025-10-02 06:37:00'),
(2, 2, 'Green Beans', 'Fresh green beans from the farm', 180.00, 30, 'Vegetables', 'https://example.com/beans.jpg', 1, '2025-10-02 06:37:00', '2025-10-02 06:37:00'),
(3, 2, 'Carrots', 'Sweet and crunchy carrots', 200.00, 40, 'Vegetables', 'https://example.com/carrots.jpg', 1, '2025-10-02 06:37:00', '2025-10-02 06:37:00'),
(4, 3, 'Bananas', 'Naturally ripened Ambul bananas', 150.00, 100, 'Fruits', 'https://example.com/bananas.jpg', 1, '2025-10-02 06:37:00', '2025-10-02 06:37:00'),
(5, 3, 'Papaya', 'Sweet and juicy papayas', 220.00, 25, 'Fruits', 'https://example.com/papaya.jpg', 1, '2025-10-02 06:37:00', '2025-10-02 06:37:00'),
(6, 3, 'Mangoes', 'Delicious ripe mangoes', 400.00, 20, 'Fruits', 'https://example.com/mangoes.jpg', 1, '2025-10-02 06:37:00', '2025-10-02 06:37:00'),
(7, 4, 'Fresh Milk', 'Pure cow milk, delivered fresh daily', 180.00, 50, 'Dairy', 'https://example.com/milk.jpg', 1, '2025-10-02 06:37:00', '2025-10-02 06:37:00'),
(8, 4, 'Farm Eggs', 'Free-range chicken eggs (12 pack)', 450.00, 30, 'Eggs', 'https://example.com/eggs.jpg', 1, '2025-10-02 06:37:00', '2025-10-02 06:37:00'),
(9, 4, 'Organic Honey', 'Pure natural honey from our farm', 850.00, 15, 'Other', 'https://example.com/honey.jpg', 1, '2025-10-02 06:37:00', '2025-10-02 06:37:00'),
(10, 2, 'Organic Tomatoes', 'Fresh organic tomatoes', 250.00, 100, 'Vegetables', 'http://example.com/tomato.jpg', 1, '2025-10-03 00:31:50', '2025-10-03 00:31:50'),
(11, 13, 'Potatoes', 'ilubfyuwbclwbcwd', 560.00, 50, 'Vegetables', 'https://www.google.com/url?sa=i&url=https%3A%2F%2Fwww.lovefoodhatewaste.com%2Ffoods-and-recipes%2Fpotatoes&psig=AOvVaw1ay7lVHs919oGgIzEgrxan&ust=1759555177591000&source=images&cd=vfe&opi=89978449&ved=0CBUQjRxqFwoTCNCIkvyjh5ADFQAAAAAdAAAAABAE', 1, '2025-10-03 05:20:01', '2025-10-03 05:20:01'),
(12, 2, 'Fresh Tomatoes 2', 'tomaotoes with fresh ', 340.00, 24, 'Vegetables', 'http://localhost:8082/uploads/products/bb1a6883-6f6c-406f-a754-8bb11c84674c.jpeg', 1, '2025-10-05 16:57:02', '2025-10-05 16:57:02');

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `user_id` bigint(20) NOT NULL,
  `email` varchar(255) NOT NULL,
  `password` varchar(255) NOT NULL,
  `full_name` varchar(255) NOT NULL,
  `role` enum('CUSTOMER','FARMER','RIDER','ADMIN') NOT NULL,
  `phone_number` varchar(20) DEFAULT NULL,
  `address` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`user_id`, `email`, `password`, `full_name`, `role`, `phone_number`, `address`, `created_at`) VALUES
(1, 'admin@farmconnect.com', '$2a$12$Dqmy/0.xaRbkavZm79SUd.5im5ox661qQrU194.LM97hzQKBdAvoe', 'System Administrator', 'ADMIN', '0771234567', 'FarmConnect HQ, Colombo', '2025-10-02 06:34:38'),
(2, 'farmer1@gmail.com', '$2a$12$8HYw.1e6VaNcjN5WppRlDeD45C4rcQT9833uJxDAvCTy90imRXV3O', 'Kamal Perera', 'FARMER', '0712345678', 'Kegalle, Sri Lanka', '2025-10-02 06:35:47'),
(3, 'farmer2@gmail.com', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'Nimal Silva', 'FARMER', '0723456789', 'Kandy, Sri Lanka', '2025-10-02 06:35:47'),
(4, 'farmer3@gmail.com', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'Sunil Fernando', 'FARMER', '0734567890', 'Anuradhapura, Sri Lanka', '2025-10-02 06:35:47'),
(5, 'customer1@gmail.com', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'Saman Kumara', 'CUSTOMER', '0745678901', 'Colombo 07, Sri Lanka', '2025-10-02 06:36:04'),
(6, 'customer2@gmail.com', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'Chamari De Silva', 'CUSTOMER', '0756789012', 'Nugegoda, Sri Lanka', '2025-10-02 06:36:04'),
(7, 'rider1@gmail.com', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'Kasun Rajapaksa', 'RIDER', '0767890123', 'Maharagama, Sri Lanka', '2025-10-02 06:36:16'),
(8, 'rider2@gmail.com', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'Ruwan Bandara', 'RIDER', '0778901234', 'Dehiwala, Sri Lanka', '2025-10-02 06:36:16'),
(11, 'newfarmer@gmail.com', '$2a$10$exEv5JQ5jrBbS0uF4LodnuzPejlFS/qv4fDbSZ8A3D35WesXEKRAS', 'New Test Farmer', 'FARMER', '0771111111', 'Kandy, Sri Lanka', '2025-10-03 03:06:54'),
(12, 'janith@gmail.com', '$2a$10$tIdlaxt.CKIar6iHrI0F0OLHBT1qT9nCdLFOYzJylZ6.4QT6hE1TC', 'Janith Thiwanka', 'CUSTOMER', '0770123456', '123/4, ABC Road, Gampaha', '2025-10-03 05:08:48'),
(13, 'farmer11@test.com', '$2a$10$k7azsTIlYXZ6r4zXtx2JGu1CvYBes5guuUG4d1Xnz8emFhmZPcrDK', 'farmer@test.com', 'FARMER', '0741597532', 'test, colombo', '2025-10-03 05:18:04'),
(14, 'testfarmer123@gmail.com', '$2a$10$UT30SY8q8yf1i2MP4IpBTelRHVUBKe3Kd5ywleH0atThRXEOhqaUW', 'Test Farmer', 'FARMER', '0771234567', 'Colombo, Sri Lanka', '2025-10-05 11:21:06');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `deliveries`
--
ALTER TABLE `deliveries`
  ADD PRIMARY KEY (`delivery_id`),
  ADD UNIQUE KEY `order_id` (`order_id`),
  ADD KEY `idx_rider` (`rider_id`),
  ADD KEY `idx_status` (`status`);

--
-- Indexes for table `orders`
--
ALTER TABLE `orders`
  ADD PRIMARY KEY (`order_id`),
  ADD KEY `idx_customer` (`customer_id`),
  ADD KEY `idx_farmer` (`farmer_id`),
  ADD KEY `idx_status` (`status`),
  ADD KEY `idx_order_date` (`order_date`);

--
-- Indexes for table `order_items`
--
ALTER TABLE `order_items`
  ADD PRIMARY KEY (`order_item_id`),
  ADD KEY `idx_order` (`order_id`),
  ADD KEY `idx_product` (`product_id`);

--
-- Indexes for table `products`
--
ALTER TABLE `products`
  ADD PRIMARY KEY (`product_id`),
  ADD KEY `idx_farmer` (`farmer_id`),
  ADD KEY `idx_category` (`category`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `email` (`email`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `deliveries`
--
ALTER TABLE `deliveries`
  MODIFY `delivery_id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `orders`
--
ALTER TABLE `orders`
  MODIFY `order_id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `order_items`
--
ALTER TABLE `order_items`
  MODIFY `order_item_id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT for table `products`
--
ALTER TABLE `products`
  MODIFY `product_id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `user_id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=15;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `deliveries`
--
ALTER TABLE `deliveries`
  ADD CONSTRAINT `deliveries_ibfk_1` FOREIGN KEY (`order_id`) REFERENCES `orders` (`order_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `deliveries_ibfk_2` FOREIGN KEY (`rider_id`) REFERENCES `users` (`user_id`) ON DELETE SET NULL;

--
-- Constraints for table `orders`
--
ALTER TABLE `orders`
  ADD CONSTRAINT `orders_ibfk_1` FOREIGN KEY (`customer_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `orders_ibfk_2` FOREIGN KEY (`farmer_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE;

--
-- Constraints for table `order_items`
--
ALTER TABLE `order_items`
  ADD CONSTRAINT `order_items_ibfk_1` FOREIGN KEY (`order_id`) REFERENCES `orders` (`order_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `order_items_ibfk_2` FOREIGN KEY (`product_id`) REFERENCES `products` (`product_id`) ON DELETE CASCADE;

--
-- Constraints for table `products`
--
ALTER TABLE `products`
  ADD CONSTRAINT `products_ibfk_1` FOREIGN KEY (`farmer_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
