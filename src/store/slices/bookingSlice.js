import { createSlice, createAsyncThunk } from '@reduxjs/toolkit';

// Initial state
const initialState = {
  bookings: [],
  currentBooking: null,
  loading: false,
};

// Async thunks
export const fetchBookings = createAsyncThunk(
  'booking/fetchBookings',
  async (_, { rejectWithValue }) => {
    try {
      // Mock API call for now
      const response = { status: true, data: { bookingList: [] } };
      if (response.status) {
        return response;
      } else {
        return rejectWithValue(response.message || 'Failed to fetch bookings');
      }
    } catch (error) {
      return rejectWithValue(error.message);
    }
  }
);

export const createBooking = createAsyncThunk(
  'booking/createBooking',
  async (bookingData, { rejectWithValue }) => {
    try {
      // Mock API call for now
      const response = { status: true, data: { booking: bookingData } };
      if (response.status) {
        return response;
      } else {
        return rejectWithValue(response.message || 'Failed to create booking');
      }
    } catch (error) {
      return rejectWithValue(error.message);
    }
  }
);

export const fetchBookingDetails = createAsyncThunk(
  'booking/fetchBookingDetails',
  async (bookingId, { rejectWithValue }) => {
    try {
      // Mock API call for now
      const response = { status: true, data: { booking: { id: bookingId } } };
      if (response.status) {
        return response;
      } else {
        return rejectWithValue(response.message || 'Failed to fetch booking details');
      }
    } catch (error) {
      return rejectWithValue(error.message);
    }
  }
);

export const getSlots = createAsyncThunk(
  'booking/getSlots',
  async (slotData, { rejectWithValue }) => {
    try {
      // Mock API call for now
      const response = { status: true, data: { slots: [] } };
      if (response.status) {
        return response;
      } else {
        return rejectWithValue(response.message || 'Failed to fetch slots');
      }
    } catch (error) {
      return rejectWithValue(error.message);
    }
  }
);

// Booking slice
const bookingSlice = createSlice({
  name: 'booking',
  initialState,
  reducers: {
    setLoading: (state, action) => {
      state.loading = action.payload;
    },
    setBookings: (state, action) => {
      state.bookings = action.payload;
    },
    setCurrentBooking: (state, action) => {
      state.currentBooking = action.payload;
    },
    addBooking: (state, action) => {
      state.bookings.unshift(action.payload); // Add to beginning of array
    },
    updateBooking: (state, action) => {
      const index = state.bookings.findIndex(booking => booking.id === action.payload.id);
      if (index !== -1) {
        state.bookings[index] = action.payload;
      }
    },
    clearBookings: (state) => {
      state.bookings = [];
      state.currentBooking = null;
    },
  },
  extraReducers: (builder) => {
    // Fetch Bookings
    builder
      .addCase(fetchBookings.pending, (state) => {
        state.loading = true;
      })
      .addCase(fetchBookings.fulfilled, (state, action) => {
        state.loading = false;
        if (action.payload.data?.bookingList) {
          state.bookings = action.payload.data.bookingList;
        }
      })
      .addCase(fetchBookings.rejected, (state) => {
        state.loading = false;
      });

    // Create Booking
    builder
      .addCase(createBooking.pending, (state) => {
        state.loading = true;
      })
      .addCase(createBooking.fulfilled, (state, action) => {
        state.loading = false;
        if (action.payload.data?.booking) {
          state.bookings.unshift(action.payload.data.booking);
        }
      })
      .addCase(createBooking.rejected, (state) => {
        state.loading = false;
      });

    // Fetch Booking Details
    builder
      .addCase(fetchBookingDetails.pending, (state) => {
        state.loading = true;
      })
      .addCase(fetchBookingDetails.fulfilled, (state, action) => {
        state.loading = false;
        if (action.payload.data?.booking) {
          state.currentBooking = action.payload.data.booking;
        }
      })
      .addCase(fetchBookingDetails.rejected, (state) => {
        state.loading = false;
      });

    // Get Slots
    builder
      .addCase(getSlots.pending, (state) => {
        state.loading = true;
      })
      .addCase(getSlots.fulfilled, (state) => {
        state.loading = false;
        // Slots data would be handled by the component
      })
      .addCase(getSlots.rejected, (state) => {
        state.loading = false;
      });
  },
});

export const {
  setLoading,
  setBookings,
  setCurrentBooking,
  addBooking,
  updateBooking,
  clearBookings,
} = bookingSlice.actions;

export default bookingSlice.reducer;
