
import { createSlice, createAsyncThunk } from '@reduxjs/toolkit';
import { apiService } from '../../services/api';

// Initial state
const initialState = {
  isAuthenticated: false,
  user: null,
  token: null,
  loading: false,
  error: null,
};

// Async thunks
export const sendOtp = createAsyncThunk(
  'auth/sendOtp',
  async (data, { rejectWithValue }) => {
    try {
      const response = await apiService.sendOtp(data);
      if (response.status) {
        return response;
      } else {
        return rejectWithValue(response.message || 'Failed to send OTP');
      }
    } catch (error) {
      return rejectWithValue(error.message);
    }
  }
);

export const sendOtpForRegistration = createAsyncThunk(
  'auth/sendOtpForRegistration',
  async (data, { rejectWithValue }) => {
    try {
      const response = await apiService.sendOtpForRegistration(data);
      if (response.status) {
        return response;
      } else {
        return rejectWithValue(response.message || 'Failed to send OTP');
      }
    } catch (error) {
      return rejectWithValue(error.message);
    }
  }
);

export const verifyOtp = createAsyncThunk(
  'auth/verifyOtp',
  async (data, { rejectWithValue }) => {
    try {
      const response = await apiService.verifyOtp(data);
      if (response.status) {
        return response;
      } else {
        return rejectWithValue(response.message || 'OTP verification failed');
      }
    } catch (error) {
      return rejectWithValue(error.message);
    }
  }
);

export const registerUser = createAsyncThunk(
  'auth/register',
  async (userData, { rejectWithValue }) => {
    try {
      const response = await apiService.register(userData);
      if (response.status) {
        return response;
      } else {
        return rejectWithValue(response.message || 'Registration failed');
      }
    } catch (error) {
      return rejectWithValue(error.message);
    }
  }
);

export const logoutUser = createAsyncThunk(
  'auth/logout',
  async (_, { rejectWithValue }) => {
    try {
      const response = await apiService.logout();
      return response;
    } catch (error) {
      return rejectWithValue(error.message);
    }
  }
);

// Auth slice
const authSlice = createSlice({
  name: 'auth',
  initialState,
  reducers: {
    setUser: (state, action) => {
      state.user = action.payload;
      state.isAuthenticated = true;
    },
    setToken: (state, action) => {
      state.token = action.payload;
      localStorage.setItem('token', action.payload);
    },
    clearAuth: (state) => {
      state.isAuthenticated = false;
      state.user = null;
      state.token = null;
      state.error = null;
      localStorage.removeItem('token');
      localStorage.removeItem('user_mobile');
    },
    setLoading: (state, action) => {
      state.loading = action.payload;
    },
    setError: (state, action) => {
      state.error = action.payload;
    },
    initializeAuth: (state) => {
      const token = localStorage.getItem('token');
      const userMobile = localStorage.getItem('user_mobile');

      if (token && userMobile) {
        state.token = token;
        state.isAuthenticated = true;
        // Note: User details would need to be fetched separately
      }
    },
  },
  extraReducers: (builder) => {
    // Login User
    builder
      .addCase(sendOtp.pending, (state) => {
        state.loading = true;
        state.error = null;
      })
      .addCase(sendOtp.fulfilled, (state, action) => {
        state.loading = false;
      })
      .addCase(sendOtp.rejected, (state, action) => {
        state.loading = false;
        state.error = action.payload;
      })
      .addCase(verifyOtp.pending, (state) => {
        state.loading = true;
        state.error = null;
      })
      .addCase(verifyOtp.fulfilled, (state, action) => {
        state.loading = false;
        console.log('OTP verification response:', action.payload);

        // Check for user data in different possible response structures
        const payload = action.payload;
        const userDetail = payload.data?.userDetail || payload.data?.user || payload.userDetail || payload.user || payload.data?.user_detail || payload.user_detail;
        const token = payload.data?.token || payload.token;

        console.log('Extracted userDetail:', userDetail);
        console.log('Extracted token:', token);

        // Since backend always returns success regardless of OTP validity,
        // we need to check if this is actually a verification attempt vs OTP sending
        // For now, assume all responses with userDetail and token are successful
        // The real fix needs to be on the backend to properly validate OTPs
        if (userDetail && token) {
          state.isAuthenticated = true;
          state.user = userDetail;
          state.token = token;
          localStorage.setItem('token', token);
          if (userDetail.userMobile || userDetail.mobile_number) {
            localStorage.setItem('user_mobile', userDetail.userMobile || userDetail.mobile_number);
          }
          console.log('User authenticated successfully');
        } else {
          // If response doesn't contain expected data, treat as error
          state.error = 'OTP verification failed - invalid response';
          state.isAuthenticated = false;
          console.log('Authentication failed - missing user data or token');
        }
      })
      .addCase(verifyOtp.rejected, (state, action) => {
        state.loading = false;
        state.error = action.payload;
        // Ensure user is not authenticated on verification failure
        state.isAuthenticated = false;
      })

    // Register
    builder
      .addCase(registerUser.pending, (state) => {
        state.loading = true;
        state.error = null;
      })
      .addCase(registerUser.fulfilled, (state, action) => {
        state.loading = false;
        // Registration successful, but user needs to login
      })
      .addCase(registerUser.rejected, (state, action) => {
        state.loading = false;
        state.error = action.payload;
      });

    // Logout
    builder
      .addCase(logoutUser.pending, (state) => {
        state.loading = true;
      })
      .addCase(logoutUser.fulfilled, (state) => {
        state.loading = false;
        state.isAuthenticated = false;
        state.user = null;
        state.token = null;
        localStorage.removeItem('token');
        localStorage.removeItem('user_mobile');
      })
      .addCase(logoutUser.rejected, (state, action) => {
        state.loading = false;
        state.error = action.payload;
        // Even if logout fails on server, clear local state
        state.isAuthenticated = false;
        state.user = null;
        state.token = null;
        localStorage.removeItem('token');
        localStorage.removeItem('user_mobile');
      });
  },
});

export const { setUser, setToken, clearAuth, setLoading, setError, initializeAuth } = authSlice.actions;
export default authSlice.reducer;
