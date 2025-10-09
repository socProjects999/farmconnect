import React, { useState, useEffect } from "react";
import { Link } from "react-router-dom";
import { useAuth } from "../../context/AuthContext";
import orderService from "../../services/orderService";
import { toast } from "react-toastify";
import "../../styles/Dashboard.css";

const RiderDashboard = () => {
  const [stats, setStats] = useState({
    totalOrders: 0,
    pendingOrders: 0,
    completedOrders: 0,
    inProgressOrders: 0,
  });
  const [allOrders, setAllOrders] = useState([]);
  const [loading, setLoading] = useState(true);

  const { user } = useAuth();

  useEffect(() => {
    fetchOrders();
  }, []);

  const fetchOrders = async () => {
    try {
      const token = localStorage.getItem("token");
      const orders = await orderService.getAllOrders(token);

      const pending = orders.filter(
        (o) => o.status === "PENDING" || o.status === "ASSIGNED"
      ).length;
      const completed = orders.filter(
        (o) => o.status === "DELIVERED" || o.status === "COMPLETED"
      ).length;
      const inProgress = orders.filter(
        (o) => o.status === "PICKED_UP" || o.status === "IN_TRANSIT"
      ).length;

      setStats({
        totalOrders: orders.length,
        pendingOrders: pending,
        completedOrders: completed,
        inProgressOrders: inProgress,
      });

      setAllOrders(orders);
    } catch (error) {
      toast.error("Failed to load orders");
      console.error("Dashboard error:", error);
    } finally {
      setLoading(false);
    }
  };

  const handleAddDelivery = async (orderId) => {
    try {
      const token = localStorage.getItem("token");
      await orderService.assignRiderToOrder(orderId, user.userId, token);
      toast.success("Order added to your deliveries!");
      fetchOrders();
    } catch (error) {
      console.error("Error assigning delivery:", error);
      toast.error("Failed to add delivery");
    }
  };

  const getStatusColor = (status) => {
    const colors = {
      PENDING: "#6c757d",
      ASSIGNED: "#ffc107",
      PICKED_UP: "#17a2b8",
      IN_TRANSIT: "#007bff",
      DELIVERED: "#28a745",
      COMPLETED: "#28a745",
      FAILED: "#dc3545",
      CANCELLED: "#6c757d",
      UNKNOWN: "#adb5bd",
    };
    return colors[status] || "#6c757d";
  };

  if (loading) {
    return (
      <div className="loading-container">
        <h2>Loading dashboard...</h2>
      </div>
    );
  }

  return (
    <div className="dashboard-container">
      <div className="dashboard-header">
        <h1>Rider Dashboard</h1>
        <p>Welcome back, {user.fullName}!</p>
      </div>

      {/* --- Stats Section --- */}
      <div className="stats-grid">
        <div className="stat-card">
          <div className="stat-icon" style={{ backgroundColor: "#17a2b8" }}>
            📦
          </div>
          <div className="stat-info">
            <h3>{stats.totalOrders}</h3>
            <p>All Orders</p>
          </div>
        </div>

        <div className="stat-card">
          <div className="stat-icon" style={{ backgroundColor: "#ffc107" }}>
            ⏳
          </div>
          <div className="stat-info">
            <h3>{stats.pendingOrders}</h3>
            <p>Pending Orders</p>
          </div>
        </div>

        <div className="stat-card">
          <div className="stat-icon" style={{ backgroundColor: "#007bff" }}>
            🚚
          </div>
          <div className="stat-info">
            <h3>{stats.inProgressOrders}</h3>
            <p>In Progress</p>
          </div>
        </div>

        <div className="stat-card">
          <div className="stat-icon" style={{ backgroundColor: "#28a745" }}>
            ✅
          </div>
          <div className="stat-info">
            <h3>{stats.completedOrders}</h3>
            <p>Completed Orders</p>
          </div>
        </div>
      </div>

      {/* --- Orders List Section --- */}
      <div className="recent-section">
        <h2>All Orders</h2>
        {allOrders.length === 0 ? (
          <p className="no-data">No orders available.</p>
        ) : (
          <div className="recent-orders">
            {allOrders.map((order) => {
              const status = order.status || "UNKNOWN";
              return (
                <div key={order.id} className="recent-order-card">
                  <div className="order-header-simple">
                    <span className="order-id-simple">Order #{order.id}</span>
                    <span
                      className="order-status-simple"
                      style={{ backgroundColor: getStatusColor(status) }}
                    >
                      {status.replace(/_/g, " ")}
                    </span>
                  </div>

                  <div className="order-details-simple">
                    {order.customerName && (
                      <span>Customer: {order.customerName}</span>
                    )}
                    {order.deliveryAddress && (
                      <span>Address: {order.deliveryAddress}</span>
                    )}
                    {order.createdAt && (
                      <span>
                        Date: {new Date(order.createdAt).toLocaleDateString()}
                      </span>
                    )}
                  </div>

                  <div className="dashboard-actions">
                    {order.riderId ? (
                      <span className="badge bg-success">Already Assigned</span>
                    ) : (
                      <button
                        className="action-button primary"
                        onClick={() => handleAddDelivery(order.id)}
                      >
                        Add as My Delivery
                      </button>
                    )}
                  </div>

                  <Link
                    to={`/rider/orders/${order.id}`}
                    className="view-order-link"
                  >
                    View Details →
                  </Link>
                </div>
              );
            })}
          </div>
        )}
      </div>
    </div>
  );
};

export default RiderDashboard;
