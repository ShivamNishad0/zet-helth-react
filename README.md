# ZetHealth React App

A comprehensive health service platform built with React, providing users with easy access to medical services including lab tests, consultations, prescription management, and more.

## Features

- **Authentication**: Secure login and registration with OTP verification
- **Home Dashboard**: Overview of available services and health packages
- **Lab Test Booking**: Browse and book diagnostic tests from partnered labs
- **Cart Management**: Add tests and packages to cart for streamlined booking
- **Prescription Upload**: Upload and manage medical prescriptions
- **Reports**: View and download lab test reports
- **Profile Management**: Manage personal information and addresses
- **Notifications**: Stay updated with health-related notifications
- **Chat Support**: Connect with healthcare professionals
- **Payment Integration**: Secure payments via Razorpay

## Prerequisites

Before running this project, make sure you have the following installed:

- **Node.js** (version 16 or higher) - [Download here](https://nodejs.org/)
- **npm** (comes with Node.js) or **yarn** package manager

You can check your versions by running:
```bash
node --version
npm --version
```

## Installation

1. **Clone the repository**:
   ```bash
   git clone <repository-url>
   cd zet-health-react
   ```

2. **Install dependencies**:
   ```bash
   npm install
   ```
   This will install all the required packages including React, Redux Toolkit, Material-UI, Axios, and other dependencies.

## Running the Application

### Development Mode

To start the development server:

```bash
npm start
```

This will:
- Start the development server on `http://localhost:3000`
- Open your default browser automatically
- Enable hot reloading for development
- Display any lint errors in the console

### Production Build

To build the app for production:

```bash
npm run build
```

This will:
- Create a `build` folder with optimized production files
- Bundle and minify the code for best performance
- Generate static files ready for deployment

### Testing

To run the test suite:

```bash
npm test
```

This will:
- Launch the test runner in interactive watch mode
- Run all test files in the project
- Provide options to run specific tests or update snapshots

## Backend API Configuration

This application connects to external backend services. The API endpoints are configured in `src/utils/backendEndpoints.js` and include the following:

### Base URLs
- **BASE_URL**: `https://apihealth.zethealth.com/api/v1/Authenticate/`
- **IMG_URL**: `http://apihealth.zethealth.com/images/`
- **PDF_UPLOAD_URL**: `https://staging.zethealth.com/categorize_v2`
- **PDF_REPORTS_URL**: `https://staging.zethealth.com/reports`
- **JOB_STATUS_URL**: `https://staging.zethealth.com/jobs/latest`
- **HEALJOUR_BASE_URL**: `https://apitesting.healjour.com/v1/`
- **NODE_API_BASE**: `http://15.207.229.70/api/`

### Authentication Endpoints
- **LOGIN**: `login-user` (handles both OTP sending and verification)
- **REGISTER**: `register-user`
- **SIGNUP**: `register-user` (alias for REGISTER)
- **LOGOUT**: `common/logout-user`
- **DELETE_ACCOUNT**: `delete-account`
- **SEND_OTP**: `login-user` (same as LOGIN)
- **VERIFY_OTP**: `login-user` (same as LOGIN)
- **RESEND_OTP**: `login-user` (same as LOGIN)

### User Profile Endpoints
- **UPDATE_PROFILE**: `update-profile`
- **GET_PATIENT_LIST**: `get-patient-list`
- **ADD_PATIENT**: `add-patient`
- **DELETE_PATIENT**: `delete-patient`
- **ADMIN_GET_CUSTOMER**: `admin/get-customer`

### Home & Content Endpoints
- **GET_HOME**: `get-home`
- **GET_NOTIFICATION**: `common/get-notification`
- **CMS**: `cms`

### Lab & Test Endpoints
- **GET_LAB_LIST**: `get-lab-list`
- **GET_LAB_LIST_V2**: `get-lab-list-v2`
- **GET_LAB_TEST_LIST**: `get-lab-test-list`
- **GET_TEST_PROFILE**: `get-test-profile`
- **GET_PACKAGE_LIST**: `get-package-list`
- **LAB_WISE_TEST**: `lab-wise-test`

### Cart & Booking Endpoints
- **ADD_TO_CART**: `cart-create-or-update`
- **GET_CART**: `get-cart`
- **CLEAR_CART**: `clear-cart-list`
- **BOOK_NOW**: `book-now-v2`
- **ADMIN_BOOK_NOW**: `admin/book-now`
- **BOOKING_AFTER_PAYMENT**: `booking-after-payment-v2`
- **GET_BOOKING_LIST**: `get-booking-list`
- **GET_BOOKING_DETAILS**: `get-booking-details`
- **GET_SLOT**: `get-slot`

### Payment Endpoints
- **GET_ORDER_KEY**: `razorpay/get-order-key`
- **GET_WALLET_TRANSACTION**: `razorpay/get-wallet-transaction`
- **RECHARGE_WALLET**: `razorpay/recharge-wallet`
- **CHECK_BALANCE_WITH_PAYMENT**: `check-balance-with-payment`

### Prescription Endpoints
- **UPLOAD_PRESCRIPTION**: `upload-prescription`
- **GET_PRESCRIPTION**: `get-prescription`

### Report Endpoints
- **GET_REPORT**: `get-report`

### Address Management Endpoints
- **GET_ADDRESS_LIST**: `get-address-list`
- **ADD_ADDRESS**: `add-address`
- **ADDRESS_DELETE**: `address-delete`

### Offer & Coupon Endpoints
- **GET_COUPON**: `get-coupon`
- **APPLY_COUPON**: `apply-coupon`

### Rating & Review Endpoints
- **RATING_REVIEW**: `rating-review`
- **RATING**: `rating`

### Search Endpoints
- **SEARCH_BY_CITY**: `search-by-city`

### Contact & Support Endpoints
- **CONTACT_US**: `contact-us`

### Healjour Integration Endpoints
- **HEALJOUR_BRANCH_LIST**: `branch/list`
- **HEALJOUR_DEPARTMENT_LIST**: `department/list`

### PDF Processing Endpoints
- **UPLOAD_PDF**: `categorize_v2` (relative to PDF_UPLOAD_URL)
- **GET_USER_PDFS**: (relative to PDF_REPORTS_URL + userId)
- **GET_JOB_STATUS**: (relative to JOB_STATUS_URL + ?user_id=)

### Node.js API Endpoints
- **CHECK_PINCODE_SERVICEABLE**: (relative to NODE_API_BASE)

### Admin Panel
- **ADMIN_PANEL**: `https://admin.zethealth.com/admin-login`

**Note**: The backend APIs are hosted on external servers and should be accessible for full functionality. If you encounter API-related issues, ensure the backend services are running and accessible.

## Project Structure

```
zet-health-react/
├── public/                 # Static assets
├── src/
│   ├── components/         # Reusable UI components
│   │   ├── auth/          # Authentication components
│   │   ├── booking/       # Booking-related components
│   │   ├── chat/          # Chat components
│   │   ├── common/        # Shared components (Header, LoadingSpinner, etc.)
│   │   ├── home/          # Home screen components
│   │   └── profile/       # Profile components
│   ├── pages/             # Page components
│   │   ├── auth/          # Authentication pages
│   │   ├── booking/       # Booking pages
│   │   ├── chat/          # Chat pages
│   │   ├── home/          # Home pages
│   │   └── profile/       # Profile pages
│   ├── services/          # API service functions
│   ├── store/             # Redux store and slices
│   ├── utils/             # Utility functions and constants
│   ├── hooks/             # Custom React hooks
│   └── assets/            # Images, icons, and fonts
├── package.json           # Project dependencies and scripts
└── README.md             # This file
```

## Available Scripts

- `npm start` - Runs the app in development mode
- `npm test` - Launches the test runner
- `npm run build` - Builds the app for production
- `npm run eject` - Ejects from Create React App (irreversible)

## Technologies Used

- **React 19** - Frontend framework
- **Redux Toolkit** - State management
- **React Router** - Client-side routing
- **Material-UI** - UI component library
- **Axios** - HTTP client for API calls
- **Firebase** - Backend services
- **React PDF** - PDF viewing and processing
- **Swiper** - Carousel/slider components
- **Lottie React** - Animations

## Troubleshooting

### Common Issues

1. **Port 3000 already in use**:
   - The app will automatically prompt to use a different port
   - Or manually specify a port: `PORT=3001 npm start`

2. **API connection issues**:
   - Check network connectivity
   - Verify backend services are running
   - Check `src/utils/backendEndpoints.js` for correct API URLs

3. **Build failures**:
   - Clear node_modules: `rm -rf node_modules && npm install`
   - Check Node.js version compatibility

### Development Tips

- Use browser developer tools for debugging
- Check the console for error messages
- Ensure all dependencies are installed correctly
- For production deployment, use `npm run build` and serve the `build` folder

## Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/your-feature-name`
3. Make your changes and test thoroughly
4. Commit your changes: `git commit -m 'Add some feature'`
5. Push to the branch: `git push origin feature/your-feature-name`
6. Open a pull request

## License

This project is private and proprietary to ZetHealth.

---

For more information about Create React App, visit the [official documentation](https://facebook.github.io/create-react-app/docs/getting-started).
