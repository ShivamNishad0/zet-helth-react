import React from 'react';
import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import { Provider } from 'react-redux';
import { configureStore } from '@reduxjs/toolkit';
import authReducer from '../store/slices/authSlice';
import appReducer from '../store/slices/appSlice';

// Mock react-router-dom first
const mockNavigate = jest.fn();
jest.mock('react-router-dom', () => ({
  BrowserRouter: ({ children }) => <div>{children}</div>,
  Link: ({ children, to }) => <a href={to}>{children}</a>,
  useNavigate: () => mockNavigate,
}), { virtual: true });

// Mock the API service
jest.mock('../services/api', () => ({
  apiService: {
    register: jest.fn(),
  },
}));

import { apiService } from '../services/api';
import RegisterScreen from '../pages/auth/RegisterScreen';

// Mock LoadingSpinner
jest.mock('../components/common/LoadingSpinner', () => {
  return function MockLoadingSpinner({ message }) {
    return <div data-testid="loading-spinner">{message || 'Loading...'}</div>;
  };
});

// Helper to create a test store
const createTestStore = (initialState = {}) => {
  return configureStore({
    reducer: {
      auth: authReducer,
      app: appReducer,
    },
    preloadedState: initialState,
  });
};

// Helper to render component with providers
const renderRegisterScreen = (store = createTestStore()) => {
  return render(
    <Provider store={store}>
      <RegisterScreen />
    </Provider>
  );
};

