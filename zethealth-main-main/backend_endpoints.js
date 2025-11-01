// JavaScript version of Backend Endpoints for ZetHealth
// This file contains all API endpoints that can be used in JavaScript environments

const BackendEndpoints = {
  // Base URLs
  BASE_URL: "https://apihealth.zethealth.com/api/v1/Authenticate/",
  IMG_URL: "http://apihealth.zethealth.com/images/",
  PDF_UPLOAD_URL: "https://staging.zethealth.com/categorize_v2",
  PDF_REPORTS_URL: "https://staging.zethealth.com/reports",
  JOB_STATUS_URL: "https://staging.zethealth.com/jobs/latest",
  HEALJOUR_BASE_URL: "https://apitesting.healjour.com/v1/",
  NODE_API_BASE: "http://15.207.229.70/api/",

  // Admin Panel
  ADMIN_PANEL: "https://admin.zethealth.com/admin-login",

  // Authentication Endpoints
  LOGIN: "login-user", // Used for both initial login (sends OTP) and OTP verification
  REGISTER: "register-user",
  SIGNUP: "register-user", // Alias for REGISTER - user registration/signup
  LOGOUT: "common/logout-user",
  DELETE_ACCOUNT: "delete-account",

  // OTP Endpoints (Note: OTP sending and verification are handled through LOGIN endpoint)
  // The login API serves dual purpose:
  // 1. First call with mobile_number sends OTP
  // 2. Second call with mobile_number + otp verifies and logs in user
  SEND_OTP: "login-user", // Same as LOGIN - sends OTP
  VERIFY_OTP: "login-user", // Same as LOGIN - verifies OTP
  RESEND_OTP: "login-user", // Same as LOGIN - resends OTP

  // User Profile Endpoints
  UPDATE_PROFILE: "update-profile",
  GET_PATIENT_LIST: "get-patient-list",
  ADD_PATIENT: "add-patient",
  DELETE_PATIENT: "delete-patient",
  ADMIN_GET_CUSTOMER: "admin/get-customer",

  // Home & Content Endpoints
  GET_HOME: "get-home",
  GET_NOTIFICATION: "common/get-notification",
  CMS: "cms",

  // Lab & Test Endpoints
  GET_LAB_LIST: "get-lab-list",
  GET_LAB_LIST_V2: "get-lab-list-v2",
  GET_LAB_TEST_LIST: "get-lab-test-list",
  GET_TEST_PROFILE: "get-test-profile",
  GET_PACKAGE_LIST: "get-package-list",
  LAB_WISE_TEST: "lab-wise-test",

  // Cart & Booking Endpoints
  ADD_TO_CART: "cart-create-or-update",
  GET_CART: "get-cart",
  CLEAR_CART: "clear-cart-list",
  BOOK_NOW: "book-now-v2",
  ADMIN_BOOK_NOW: "admin/book-now",
  BOOKING_AFTER_PAYMENT: "booking-after-payment-v2",
  GET_BOOKING_LIST: "get-booking-list",
  GET_BOOKING_DETAILS: "get-booking-details",
  GET_SLOT: "get-slot",

  // Payment Endpoints
  GET_ORDER_KEY: "razorpay/get-order-key",
  GET_WALLET_TRANSACTION: "razorpay/get-wallet-transaction",
  RECHARGE_WALLET: "razorpay/recharge-wallet",
  CHECK_BALANCE_WITH_PAYMENT: "check-balance-with-payment",

  // Prescription Endpoints
  UPLOAD_PRESCRIPTION: "upload-prescription",
  GET_PRESCRIPTION: "get-prescription",

  // Report Endpoints
  GET_REPORT: "get-report",

  // Address Management Endpoints
  GET_ADDRESS_LIST: "get-address-list",
  ADD_ADDRESS: "add-address",
  ADDRESS_DELETE: "address-delete",

  // Offer & Coupon Endpoints
  GET_COUPON: "get-coupon",
  APPLY_COUPON: "apply-coupon",

  // Rating & Review Endpoints
  RATING_REVIEW: "rating-review",
  RATING: "rating",

  // Search Endpoints
  SEARCH_BY_CITY: "search-by-city",

  // Contact & Support Endpoints
  CONTACT_US: "contact-us",

  // Healjour Integration Endpoints
  HEALJOUR_BRANCH_LIST: "branch/list",
  HEALJOUR_DEPARTMENT_LIST: "department/list",

  // PDF Processing Endpoints (External Services)
  UPLOAD_PDF: "categorize_v2", // Relative to PDF_UPLOAD_URL
  GET_USER_PDFS: "", // Relative to PDF_REPORTS_URL + userId
  GET_JOB_STATUS: "", // Relative to JOB_STATUS_URL + ?user_id=

  // Node.js API Endpoints (External Service)
  CHECK_PINCODE_SERVICEABLE: "", // To be used with NODE_API_BASE

  // API Methods Available
  API_METHODS: [
    'callPostApi',
    'callGetApi',
    'callFormDataPostApi',
    'callNewNodeApi',
    'uploadPdfInBackground',
    'uploadPdfInBackgroundWithData',
    'getUserUploadedPdfs',
    'getLatestJob',
    'branchList',
    'branchDepartment'
  ],

  // HTTP Status Codes Handled
  HTTP_STATUS_MESSAGES: {
    200: 'Success',
    202: 'Accepted',
    400: 'Bad Request',
    401: 'Unauthorized',
    404: 'Not Found',
    500: 'Internal Server Error'
  },

  // API Helper Classes
  API_HELPERS: [
    'WebApiHelper',
    'FormDataApiHelper',
    'PdfApiHelper',
    'HealjourApiServices'
  ],

  // Helper methods to construct full URLs
  getFullUrl: function(endpoint) {
    return this.BASE_URL + endpoint;
  },

  getPdfUrl: function(endpoint) {
    return this.PDF_UPLOAD_URL + endpoint;
  },

  getHealjourUrl: function(endpoint) {
    return this.HEALJOUR_BASE_URL + endpoint;
  },

  getNodeApiUrl: function(endpoint) {
    return this.NODE_API_BASE + endpoint;
  },

  getImageUrl: function(imagePath) {
    return this.IMG_URL + imagePath;
  },

  // Authentication helper methods
  getLoginUrl: function() {
    return this.getFullUrl(this.LOGIN);
  },

  getSignupUrl: function() {
    return this.getFullUrl(this.SIGNUP);
  },

  getOtpUrl: function() {
    return this.getFullUrl(this.SEND_OTP);
  },

  // Example usage functions
  loginUser: async function(mobileNumber, otp = null) {
    const url = this.getLoginUrl();
    const payload = otp
      ? { mobile_number: mobileNumber, otp: otp, user_type: 'User' }
      : { mobile_number: mobileNumber, user_type: 'User' };

    // This would need to be implemented with fetch or axios
    console.log('Login URL:', url);
    console.log('Payload:', payload);
    return { url, payload };
  },

  signupUser: async function(userData) {
    const url = this.getSignupUrl();
    console.log('Signup URL:', url);
    console.log('User Data:', userData);
    return { url, userData };
  }
};

// Export for different environments
if (typeof module !== 'undefined' && module.exports) {
  module.exports = BackendEndpoints;
} else if (typeof window !== 'undefined') {
  window.BackendEndpoints = BackendEndpoints;
} else if (typeof global !== 'undefined') {
  global.BackendEndpoints = BackendEndpoints;
}
