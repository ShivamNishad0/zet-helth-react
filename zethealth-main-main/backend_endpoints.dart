// Consolidated Backend Endpoints for ZetHealth Flutter App
// This file contains all API endpoints used across the application

class BackendEndpoints {
  // Base URLs
  static const String BASE_URL = "https://apihealth.zethealth.com/api/v1/Authenticate/";
  static const String IMG_URL = "http://apihealth.zethealth.com/images/";
  static const String PDF_UPLOAD_URL = "https://staging.zethealth.com/categorize_v2";
  static const String PDF_REPORTS_URL = "https://staging.zethealth.com/reports";
  static const String JOB_STATUS_URL = "https://staging.zethealth.com/jobs/latest";
  static const String HEALJOUR_BASE_URL = "https://apitesting.healjour.com/v1/";
  static const String NODE_API_BASE = "http://15.207.229.70/api/";

  // Admin Panel
  static const String ADMIN_PANEL = "https://admin.zethealth.com/admin-login";

  // Authentication Endpoints
  static const String LOGIN = "login-user"; // Used for both initial login (sends OTP) and OTP verification
  static const String REGISTER = "register-user";
  static const String SIGNUP = "register-user"; // Alias for REGISTER - user registration/signup
  static const String LOGOUT = "common/logout-user";
  static const String DELETE_ACCOUNT = "delete-account";

  // OTP Endpoints (Note: OTP sending and verification are handled through LOGIN endpoint)
  // The login API serves dual purpose:
  // 1. First call with mobile_number sends OTP
  // 2. Second call with mobile_number + otp verifies and logs in user
  static const String SEND_OTP = "login-user"; // Same as LOGIN - sends OTP
  static const String VERIFY_OTP = "login-user"; // Same as LOGIN - verifies OTP
  static const String RESEND_OTP = "login-user"; // Same as LOGIN - resends OTP

  // User Profile Endpoints
  static const String UPDATE_PROFILE = "update-profile";
  static const String GET_PATIENT_LIST = "get-patient-list";
  static const String ADD_PATIENT = "add-patient";
  static const String DELETE_PATIENT = "delete-patient";
  static const String ADMIN_GET_CUSTOMER = "admin/get-customer";

  // Home & Content Endpoints
  static const String GET_HOME = "get-home";
  static const String GET_NOTIFICATION = "common/get-notification";
  static const String CMS = "cms";

  // Lab & Test Endpoints
  static const String GET_LAB_LIST = "get-lab-list";
  static const String GET_LAB_LIST_V2 = "get-lab-list-v2";
  static const String GET_LAB_TEST_LIST = "get-lab-test-list";
  static const String GET_TEST_PROFILE = "get-test-profile";
  static const String GET_PACKAGE_LIST = "get-package-list";
  static const String LAB_WISE_TEST = "lab-wise-test";

  // Cart & Booking Endpoints
  static const String ADD_TO_CART = "cart-create-or-update";
  static const String GET_CART = "get-cart";
  static const String CLEAR_CART = "clear-cart-list";
  static const String BOOK_NOW = "book-now-v2";
  static const String ADMIN_BOOK_NOW = "admin/book-now";
  static const String BOOKING_AFTER_PAYMENT = "booking-after-payment-v2";
  static const String GET_BOOKING_LIST = "get-booking-list";
  static const String GET_BOOKING_DETAILS = "get-booking-details";
  static const String GET_SLOT = "get-slot";

  // Payment Endpoints
  static const String GET_ORDER_KEY = "razorpay/get-order-key";
  static const String GET_WALLET_TRANSACTION = "razorpay/get-wallet-transaction";
  static const String RECHARGE_WALLET = "razorpay/recharge-wallet";
  static const String CHECK_BALANCE_WITH_PAYMENT = "check-balance-with-payment";

  // Prescription Endpoints
  static const String UPLOAD_PRESCRIPTION = "upload-prescription";
  static const String GET_PRESCRIPTION = "get-prescription";

  // Report Endpoints
  static const String GET_REPORT = "get-report";

  // Address Management Endpoints
  static const String GET_ADDRESS_LIST = "get-address-list";
  static const String ADD_ADDRESS = "add-address";
  static const String ADDRESS_DELETE = "address-delete";

  // Offer & Coupon Endpoints
  static const String GET_COUPON = "get-coupon";
  static const String APPLY_COUPON = "apply-coupon";

  // Rating & Review Endpoints
  static const String RATING_REVIEW = "rating-review";
  static const String RATING = "rating";

  // Search Endpoints
  static const String SEARCH_BY_CITY = "search-by-city";

  // Contact & Support Endpoints
  static const String CONTACT_US = "contact-us";

  // Healjour Integration Endpoints
  static const String HEALJOUR_BRANCH_LIST = "branch/list";
  static const String HEALJOUR_DEPARTMENT_LIST = "department/list";

  // PDF Processing Endpoints (External Services)
  static const String UPLOAD_PDF = "categorize_v2"; // Relative to PDF_UPLOAD_URL
  static const String GET_USER_PDFS = ""; // Relative to PDF_REPORTS_URL + userId
  static const String GET_JOB_STATUS = ""; // Relative to JOB_STATUS_URL + ?user_id=

  // Node.js API Endpoints (External Service)
  static const String CHECK_PINCODE_SERVICEABLE = ""; // To be used with NODE_API_BASE

  // API Methods Available
  static const List<String> API_METHODS = [
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
  ];

  // HTTP Status Codes Handled
  static const Map<int, String> HTTP_STATUS_MESSAGES = {
    200: 'Success',
    202: 'Accepted',
    400: 'Bad Request',
    401: 'Unauthorized',
    404: 'Not Found',
    500: 'Internal Server Error'
  };

  // API Helper Classes
  static const List<String> API_HELPERS = [
    'WebApiHelper',
    'FormDataApiHelper',
    'PdfApiHelper',
    'HealjourApiServices'
  ];

  // Get full URL for main API endpoints
  static String getFullUrl(String endpoint) {
    return BASE_URL + endpoint;
  }

  // Get full URL for PDF service endpoints
  static String getPdfUrl(String endpoint) {
    return PDF_UPLOAD_URL + endpoint;
  }

  // Get full URL for Healjour endpoints
  static String getHealjourUrl(String endpoint) {
    return HEALJOUR_BASE_URL + endpoint;
  }

  // Get full URL for Node.js API endpoints
  static String getNodeApiUrl(String endpoint) {
    return NODE_API_BASE + endpoint;
  }

  // Get image URL
  static String getImageUrl(String imagePath) {
    return IMG_URL + imagePath;
  }
}
