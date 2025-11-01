import bookingReducer, {
  setLoading,
  setBookings,
  setCurrentBooking,
  addBooking,
  updateBooking,
  clearBookings,
  fetchBookings,
  createBooking,
  fetchBookingDetails,
  getSlots,
} from '../bookingSlice';
import { configureStore } from '@reduxjs/toolkit';

// Helper to create a test store
const createTestStore = () => {
  return configureStore({
    reducer: {
      booking: bookingReducer,
    },
  });
};

describe('bookingSlice', () => {
  let store;

  beforeEach(() => {
    store = createTestStore();
  });

  describe('initial state', () => {
    it('should return the initial state', () => {
      const state = store.getState().booking;
      expect(state).toEqual({
        bookings: [],
        currentBooking: null,
        loading: false,
      });
    });
  });

  describe('reducers', () => {
    it('should handle setLoading', () => {
      store.dispatch(setLoading(true));
      expect(store.getState().booking.loading).toBe(true);

      store.dispatch(setLoading(false));
      expect(store.getState().booking.loading).toBe(false);
    });

    it('should handle setBookings', () => {
      const mockBookings = [{ id: 1, name: 'Booking 1' }];
      store.dispatch(setBookings(mockBookings));
      expect(store.getState().booking.bookings).toEqual(mockBookings);
    });

    it('should handle setCurrentBooking', () => {
      const mockBooking = { id: 1, name: 'Booking 1' };
      store.dispatch(setCurrentBooking(mockBooking));
      expect(store.getState().booking.currentBooking).toEqual(mockBooking);
    });

    it('should handle addBooking', () => {
      const mockBooking1 = { id: 1, name: 'Booking 1' };
      const mockBooking2 = { id: 2, name: 'Booking 2' };

      store.dispatch(addBooking(mockBooking1));
      expect(store.getState().booking.bookings).toEqual([mockBooking1]);

      store.dispatch(addBooking(mockBooking2));
      expect(store.getState().booking.bookings).toEqual([mockBooking2, mockBooking1]); // unshift adds to beginning
    });

    it('should handle updateBooking', () => {
      const mockBooking = { id: 1, name: 'Booking 1' };
      const updatedBooking = { id: 1, name: 'Updated Booking 1' };

      store.dispatch(addBooking(mockBooking));
      store.dispatch(updateBooking(updatedBooking));
      expect(store.getState().booking.bookings).toEqual([updatedBooking]);
    });

    it('should handle clearBookings', () => {
      const mockBooking = { id: 1, name: 'Booking 1' };
      store.dispatch(addBooking(mockBooking));
      store.dispatch(setCurrentBooking(mockBooking));
      store.dispatch(setLoading(true));

      store.dispatch(clearBookings());
      expect(store.getState().booking.bookings).toEqual([]);
      expect(store.getState().booking.currentBooking).toBe(null);
      expect(store.getState().booking.loading).toBe(true); // loading not affected
    });
  });

  describe('async thunks', () => {
    it('should handle fetchBookings.fulfilled', () => {
      const mockBookings = [{ id: 1, name: 'Booking 1' }];
      const mockResponse = { status: true, data: { bookingList: mockBookings } };

      // Test the fulfilled action directly
      const action = { type: fetchBookings.fulfilled.type, payload: mockResponse };
      store.dispatch(action);
      expect(store.getState().booking.bookings).toEqual(mockBookings);
      expect(store.getState().booking.loading).toBe(false);
    });

    it('should handle createBooking.fulfilled', () => {
      const mockBooking = { id: 1, name: 'New Booking' };
      const mockResponse = { status: true, data: { booking: mockBooking } };

      const action = { type: createBooking.fulfilled.type, payload: mockResponse };
      store.dispatch(action);
      expect(store.getState().booking.bookings).toEqual([mockBooking]);
      expect(store.getState().booking.loading).toBe(false);
    });

    it('should handle fetchBookingDetails.fulfilled', () => {
      const mockBooking = { id: 1, name: 'Booking 1' };
      const mockResponse = { status: true, data: { booking: mockBooking } };

      const action = { type: fetchBookingDetails.fulfilled.type, payload: mockResponse };
      store.dispatch(action);
      expect(store.getState().booking.currentBooking).toEqual(mockBooking);
      expect(store.getState().booking.loading).toBe(false);
    });

    it('should handle getSlots.fulfilled', () => {
      const mockSlots = [{ id: 1, time: '10:00' }];
      const mockResponse = { status: true, data: { slots: mockSlots } };

      const action = { type: getSlots.fulfilled.type, payload: mockResponse };
      store.dispatch(action);
      // Slots are not stored in state, just loading set to false
      expect(store.getState().booking.loading).toBe(false);
    });

    // Note: Rejected cases are not tested as the mocked thunks always succeed.
    // In a real scenario, you could mock the API to throw errors.
  });
});
