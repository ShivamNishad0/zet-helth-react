import React, { useEffect } from 'react';
import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import { Provider } from 'react-redux';
import { PersistGate } from 'redux-persist/integration/react';
import { ThemeProvider, createTheme } from '@mui/material/styles';
import CssBaseline from '@mui/material/CssBaseline';
import { Toaster } from 'react-hot-toast';
import { store, persistor } from './store/store';
import { initializeAuth } from './store/slices/authSlice';
import { COLORS } from './utils/constants';

// Components
import LoadingSpinner from './components/common/LoadingSpinner';
import PrivateRoute from './components/common/PrivateRoute';

// Pages
import SplashScreen from './pages/auth/SplashScreen';
import LoginScreen from './pages/auth/LoginScreen';
import RegisterScreen from './pages/auth/RegisterScreen';
import OTPScreen from './pages/auth/OTPScreen';
import RegisterDetailsScreen from './pages/auth/RegisterDetailsScreen';
import WelcomeScreen from './pages/auth/WelcomeScreen';
import HomeScreen from './pages/home/HomeScreen';
import BookingScreen from './pages/booking/BookingScreen';
import CartScreen from './pages/home/CartScreen';
import ProfileScreen from './pages/profile/ProfileScreen';
import ReportScreen from './pages/home/ReportScreen';
import NotificationScreen from './pages/home/NotificationScreen';
import PrescriptionScreen from './pages/home/PrescriptionScreen';
import AddressScreen from './pages/profile/AddressScreen';
import ChatScreen from './pages/chat/ChatScreen';
import SettingsScreen from './pages/profile/SettingsScreen';

// Material-UI Theme
const theme = createTheme({
  palette: {
    primary: {
      main: COLORS.PRIMARY,
    },
    secondary: {
      main: COLORS.SECONDARY,
    },
    warning: {
      main: COLORS.WARNING,
    },
    info: {
      main: COLORS.INFO,
    },
  },
  typography: {
    fontFamily: '"Inter", "Roboto", "Helvetica", "Arial", sans-serif',
    h1: {
      fontSize: '2rem',
      fontWeight: 600,
    },
    h2: {
      fontSize: '1.75rem',
      fontWeight: 600,
    },
    h3: {
      fontSize: '1.5rem',
      fontWeight: 600,
    },
    h4: {
      fontSize: '1.25rem',
      fontWeight: 600,
    },
    h5: {
      fontSize: '1.125rem',
      fontWeight: 600,
    },
    h6: {
      fontSize: '1rem',
      fontWeight: 600,
    },
    body1: {
      fontSize: '1rem',
    },
    body2: {
      fontSize: '0.875rem',
    },
    button: {
      textTransform: 'none',
      fontWeight: 500,
    },
  },
  components: {
    MuiButton: {
      styleOverrides: {
        root: {
          borderRadius: 8,
          padding: '12px 24px',
        },
        contained: {
          boxShadow: 'none',
          '&:hover': {
            boxShadow: '0 2px 8px rgba(0, 123, 255, 0.3)',
          },
        },
      },
    },
    MuiTextField: {
      styleOverrides: {
        root: {
          '& .MuiOutlinedInput-root': {
            borderRadius: 8,
          },
        },
      },
    },
    MuiCard: {
      styleOverrides: {
        root: {
          borderRadius: 12,
          boxShadow: '0 2px 12px rgba(0, 0, 0, 0.08)',
        },
      },
    },
  },
});

const App = () => {
  useEffect(() => {
    // Initialize auth state on app start
    store.dispatch(initializeAuth());
  }, []);

  return (
    <Provider store={store}>
      <PersistGate loading={<LoadingSpinner />} persistor={persistor}>
        <ThemeProvider theme={theme}>
          <CssBaseline />
          <Router>
            <div className="App">
              <Routes>
                {/* Public Routes */}
                <Route path="/" element={<WelcomeScreen />} />
                <Route path="/splash" element={<SplashScreen />} />
                <Route path="/login" element={<LoginScreen />} />
                <Route path="/register" element={<RegisterScreen />} />
                <Route path="/otp" element={<OTPScreen />} />
                <Route path="/register-details" element={<RegisterDetailsScreen />} />
                <Route path="/welcome" element={<WelcomeScreen />} />

                {/* Protected Routes */}
                <Route
                  path="/home"
                  element={
                    <PrivateRoute>
                      <HomeScreen />
                    </PrivateRoute>
                  }
                />
                <Route
                  path="/booking"
                  element={
                    <PrivateRoute>
                      <BookingScreen />
                    </PrivateRoute>
                  }
                />
                <Route
                  path="/cart"
                  element={
                    <PrivateRoute>
                      <CartScreen />
                    </PrivateRoute>
                  }
                />
                <Route
                  path="/profile"
                  element={
                    <PrivateRoute>
                      <ProfileScreen />
                    </PrivateRoute>
                  }
                />
                <Route
                  path="/report"
                  element={
                    <PrivateRoute>
                      <ReportScreen />
                    </PrivateRoute>
                  }
                />
                <Route
                  path="/notifications"
                  element={
                    <PrivateRoute>
                      <NotificationScreen />
                    </PrivateRoute>
                  }
                />
                <Route
                  path="/prescriptions"
                  element={
                    <PrivateRoute>
                      <PrescriptionScreen />
                    </PrivateRoute>
                  }
                />
                <Route
                  path="/address"
                  element={
                    <PrivateRoute>
                      <AddressScreen />
                    </PrivateRoute>
                  }
                />
                <Route
                  path="/chat"
                  element={
                    <PrivateRoute>
                      <ChatScreen />
                    </PrivateRoute>
                  }
                />
                <Route
                  path="/settings"
                  element={
                    <PrivateRoute>
                      <SettingsScreen />
                    </PrivateRoute>
                  }
                />

                {/* Redirect unknown routes to welcome */}
                <Route path="*" element={<Navigate to="/" replace />} />
              </Routes>
            </div>
          </Router>

          {/* Global Toast Notifications */}
          <Toaster
            position="top-center"
            toastOptions={{
              duration: 3000,
              style: {
                background: '#363636',
                color: '#fff',
              },
            }}
          />
        </ThemeProvider>
      </PersistGate>
    </Provider>
  );
};

export default App;
