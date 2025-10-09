import axios from "axios";

<<<<<<< Updated upstream
const API_URL = 'http://localhost:8083/api/deliveries';
=======
//const API_URL = '/api/deliveries';
const API_URL = "http://localhost:8083/api/deliveries";
>>>>>>> Stashed changes

const deliveryService = {
  // Get delivery by order ID
  getDeliveryByOrderId: async (orderId, token) => {
    const response = await axios.get(`${API_URL}/order/${orderId}`, {
      headers: { Authorization: `Bearer ${token}` },
    });
    return response.data;
  },

  // Get deliveries by rider
  getDeliveriesByRider: async (riderId, token) => {
    const response = await axios.get(`${API_URL}/rider/${riderId}`, {
      headers: { Authorization: `Bearer ${token}` },
    });
    return response.data;
  },

  // Get pending deliveries
  getPendingDeliveries: async (token) => {
    const response = await axios.get(`${API_URL}/pending`, {
      headers: { Authorization: `Bearer ${token}` },
    });
    return response.data;
  },

  // Get all deliveries
  getAllDeliveries: async (token) => {
    const response = await axios.get(API_URL, {
      headers: { Authorization: `Bearer ${token}` },
    });
    return response.data;
  },

  // **Create a new delivery for an order**
  createDelivery: async (orderId, riderId, token) => {
    const response = await axios.post(
      API_URL,
      { orderId, riderId }, // send orderId and riderId in body
      { headers: { Authorization: `Bearer ${token}` } }
    );
    return response.data;
  },

  // Assign rider to existing delivery
  assignRider: async (deliveryId, riderId, token) => {
    const response = await axios.put(
      `${API_URL}/${deliveryId}/assign?riderId=${riderId}`,
      {},
      { headers: { Authorization: `Bearer ${token}` } }
    );
    return response.data;
  },

  // Update delivery status
  updateDeliveryStatus: async (deliveryId, status, token) => {
    const response = await axios.put(
      `${API_URL}/${deliveryId}/status?status=${status}`,
      {},
      { headers: { Authorization: `Bearer ${token}` } }
    );
    return response.data;
  },
};

export default deliveryService;
