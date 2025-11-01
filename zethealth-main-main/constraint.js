// Constraint definitions for ZetHealth Application
// This file contains various constraints and validation rules used across the app

const Constraints = {
  // API Constraints
  API_TIMEOUT: 30000, // 30 seconds
  MAX_RETRY_ATTEMPTS: 3,
  RETRY_DELAY: 1000, // 1 second

  // File Upload Constraints
  MAX_FILE_SIZE: 10 * 1024 * 1024, // 10MB
  ALLOWED_FILE_TYPES: ['application/pdf', 'image/jpeg', 'image/png', 'image/jpg'],
  MAX_FILE_NAME_LENGTH: 255,

  // PDF Processing Constraints
  PDF_PROCESSING_TIMEOUT: 300000, // 5 minutes
  MAX_PDF_PAGES: 100,
  MIN_PDF_SIZE: 1024, // 1KB

  // User Input Constraints
  MIN_PASSWORD_LENGTH: 8,
  MAX_PASSWORD_LENGTH: 128,
  MIN_NAME_LENGTH: 2,
  MAX_NAME_LENGTH: 50,
  MIN_PHONE_LENGTH: 10,
  MAX_PHONE_LENGTH: 15,
  MAX_EMAIL_LENGTH: 254,

  // Address Constraints
  MAX_ADDRESS_LENGTH: 500,
  MAX_CITY_LENGTH: 100,
  MAX_PINCODE_LENGTH: 10,
  MAX_LANDMARK_LENGTH: 200,

  // Search Constraints
  MIN_SEARCH_QUERY_LENGTH: 2,
  MAX_SEARCH_RESULTS: 50,

  // Booking Constraints
  MAX_BOOKING_ADVANCE_DAYS: 90,
  MIN_BOOKING_ADVANCE_HOURS: 2,
  MAX_PATIENTS_PER_BOOKING: 5,

  // Cart Constraints
  MAX_CART_ITEMS: 20,
  MAX_QUANTITY_PER_ITEM: 10,

  // Payment Constraints
  MIN_WALLET_RECHARGE: 100,
  MAX_WALLET_RECHARGE: 50000,
  PAYMENT_TIMEOUT: 900000, // 15 minutes

  // Notification Constraints
  MAX_NOTIFICATION_TITLE_LENGTH: 100,
  MAX_NOTIFICATION_MESSAGE_LENGTH: 500,

  // Rating Constraints
  MIN_RATING: 1,
  MAX_RATING: 5,

  // Review Constraints
  MAX_REVIEW_LENGTH: 1000,

  // Location Constraints
  DEFAULT_LOCATION_ACCURACY: 100, // meters
  LOCATION_TIMEOUT: 10000, // 10 seconds

  // Network Constraints
  MAX_CONCURRENT_REQUESTS: 5,
  REQUEST_QUEUE_SIZE: 10,

  // Cache Constraints
  CACHE_EXPIRY_TIME: 3600000, // 1 hour
  MAX_CACHE_SIZE: 50 * 1024 * 1024, // 50MB

  // UI Constraints
  MAX_LIST_ITEMS_PER_PAGE: 20,
  INFINITE_SCROLL_THRESHOLD: 5,
  SNACKBAR_DURATION: 3000, // 3 seconds

  // Validation Patterns
  PATTERNS: {
    EMAIL: /^[^\s@]+@[^\s@]+\.[^\s@]+$/,
    PHONE: /^\+?[\d\s\-\(\)]+$/,
    PINCODE: /^\d{6}$/,
    PASSWORD: /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]/,
    NAME: /^[a-zA-Z\s]+$/,
    ALPHANUMERIC: /^[a-zA-Z0-9\s]+$/
  },

  // Error Messages
  ERRORS: {
    NETWORK_ERROR: 'Network connection error. Please check your internet connection.',
    TIMEOUT_ERROR: 'Request timed out. Please try again.',
    SERVER_ERROR: 'Server error. Please try again later.',
    UNAUTHORIZED: 'Session expired. Please login again.',
    FILE_TOO_LARGE: 'File size exceeds the maximum limit.',
    INVALID_FILE_TYPE: 'Invalid file type. Please select a valid file.',
    REQUIRED_FIELD: 'This field is required.',
    INVALID_EMAIL: 'Please enter a valid email address.',
    INVALID_PHONE: 'Please enter a valid phone number.',
    INVALID_PASSWORD: 'Password must contain at least 8 characters with uppercase, lowercase, number and special character.',
    INVALID_PINCODE: 'Please enter a valid 6-digit pincode.',
    LOCATION_PERMISSION_DENIED: 'Location permission is required for this feature.',
    PAYMENT_FAILED: 'Payment failed. Please try again.',
    BOOKING_FAILED: 'Booking failed. Please try again.',
    UPLOAD_FAILED: 'Upload failed. Please try again.'
  },

  // Success Messages
  SUCCESS: {
    LOGIN_SUCCESS: 'Login successful!',
    REGISTER_SUCCESS: 'Registration successful!',
    BOOKING_SUCCESS: 'Booking confirmed successfully!',
    PAYMENT_SUCCESS: 'Payment completed successfully!',
    UPLOAD_SUCCESS: 'File uploaded successfully!',
    PROFILE_UPDATE_SUCCESS: 'Profile updated successfully!',
    ADDRESS_ADD_SUCCESS: 'Address added successfully!',
    CART_UPDATE_SUCCESS: 'Cart updated successfully!'
  },

  // Feature Flags
  FEATURES: {
    ENABLE_PDF_UPLOAD: true,
    ENABLE_CHAT: true,
    ENABLE_NOTIFICATIONS: true,
    ENABLE_WALLET: true,
    ENABLE_REVIEWS: true,
    ENABLE_PRESCRIPTIONS: true,
    ENABLE_BRANCH_SELECTION: true
  },

  // Environment-specific constraints
  ENVIRONMENT: {
    DEVELOPMENT: {
      API_TIMEOUT: 60000,
      ENABLE_DEBUG_LOGGING: true
    },
    STAGING: {
      API_TIMEOUT: 45000,
      ENABLE_DEBUG_LOGGING: false
    },
    PRODUCTION: {
      API_TIMEOUT: 30000,
      ENABLE_DEBUG_LOGGING: false
    }
  }
};

// Export for use in other files
if (typeof module !== 'undefined' && module.exports) {
  module.exports = Constraints;
} else if (typeof window !== 'undefined') {
  window.Constraints = Constraints;
}
