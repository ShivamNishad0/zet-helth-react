// API Constants
export const BASE_URL = 'https://apihealth.zethealth.com/api/v1/Authenticate/';
export const IMG_URL = 'http://apihealth.zethealth.com/images/';

// App Constants
export const APP_NAME = 'Zet Health';
export const PLAY_STORE_URL = 'https://play.google.com/store/apps/details?id=com.healthexpress';
export const APP_STORE_URL = 'https://apps.apple.com/in/app/zet-health/id6749360221';
export const WHATSAPP_URL = 'https://wa.me/919148914858'; // Replace with actual WhatsApp number

// Payment Constants
export const IS_PAYMENT_LIVE = 1; // 0 means test and 1 means live

// Google Maps API Key
export const GOOGLE_MAP_API_KEY = 'AIzaSyBqG8oCDY59Pwe68Y0AUiUeis-jWlsmtN8';
export const GOOGLE_MAP_API_KEY_2 = 'AIzaSyCILYd8F2M7g95NQErBTZsXLmTD7baDBIw';

// API Endpoints
export const API_ENDPOINTS = {
  LOGIN: 'login-user',
  REGISTER: 'register-user',
  HOME: 'get-home',
  PACKAGES: 'get-package-list',
  LAB_TESTS: 'get-lab-test-list',
  TEST_PROFILE: 'get-test-profile',
  ADD_PATIENT: 'add-patient',
  GET_PATIENT_LIST: 'get-patient-list',
  LAB_LIST: 'get-lab-list',
  LAB_LIST_V2: 'get-lab-list-v2',
  CART_CREATE_UPDATE: 'cart-create-or-update',
  GET_CART: 'get-cart',
  CLEAR_CART: 'clear-cart-list',
  BOOK_NOW: 'book-now-v2',
  BOOKING_AFTER_PAYMENT: 'booking-after-payment-v2',
  GET_SLOTS: 'get-slot',
  GET_BOOKING_LIST: 'get-booking-list',
  GET_BOOKING_DETAILS: 'get-booking-details',

  GET_PRESCRIPTION: 'get-prescription',
  GET_REPORT: 'get-report',
  UPDATE_PROFILE: 'update-profile',

  GET_NOTIFICATION: 'common/get-notification',
  CONTACT_US: 'contact-us',
  GET_ADDRESS_LIST: 'get-address-list',
  ADD_ADDRESS: 'add-address',
  ADDRESS_DELETE: 'address-delete',
  APPLY_COUPON: 'apply-coupon',
  LOGOUT: 'common/logout-user',
  RATING_REVIEW: 'rating-review',
  SEARCH_BY_CITY: 'search-by-city',
  DELETE_ACCOUNT: 'delete-account',
  GET_ORDER_KEY: 'razorpay/get-order-key',
  GET_WALLET_TRANSACTION: 'razorpay/get-wallet-transaction',
  RECHARGE_WALLET: 'razorpay/recharge-wallet',
  CHECK_BALANCE_WITH_PAYMENT: 'check-balance-with-payment',
  LAB_WISE_TEST: 'lab-wise-test',
  GET_COUPON: 'get-coupon',
  CMS: 'cms',
};

// CMS Types
export const CMS_TYPES = {
  TERMS_CONDITION: 'terms_and_conditions',
  CONTACT_US: 'contact_us',
  PRIVACY_POLICY: 'privacy_policy',
  ABOUT_US: 'about_us',
  BANK_DETAIL: 'bank_detail',
};

// Booking Types
export const BOOKING_TYPES = {
  TEST: 'LabTest',
  PACKAGE: 'Package',
  PROFILE: 'Profile',
};

// Routes
export const ROUTES = {
  SPLASH: '/splash',
  HOME: '/',
  LOGIN: '/login',
  REGISTER: '/register',
  WELCOME: '/welcome',
  REPORT: '/report',
  BOOKING: '/booking',
  CART: '/cart',
  PROFILE: '/profile',
  NOTIFICATIONS: '/notifications',
  PRESCRIPTIONS: '/prescriptions',
  ADDRESS: '/address',
  CHAT: '/chat',
  SETTINGS: '/settings',
};

