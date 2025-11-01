// Base API Response Types
const ApiResponse = {
  status: false,
  message: '',
  data: null,
};

// User Types
const UserDetail = {
  id: '',
  userName: '',
  userEmail: '',
  email: '',
  userMobile: '',
  userDob: '',
  userGender: '',
  userImage: '',
  userType: '',
  isVerified: false,
  createdAt: '',
  updatedAt: '',
};

const AddressList = {
  id: '',
  userId: '',
  address: '',
  houseNo: '',
  landmark: '',
  city: '',
  pincode: '',
  location: '',
  addressType: '',
  latitude: 0,
  longitude: 0,
  isDefault: false,
};

const CityModel = {
  id: '',
  cityName: '',
  cityCode: '',
  stateName: '',
  stateCode: '',
};

// Booking Types
const BookingModel = {
  id: '',
  bookingId: '',
  userId: '',
  patientId: '',
  testIds: '',
  packageIds: '',
  labId: '',
  bookingDate: '',
  bookingTime: '',
  totalAmount: 0,
  discountAmount: 0,
  payableAmount: 0,
  paymentStatus: '',
  bookingStatus: '',
  paymentMethod: '',
  transactionId: '',
  createdAt: '',
  updatedAt: '',
};

// Test and Package Types
const TestModel = {
  id: '',
  testName: '',
  testCode: '',
  testDescription: '',
  testPrice: 0,
  testDiscountPrice: 0,
  testCategory: '',
  testType: '',
  testImage: '',
  isPopular: false,
  isActive: false,
};

const PackageModel = {
  id: '',
  packageName: '',
  packageCode: '',
  packageDescription: '',
  packagePrice: 0,
  packageDiscountPrice: 0,
  packageCategory: '',
  packageImage: '',
  testList: [],
  isPopular: false,
  isActive: false,
  type: '', // "Lifestyle" or others
};

// Cart Types
const CartItem = {
  id: '',
  type: '', // "test" or "package"
  itemId: '',
  itemName: '',
  itemPrice: 0,
  itemDiscountPrice: 0,
  quantity: 0,
  labId: '',
  labName: '',
};

const CartModel = {
  id: '',
  userId: '',
  itemList: [],
  totalAmount: 0,
  discountAmount: 0,
  payableAmount: 0,
  createdAt: '',
  updatedAt: '',
};

// Lab Types
const BranchListModel = {
  id: '',
  branchName: '',
  branchAddress: '',
  branchPhone: '',
  branchEmail: '',
  branchImage: '',
  latitude: 0,
  longitude: 0,
  isActive: false,
  cityId: '',
  cityName: '',
};

// Notification Types
const NotificationModel = {
  id: '',
  title: '',
  message: '',
  type: '',
  isRead: false,
  createdAt: '',
};

// Prescription Types
const PrescriptionModel = {
  id: '',
  userId: '',
  prescriptionImage: '',
  prescriptionName: '',
  uploadDate: '',
  status: '',
  notes: '',
};

// Report Types
const ReportModel = {
  id: '',
  bookingId: '',
  testId: '',
  reportFile: '',
  reportDate: '',
  reportStatus: '',
  downloadUrl: '',
};

// Chat Types
const ChatMessage = {
  id: '',
  senderId: '',
  receiverId: '',
  message: '',
  messageType: '',
  timestamp: '',
  isRead: false,
};

const ChatSession = {
  id: '',
  participants: [],
  lastMessage: null,
  unreadCount: 0,
  createdAt: '',
  updatedAt: '',
};

// Slider Types
const SliderModel = {
  id: '',
  title: '',
  description: '',
  image: '',
  link: '',
  isActive: false,
};

// Status Types
const StatusModel = {
  status: false,
  message: '',
  userDetail: null,
  userAndroidAppVersion: '',
  userIosAppVersion: '',
  userAndroidUpdateMessage: '',
  userIosUpdateMessage: '',
  supportMobile: '',
  supportEmail: '',
  serviceCharge: 0,
  serviceChargeDisplay: '',
  unreadNotification: 0,
  sliderList: [],
  popularPackageList: [],
  lifestylePackageList: [],
  popularProfilesList: [],
  testList: [],
  branchList: [],
  cartList: [],
  cityList: [],
  addressList: [],
  prescriptionList: [],
  bookingList: [],
  notificationList: [],
  reportList: [],
};

// API Request Types
const LoginRequest = {
  mobile_number: '',
  password: '',
  otp: '',
};

const RegisterRequest = {
  user_name: '',
  user_email: '',
  user_mobile: '',
  password: '',
  user_dob: '',
  user_gender: '',
};

const BookingRequest = {
  patient_id: '',
  test_ids: '',
  package_ids: '',
  lab_id: '',
  booking_date: '',
  booking_time: '',
  address_id: '',
  coupon_code: '',
};

const HomeApiRequest = {
  token: '',
  device_id: '',
  platform: '',
  app_version: '',
};

// Redux State Types
const AuthState = {
  isAuthenticated: false,
  user: null,
  token: null,
  loading: false,
  error: null,
};

const AppState = {
  loading: false,
  toast: {
    message: '',
    type: 'info',
    visible: false,
  },
};

const HomeState = {
  sliderList: [],
  popularPackages: [],
  lifestylePackages: [],
  popularTests: [],
  popularProfiles: [],
  branchList: [],
  loading: false,
};

const CartState = {
  items: [],
  totalAmount: 0,
  discountAmount: 0,
  payableAmount: 0,
  loading: false,
};

const BookingState = {
  bookings: [],
  currentBooking: null,
  loading: false,
};

const RootState = {
  auth: AuthState,
  app: AppState,
  home: HomeState,
  cart: CartState,
  booking: BookingState,
};

export {
  ApiResponse,
  UserDetail,
  AddressList,
  CityModel,
  BookingModel,
  TestModel,
  PackageModel,
  CartItem,
  CartModel,
  BranchListModel,
  NotificationModel,
  PrescriptionModel,
  ReportModel,
  ChatMessage,
  ChatSession,
  SliderModel,
  StatusModel,
  LoginRequest,
  RegisterRequest,
  BookingRequest,
  HomeApiRequest,
  AuthState,
  AppState,
  HomeState,
  CartState,
  BookingState,
  RootState,
};