describe('RegisterScreen', () => {
  beforeEach(() => {
    jest.clearAllMocks();
    mockNavigate.mockClear();
  });

  describe('Rendering', () => {
    it('should render the registration form', () => {
      renderRegisterScreen();

      expect(screen.getByText('Create your account')).toBeInTheDocument();
      expect(screen.getByText('Sign Up')).toBeInTheDocument();
      expect(screen.getByLabelText(/full name/i)).toBeInTheDocument();
      expect(screen.getByLabelText(/mobile number/i)).toBeInTheDocument();
      expect(screen.getByLabelText(/email address/i)).toBeInTheDocument();
      expect(screen.getByLabelText(/gender/i)).toBeInTheDocument();
      expect(screen.getByText('Create Account')).toBeInTheDocument();
    });

    it('should render all form fields with correct attributes', () => {
      renderRegisterScreen();

      const nameField = screen.getByLabelText(/full name/i);
      const mobileField = screen.getByLabelText(/mobile number/i);
      const emailField = screen.getByLabelText(/email address/i);

      expect(nameField).toHaveAttribute('type', 'text');
      expect(mobileField).toHaveAttribute('type', 'tel');
      expect(emailField).toHaveAttribute('type', 'email');
    });

    it('should render gender select options', () => {
      renderRegisterScreen();

      const genderSelect = screen.getByLabelText(/gender/i);
      expect(genderSelect).toBeInTheDocument();

      // Open the select
      fireEvent.mouseDown(genderSelect);

      expect(screen.getByText('Male')).toBeInTheDocument();
      expect(screen.getByText('Female')).toBeInTheDocument();
      expect(screen.getByText('Other')).toBeInTheDocument();
    });

    it('should render terms and conditions checkbox', () => {
      renderRegisterScreen();

      const checkbox = screen.getByRole('checkbox');
      expect(checkbox).toBeInTheDocument();
      expect(screen.getByText(/i agree to the/i)).toBeInTheDocument();
    });
  });

  describe('Form Validation', () => {
    it('should show validation errors for empty required fields', async () => {
      renderRegisterScreen();

      const submitButton = screen.getByText('Create Account');
      fireEvent.click(submitButton);

      await waitFor(() => {
        expect(screen.getByText('Name is required')).toBeInTheDocument();
        expect(screen.getByText('Mobile number is required')).toBeInTheDocument();
        expect(screen.getByText('Email is required')).toBeInTheDocument();
        expect(screen.getByText('Please select your gender')).toBeInTheDocument();
        expect(screen.getByText('You must agree to the terms and conditions')).toBeInTheDocument();
      });
    });

    it('should validate name length', async () => {
      renderRegisterScreen();

      const nameField = screen.getByLabelText(/full name/i);
      fireEvent.change(nameField, { target: { value: 'A' } });

      const submitButton = screen.getByText('Create Account');
      fireEvent.click(submitButton);

      await waitFor(() => {
        expect(screen.getByText('Name must be at least 2 characters')).toBeInTheDocument();
      });
    });

    it('should validate mobile number format', async () => {
      renderRegisterScreen();

      const mobileField = screen.getByLabelText(/mobile number/i);
      fireEvent.change(mobileField, { target: { value: '123456789' } }); // 9 digits

      const submitButton = screen.getByText('Create Account');
      fireEvent.click(submitButton);

      await waitFor(() => {
        expect(screen.getByText('Please enter a valid 10-digit mobile number')).toBeInTheDocument();
      });
    });

    it('should validate email format', async () => {
      renderRegisterScreen();

      const emailField = screen.getByLabelText(/email address/i);
      fireEvent.change(emailField, { target: { value: 'invalid-email' } });

      const submitButton = screen.getByText('Create Account');
      fireEvent.click(submitButton);

      await waitFor(() => {
        expect(screen.getByText('Please enter a valid email address')).toBeInTheDocument();
      });
    });



    it('should clear validation errors when user starts typing', async () => {
      renderRegisterScreen();

      const submitButton = screen.getByText('Create Account');
      fireEvent.click(submitButton);

      await waitFor(() => {
        expect(screen.getByText('Name is required')).toBeInTheDocument();
      });

      const nameField = screen.getByLabelText(/full name/i);
      fireEvent.change(nameField, { target: { value: 'J' } });

      await waitFor(() => {
        expect(screen.queryByText('Name is required')).not.toBeInTheDocument();
      });
    });
  });

  describe('Form Submission', () => {
    const validFormData = {
      name: 'John Doe',
      mobile: '9876543210',
      email: 'john@example.com',
      gender: 'male',
      agreeToTerms: true,
    };

    const fillForm = () => {
      // Fill out the form with valid data
      const nameField = screen.getByLabelText(/full name/i);
      const mobileField = screen.getByLabelText(/mobile number/i);
      const emailField = screen.getByLabelText(/email address/i);
      const genderField = screen.getByLabelText(/gender/i);
      const termsCheckbox = screen.getByRole('checkbox');

      fireEvent.change(nameField, { target: { value: validFormData.name } });
      fireEvent.change(mobileField, { target: { value: validFormData.mobile } });
      fireEvent.change(emailField, { target: { value: validFormData.email } });
      fireEvent.mouseDown(genderField);
      fireEvent.click(screen.getByText('Male'));
      fireEvent.click(termsCheckbox);
    };

    it('should submit form with correct data on successful registration', async () => {
      renderRegisterScreen();

      fillForm();

      const mockResponse = { status: true, message: 'Registration successful' };
      apiService.register.mockResolvedValue(mockResponse);

      const submitButton = screen.getByText('Create Account');
      fireEvent.click(submitButton);

      await waitFor(() => {
        expect(apiService.register).toHaveBeenCalledWith({
          user_name: validFormData.name,
          user_email: validFormData.email,
          mobile_number: validFormData.mobile,
          user_gender: validFormData.gender,
          device_id: 'web-app',
        });
      }).catch(() => {
        // Ignore unwrap rejection for test
      });

      // Should navigate to login page after successful registration
      await waitFor(() => {
        expect(mockNavigate).toHaveBeenCalledWith('/login', { replace: true });
      });
    });

    it('should show loading spinner during submission', async () => {
      renderRegisterScreen();

      fillForm();

      // Mock a delayed response
      apiService.register.mockImplementation(() => new Promise(resolve => setTimeout(resolve, 100)));

      const submitButton = screen.getByRole('button', { name: /create account/i });
      fireEvent.click(submitButton);

      // Check that button is disabled during loading
      expect(submitButton).toBeDisabled();

      // Wait for the promise to resolve
      await waitFor(() => {
        expect(submitButton).not.toBeDisabled();
      });
    });

    it('should display error message on registration failure', async () => {
      renderRegisterScreen();

      fillForm();

      const errorMessage = 'Email already exists';
      apiService.register.mockResolvedValue({ status: false, message: errorMessage });

      const submitButton = screen.getByText('Create Account');
      fireEvent.click(submitButton);

      await waitFor(() => {
        expect(screen.getByText(errorMessage)).toBeInTheDocument();
      });

      // Should not navigate
      expect(mockNavigate).not.toHaveBeenCalled();
    });

    it('should handle API errors gracefully', async () => {
      renderRegisterScreen();

      fillForm();

      const errorMessage = 'Network error';
      apiService.register.mockRejectedValue(new Error(errorMessage));

      const submitButton = screen.getByText('Create Account');
      fireEvent.click(submitButton);

      await waitFor(() => {
        expect(screen.getByText(errorMessage)).toBeInTheDocument();
      });
    });
  });



  describe('Navigation', () => {
    it('should navigate to login page when sign in link is clicked', () => {
      renderRegisterScreen();

      const signInLink = screen.getByText('Sign In');
      fireEvent.click(signInLink);

      expect(signInLink.closest('a')).toHaveAttribute('href', '/login');
    });

    it('should redirect to home if already authenticated', () => {
      const authenticatedStore = createTestStore({
        auth: {
          isAuthenticated: true,
          user: { id: 1, name: 'John' },
          token: 'token',
          loading: false,
          error: null,
        },
      });

      renderRegisterScreen(authenticatedStore);

      expect(mockNavigate).toHaveBeenCalledWith('/', { replace: true });
    });
  });
});
