import axios from 'axios';
import { BackendEndpoints } from '../utils/backendEndpoints';

// API Configuration
const BASE_URL = BackendEndpoints.BASE_URL;
const IMG_URL = BackendEndpoints.IMG_URL;

// Create axios instance
const api = axios.create({
  baseURL: BASE_URL,
  timeout: 30000,
  headers: {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  },
});

// Request interceptor to add auth token
api.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem('token');
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error) => {
    return Promise.reject(error);
  }
);

// Response interceptor to handle common errors
api.interceptors.response.use(
  (response) => {
    return response;
  },
  (error) => {
    if (error.response?.status === 401) {
      // Token expired or invalid
      // Don't redirect to login if on booking page to prevent page closure
      if (window.location.pathname !== '/booking') {
        localStorage.removeItem('token');
        localStorage.removeItem('user_mobile');
        window.location.href = '/login';
      }
    }
    return Promise.reject(error);
  }
);

// API Service class
class ApiService {
  // Authentication APIs
  async sendOtp(data) {
    try {
      const response = await api.post(BackendEndpoints.SEND_OTP, data);
      return response.data;
    } catch (error) {
      throw this.handleError(error);
    }
  }

  async sendOtpForRegistration(data) {
    try {
      const response = await api.post(BackendEndpoints.REGISTER, data);
      return response.data;
    } catch (error) {
      throw this.handleError(error);
    }
  }

  async verifyOtp(data) {
    try {
      const response = await api.post(BackendEndpoints.VERIFY_OTP, data);
      return response.data;
    } catch (error) {
      throw this.handleError(error);
    }
  }

  async register(data) {
    try {
      const response = await api.post(BackendEndpoints.REGISTER, data);
      return response.data;
    } catch (error) {
      throw this.handleError(error);
    }
  }

  async logout() {
    try {
      const response = await api.post(BackendEndpoints.LOGOUT);
      return response.data;
    } catch (error) {
      throw this.handleError(error);
    }
  }

  // Home APIs
  async getHomeData(data) {
    try {
      const response = await api.post(BackendEndpoints.GET_HOME, data);
      return response.data;
    } catch (error) {
      throw this.handleError(error);
    }
  }

  // Package and Test APIs
  async getPackages() {
    try {
      const response = await api.get(BackendEndpoints.GET_PACKAGE_LIST);
      return response.data;
    } catch (error) {
      throw this.handleError(error);
    }
  }

  async getLabTests() {
    try {
      const response = await api.get(BackendEndpoints.GET_LAB_TEST_LIST);
      return response.data;
    } catch (error) {
      throw this.handleError(error);
    }
  }

  async getTestProfile(testId) {
    try {
      const response = await api.get(`${BackendEndpoints.GET_TEST_PROFILE}?test_id=${testId}`);
      return response.data;
    } catch (error) {
      throw this.handleError(error);
    }
  }

  // Patient APIs
  async addPatient(patientData) {
    try {
      const response = await api.post(BackendEndpoints.ADD_PATIENT, patientData);
      return response.data;
    } catch (error) {
      throw this.handleError(error);
    }
  }

  async getPatientList() {
    try {
      const response = await api.get(BackendEndpoints.GET_PATIENT_LIST);
      return response.data;
    } catch (error) {
      throw this.handleError(error);
    }
  }

  // Lab APIs
  async getLabList() {
    try {
      const response = await api.post(BackendEndpoints.GET_LAB_LIST, {});
      return response.data;
    } catch (error) {
      throw this.handleError(error);
    }
  }

  async getLabListV2(params) {
    try {
      const response = await api.get(BackendEndpoints.GET_LAB_LIST_V2, { params });
      return response.data;
    } catch (error) {
      throw this.handleError(error);
    }
  }

  // Cart APIs
  async addToCart(cartData) {
    try {
      const response = await api.post(BackendEndpoints.ADD_TO_CART, cartData);
      return response.data;
    } catch (error) {
      throw this.handleError(error);
    }
  }

  async getCart() {
    try {
      const response = await api.get(BackendEndpoints.GET_CART);
      return response.data;
    } catch (error) {
      throw this.handleError(error);
    }
  }

  async clearCart() {
    try {
      const response = await api.get(BackendEndpoints.CLEAR_CART);
      return response.data;
    } catch (error) {
      throw this.handleError(error);
    }
  }

  // Booking APIs
  async getSlots(bookingData) {
    try {
      const response = await api.post(BackendEndpoints.GET_SLOT, bookingData);
      return response.data;
    } catch (error) {
      throw this.handleError(error);
    }
  }

  async bookNow(bookingData) {
    try {
      const response = await api.post(BackendEndpoints.BOOK_NOW, bookingData);
      return response.data;
    } catch (error) {
      throw this.handleError(error);
    }
  }

  async getBookingList() {
    try {
      const response = await api.get(BackendEndpoints.GET_BOOKING_LIST);
      return response.data;
    } catch (error) {
      throw this.handleError(error);
    }
  }

  async getBookingDetails(bookingId) {
    try {
      const response = await api.get(`${BackendEndpoints.GET_BOOKING_DETAILS}?booking_id=${bookingId}`);
      return response.data;
    } catch (error) {
      throw this.handleError(error);
    }
  }

  // Prescription APIs
  async uploadPrescription(formData) {
    try {
      const response = await api.post(BackendEndpoints.UPLOAD_PRESCRIPTION, formData, {
        headers: {
          'Content-Type': 'multipart/form-data',
        },
      });
      return response.data;
    } catch (error) {
      throw this.handleError(error);
    }
  }