// Local Storage Keys
export const STORAGE_KEYS = {
  TOKEN: 'token',
  USER_TYPE: 'user_type',
  USER_ID: 'user_id',
  USER_NAME: 'user_name',
  USER_DETAIL: 'user_detail',
  USER_MOBILE: 'user_mobile',
  IS_NOTIFICATION: 'is_notification',
  SUPPORT_MOBILE: 'support_mobile',
  SUPPORT_EMAIL: 'support_email',
  SERVICE_CHARGE: 'serviceCharge',
  SERVICE_CHARGE_DISPLAY: 'serviceChargeDisplay',
  IS_CART_EXIST: 'isCartExist',
  CART_COUNTER: 'cartCounter',
  LOGIN_COUNT: 'login_count',
  CITY_LIST: 'city_list',
  CITY_ID: 'city_id',
  CURRENT_LOCATION: 'current_location',
  CURRENT_PINCODE: 'current_pincode',
  FULL_ADDRESS: 'full_address',
  SELECTED_ADDRESS: 'selected_address',
  IS_ADDRESS_SELECTED: 'is_address_selected',
  CURRENT_ADDRESS: 'current_address',
  IS_CURRENT_ADDRESS: 'is_current_address',
  CART_PINCODE: 'cart_pincode',
  WELCOME_SHOWN: 'welcome_shown',
};

// Colors (matching brand - rich green theme)
export const COLORS = {
  PRIMARY: '#13a266ff', // Rich green
  SECONDARY: '#228B22', // Forest green
  SUCCESS: '#32CD32', // Lime green
  DANGER: '#dc3545',
  WARNING: '#ffc107',
  INFO: '#17a2b8',
  LIGHT: '#f0f8f0', // Light green tint
  DARK: '#004d00', // Dark green
  WHITE: '#ffffff',
  BLACK: '#000000',
  BORDER: '#90EE90', // Light green border
  GRAY: '#6c757d',
  LIGHT_GRAY: '#f8f9fa',
};

// Screen Sizes
export const SCREEN_SIZES = {
  MOBILE: 768,
  TABLET: 1024,
  DESKTOP: 1200,
};

// Validation Rules
export const VALIDATION = {
  EMAIL_REGEX: /^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$/,
  MOBILE_REGEX: /^[6-9]\d{9}$/,
  PASSWORD_MIN_LENGTH: 6,
  NAME_MIN_LENGTH: 2,
  PINCODE_LENGTH: 6,
};

// Date Formats
export const DATE_FORMATS = {
  DISPLAY: 'dd-MM-yyyy',
  API: 'yyyy-MM-dd',
  DISPLAY_WITH_TIME: 'dd-MM-yyyy hh:mm a',
  API_WITH_TIME: 'yyyy-MM-dd HH:mm:ss',
};

// File Upload
export const FILE_UPLOAD = {
  MAX_SIZE: 10 * 1024 * 1024, // 10MB
  ALLOWED_TYPES: ['image/jpeg', 'image/png', 'image/jpg', 'application/pdf'],
  IMAGE_TYPES: ['image/jpeg', 'image/png', 'image/jpg'],
};

// Payment Status
export const PAYMENT_STATUS = {
  PENDING: 'pending',
  COMPLETED: 'completed',
  FAILED: 'failed',
  CANCELLED: 'cancelled',
};

// Booking Status
export const BOOKING_STATUS = {
  PENDING: 'pending',
  CONFIRMED: 'confirmed',
  IN_PROGRESS: 'in_progress',
  COMPLETED: 'completed',
  CANCELLED: 'cancelled',
};

// Toast Types
export const TOAST_TYPES = {
  SUCCESS: 'success',
  ERROR: 'error',
  INFO: 'info',
  WARNING: 'warning',
};
