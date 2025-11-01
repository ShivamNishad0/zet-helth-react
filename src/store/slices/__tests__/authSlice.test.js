import authReducer, {
  sendOtp,
  verifyOtp,
  registerUser,
  logoutUser,
  setUser,
  setToken,
  clearAuth,
  setLoading,
  setError,
  initializeAuth,
} from '../authSlice';
import { configureStore } from '@reduxjs/toolkit';

// Mock localStorage
const localStorageMock = {
  getItem: jest.fn(),
  setItem: jest.fn(),
  removeItem: jest.fn(),
  clear: jest.fn(),
};
Object.defineProperty(window, 'localStorage', {
  value: localStorageMock,
});

// Mock apiService
jest.mock('../../../services/api', () => ({
  apiService: {
    sendOtp: jest.fn(),
    verifyOtp: jest.fn(),
    register: jest.fn(),
    logout: jest.fn(),
  },
}));

import { apiService } from '../../../services/api';

// Helper to create a test store
const createTestStore = () => {
  return configureStore({
    reducer: {
      auth: authReducer,
    },
  });
};

describe('authSlice', () => {
  let store;

  beforeEach(() => {
    store = createTestStore();
    jest.clearAllMocks();
    localStorageMock.clear();
  });

  describe('initial state', () => {
    it('should return the initial state', () => {
      const state = store.getState().auth;
      expect(state).toEqual({
        isAuthenticated: false,
        user: null,
        token: null,
        loading: false,
        error: null,
      });
    });
  });

  describe('reducers', () => {
    it('should handle setUser', () => {
      const mockUser = { id: 1, name: 'John Doe' };
      store.dispatch(setUser(mockUser));
      expect(store.getState().auth.user).toEqual(mockUser);
      expect(store.getState().auth.isAuthenticated).toBe(true);
    });

    it('should handle setToken', () => {
      const mockToken = 'mock-token';
      store.dispatch(setToken(mockToken));
      expect(store.getState().auth.token).toEqual(mockToken);
      expect(localStorageMock.setItem).toHaveBeenCalledWith('token', mockToken);
    });

    it('should handle clearAuth', () => {
      // Set some state first
      store.dispatch(setUser({ id: 1, name: 'John' }));
      store.dispatch(setToken('token'));
      store.dispatch(setError('error'));

      store.dispatch(clearAuth());
      const state = store.getState().auth;
      expect(state.isAuthenticated).toBe(false);
      expect(state.user).toBe(null);
      expect(state.token).toBe(null);
      expect(state.error).toBe(null);
      expect(localStorageMock.removeItem).toHaveBeenCalledWith('token');
      expect(localStorageMock.removeItem).toHaveBeenCalledWith('user_mobile');
    });

    it('should handle setLoading', () => {
      store.dispatch(setLoading(true));
      expect(store.getState().auth.loading).toBe(true);

      store.dispatch(setLoading(false));
      expect(store.getState().auth.loading).toBe(false);
    });

    it('should handle setError', () => {
      const errorMessage = 'Test error';
      store.dispatch(setError(errorMessage));
      expect(store.getState().auth.error).toEqual(errorMessage);
    });

    it('should handle initializeAuth with token and user_mobile', () => {
      localStorageMock.getItem.mockImplementation((key) => {
        if (key === 'token') return 'mock-token';
        if (key === 'user_mobile') return '1234567890';
        return null;
      });

      store.dispatch(initializeAuth());
      const state = store.getState().auth;
      expect(state.token).toBe('mock-token');
      expect(state.isAuthenticated).toBe(true);
    });

    it('should handle initializeAuth without token', () => {
      localStorageMock.getItem.mockReturnValue(null);

      store.dispatch(initializeAuth());
      const state = store.getState().auth;
      expect(state.token).toBe(null);
      expect(state.isAuthenticated).toBe(false);
    });
  });

  describe('async thunks', () => {
    describe('sendOtp', () => {
      it('should handle sendOtp.fulfilled', async () => {
        const mockResponse = {
          status: true,
          message: 'OTP sent successfully',
        };
        apiService.sendOtp.mockResolvedValue(mockResponse);

        await store.dispatch(sendOtp({ mobile_number: '1234567890', user_type: 'User' }));

        const state = store.getState().auth;
        expect(state.loading).toBe(false);
        expect(state.error).toBe(null);
      });

      it('should handle sendOtp.rejected', async () => {
        const errorMessage = 'Failed to send OTP';
        apiService.sendOtp.mockRejectedValue(new Error(errorMessage));

        await store.dispatch(sendOtp({ mobile_number: '1234567890', user_type: 'User' }));

        const state = store.getState().auth;
        expect(state.loading).toBe(false);
        expect(state.error).toEqual(errorMessage);
      });

      it('should handle sendOtp with status false', async () => {
        const mockResponse = {
          status: false,
          message: 'Failed to send OTP',
        };
        apiService.sendOtp.mockResolvedValue(mockResponse);

        await store.dispatch(sendOtp({ mobile_number: '1234567890', user_type: 'User' }));

        const state = store.getState().auth;
        expect(state.loading).toBe(false);
        expect(state.error).toEqual('Failed to send OTP');
      });
    });

    describe('verifyOtp', () => {
      it('should handle verifyOtp.fulfilled', async () => {
        const mockResponse = {
          status: true,
          data: {
            userDetail: { id: 1, name: 'John', userMobile: '1234567890' },
            token: 'mock-token',
          },
        };
        apiService.verifyOtp.mockResolvedValue(mockResponse);

        await store.dispatch(verifyOtp({ mobile_number: '1234567890', otp: '123456', user_type: 'User' }));

        const state = store.getState().auth;
        expect(state.loading).toBe(false);
        expect(state.isAuthenticated).toBe(true);
        expect(state.user).toEqual(mockResponse.data.userDetail);
        expect(state.token).toEqual('mock-token');
        expect(localStorageMock.setItem).toHaveBeenCalledWith('token', 'mock-token');
        expect(localStorageMock.setItem).toHaveBeenCalledWith('user_mobile', '1234567890');
      });

      it('should handle verifyOtp.rejected', async () => {
        const errorMessage = 'Invalid OTP';
        apiService.verifyOtp.mockRejectedValue(new Error(errorMessage));

        await store.dispatch(verifyOtp({ mobile_number: '1234567890', otp: '123456', user_type: 'User' }));

        const state = store.getState().auth;
        expect(state.loading).toBe(false);
        expect(state.error).toEqual(errorMessage);
        expect(state.isAuthenticated).toBe(false);
      });

      it('should handle verifyOtp with status false', async () => {
        const mockResponse = {
          status: false,
          message: 'OTP verification failed',
        };
        apiService.verifyOtp.mockResolvedValue(mockResponse);

        await store.dispatch(verifyOtp({ mobile_number: '1234567890', otp: '123456', user_type: 'User' }));

        const state = store.getState().auth;
        expect(state.loading).toBe(false);
        expect(state.error).toEqual('OTP verification failed');
        expect(state.isAuthenticated).toBe(false);
      });
    });

    describe('registerUser', () => {
      it('should handle registerUser.fulfilled', async () => {
        const mockResponse = {
          status: true,
          message: 'Registration successful',
        };
        apiService.register.mockResolvedValue(mockResponse);

        const userData = {
          user_name: 'John Doe',
          user_email: 'john@example.com',
          mobile_number: '1234567890',
          password: 'password123',
          user_gender: 'male',
          device_id: 'web-app',
        };

        await store.dispatch(registerUser(userData));

        const state = store.getState().auth;
        expect(state.loading).toBe(false);
        expect(state.error).toBe(null);
        // Registration doesn't set user as authenticated
        expect(state.isAuthenticated).toBe(false);
      });

      it('should handle registerUser.rejected', async () => {
        const errorMessage = 'Registration failed';
        apiService.register.mockRejectedValue(new Error(errorMessage));

        const userData = {
          user_name: 'John Doe',
          user_email: 'john@example.com',
          mobile_number: '1234567890',
          password: 'password123',
          user_gender: 'male',
          device_id: 'web-app',
        };

        await store.dispatch(registerUser(userData));

        const state = store.getState().auth;
        expect(state.loading).toBe(false);
        expect(state.error).toEqual(errorMessage);
      });

      it('should handle registerUser with status false', async () => {
        const mockResponse = {
          status: false,
          message: 'Email already exists',
        };
        apiService.register.mockResolvedValue(mockResponse);

        const userData = {
          user_name: 'John Doe',
          user_email: 'john@example.com',
          mobile_number: '1234567890',
          password: 'password123',
          user_gender: 'male',
          device_id: 'web-app',
        };

        await store.dispatch(registerUser(userData));

        const state = store.getState().auth;
        expect(state.loading).toBe(false);
        expect(state.error).toEqual('Email already exists');
      });
    });

    describe('logoutUser', () => {
      it('should handle logoutUser.fulfilled', async () => {
        // Set authenticated state first
        store.dispatch(setUser({ id: 1, name: 'John' }));
        store.dispatch(setToken('token'));

        const mockResponse = { status: true };
        apiService.logout.mockResolvedValue(mockResponse);

        await store.dispatch(logoutUser());

        const state = store.getState().auth;
        expect(state.loading).toBe(false);
        expect(state.isAuthenticated).toBe(false);
        expect(state.user).toBe(null);
        expect(state.token).toBe(null);
        expect(localStorageMock.removeItem).toHaveBeenCalledWith('token');
        expect(localStorageMock.removeItem).toHaveBeenCalledWith('user_mobile');
      });

      it('should handle logoutUser.rejected', async () => {
        // Set authenticated state first
        store.dispatch(setUser({ id: 1, name: 'John' }));
        store.dispatch(setToken('token'));

        const errorMessage = 'Logout failed';
        apiService.logout.mockRejectedValue(new Error(errorMessage));

        await store.dispatch(logoutUser());

        const state = store.getState().auth;
        expect(state.loading).toBe(false);
        expect(state.error).toEqual(errorMessage);
        // Even on error, local state should be cleared
        expect(state.isAuthenticated).toBe(false);
        expect(state.user).toBe(null);
        expect(state.token).toBe(null);
      });
    });
  });
});