  async getPrescriptions() {
    try {
      const response = await api.get(BackendEndpoints.GET_PRESCRIPTION);
      return response.data;
    } catch (error) {
      throw this.handleError(error);
    }
  }

  // Report APIs
  async getReports() {
    try {
      const response = await api.get(BackendEndpoints.GET_REPORT);
      return response.data;
    } catch (error) {
      throw this.handleError(error);
    }
  }

  // Notification APIs
  async getNotifications() {
    try {
      const response = await api.get(BackendEndpoints.GET_NOTIFICATION);
      return response.data;
    } catch (error) {
      throw this.handleError(error);
    }
  }

  // Address APIs
  async getAddressList() {
    try {
      const response = await api.get(BackendEndpoints.GET_ADDRESS_LIST);
      return response.data;
    } catch (error) {
      throw this.handleError(error);
    }
  }

  async addAddress(addressData) {
    try {
      const response = await api.post(BackendEndpoints.ADD_ADDRESS, addressData);
      return response.data;
    } catch (error) {
      throw this.handleError(error);
    }
  }

  async deleteAddress(addressId) {
    try {
      const response = await api.post(BackendEndpoints.ADDRESS_DELETE, { address_id: addressId });
      return response.data;
    } catch (error) {
      throw this.handleError(error);
    }
  }

  // CMS APIs
  async getCmsContent(type) {
    try {
      const response = await api.get(`${BackendEndpoints.CMS}?type=${type}`);
      return response.data;
    } catch (error) {
      throw this.handleError(error);
    }
  }

  // Contact Us API
  async contactUs(contactData) {
    try {
      const response = await api.post(BackendEndpoints.CONTACT_US, contactData);
      return response.data;
    } catch (error) {
      throw this.handleError(error);
    }
  }

  // Rating and Review APIs
  async submitRating(ratingData) {
    try {
      const response = await api.post(BackendEndpoints.RATING_REVIEW, ratingData);
      return response.data;
    } catch (error) {
      throw this.handleError(error);
    }
  }

  // Search APIs
  async searchByCity(cityName) {
    try {
      const response = await api.get(`${BackendEndpoints.SEARCH_BY_CITY}?city=${cityName}`);
      return response.data;
    } catch (error) {
      throw this.handleError(error);
    }
  }

  // Coupon APIs
  async applyCoupon(couponData) {
    try {
      const response = await api.post(BackendEndpoints.APPLY_COUPON, couponData);
      return response.data;
    } catch (error) {
      throw this.handleError(error);
    }
  }

  // Payment APIs
  async getOrderKey() {
    try {
      const response = await api.get(BackendEndpoints.GET_ORDER_KEY);
      return response.data;
    } catch (error) {
      throw this.handleError(error);
    }
  }

  async getWalletTransaction() {
    try {
      const response = await api.get(BackendEndpoints.GET_WALLET_TRANSACTION);
      return response.data;
    } catch (error) {
      throw this.handleError(error);
    }
  }

  async rechargeWallet(amount) {
    try {
      const response = await api.post(BackendEndpoints.RECHARGE_WALLET, { amount });
      return response.data;
    } catch (error) {
      throw this.handleError(error);
    }
  }

  async checkBalanceWithPayment(paymentData) {
    try {
      const response = await api.post(BackendEndpoints.CHECK_BALANCE_WITH_PAYMENT, paymentData);
      return response.data;
    } catch (error) {
      throw this.handleError(error);
    }
  }

  async bookingAfterPayment(paymentData) {
    try {
      const response = await api.post(BackendEndpoints.BOOKING_AFTER_PAYMENT, paymentData);
      return response.data;
    } catch (error) {
      throw this.handleError(error);
    }
  }

  // Delete Account API
  async deleteAccount() {
    try {
      const response = await api.post(BackendEndpoints.DELETE_ACCOUNT);
      return response.data;
    } catch (error) {
      throw this.handleError(error);
    }
  }

  // Update Profile API
  async updateProfile(profileData) {
    try {
      const response = await api.post(BackendEndpoints.UPDATE_PROFILE, profileData);
      return response.data;
    } catch (error) {
      throw this.handleError(error);
    }
  }

  // Lab-wise test API
  async getLabWiseTests(labId) {
    try {
      const response = await api.get(`${BackendEndpoints.LAB_WISE_TEST}?lab_id=${labId}`);
      return response.data;
    } catch (error) {
      throw this.handleError(error);
    }
  }

  // Get coupon API
  async getCoupons() {
    try {
      const response = await api.get(BackendEndpoints.GET_COUPON);
      return response.data;
    } catch (error) {
      throw this.handleError(error);
    }
  }

  // Error handler
  handleError(error) {
    if (error.response) {
      // Server responded with error status
      // Log full response for easier debugging
      // eslint-disable-next-line no-console
      console.error('API error response:', {
        status: error.response.status,
        statusText: error.response.statusText,
        data: error.response.data,
        headers: error.response.headers,
        url: error.config?.url,
        method: error.config?.method,
      });

      const respData = error.response.data || {};
      const possibleMessage = respData.message || respData.error || respData.detail || JSON.stringify(respData);
      const message = possibleMessage && possibleMessage !== '{}' ? possibleMessage : `HTTP ${error.response.status}: ${error.response.statusText}`;
      return new Error(message);
    } else if (error.request) {
      // Network error
      // eslint-disable-next-line no-console
      console.error('API network error - no response received', error.request);
      return new Error('Network error - please check your internet connection');
    } else {
      // Other error
      // eslint-disable-next-line no-console
      console.error('API error', error.message);
      return new Error(error.message || 'An unexpected error occurred');
    }
  }
}

// Export singleton instance
export const apiService = new ApiService();
export { IMG_URL, BackendEndpoints };
