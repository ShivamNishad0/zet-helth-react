import { createSlice, createAsyncThunk } from '@reduxjs/toolkit';

// Initial state
const initialState = {
  items: [],
  totalAmount: 0,
  discountAmount: 0,
  payableAmount: 0,
  loading: false,
};

// Async thunks
export const fetchCart = createAsyncThunk(
  'cart/fetchCart',
  async (_, { rejectWithValue }) => {
    try {
      // Mock API call for now
      const response = { status: true, data: { cartList: [] } };
      if (response.status) {
        return response;
      } else {
        return rejectWithValue(response.message || 'Failed to fetch cart');
      }
    } catch (error) {
      return rejectWithValue(error.message);
    }
  }
);

export const addToCart = createAsyncThunk(
  'cart/addToCart',
  async (cartData, { rejectWithValue }) => {
    try {
      // Mock API call for now
      const response = { status: true };
      if (response.status) {
        return response;
      } else {
        return rejectWithValue(response.message || 'Failed to add to cart');
      }
    } catch (error) {
      return rejectWithValue(error.message);
    }
  }
);

export const clearCartItems = createAsyncThunk(
  'cart/clearCart',
  async (_, { rejectWithValue }) => {
    try {
      // Mock API call for now
      const response = { status: true };
      if (response.status) {
        return response;
      } else {
        return rejectWithValue(response.message || 'Failed to clear cart');
      }
    } catch (error) {
      return rejectWithValue(error.message);
    }
  }
);

// Cart slice
const cartSlice = createSlice({
  name: 'cart',
  initialState,
  reducers: {
    setLoading: (state, action) => {
      state.loading = action.payload;
    },
    setCartItems: (state, action) => {
      state.items = action.payload;
      // Recalculate totals
      state.totalAmount = action.payload.reduce((sum, item) => sum + (item.itemPrice || 0), 0);
      state.payableAmount = state.totalAmount - state.discountAmount;
    },
    addItem: (state, action) => {
      const existingItem = state.items.find(item => item.id === action.payload.id);
      if (existingItem) {
        existingItem.quantity = (existingItem.quantity || 1) + 1;
      } else {
        state.items.push({ ...action.payload, quantity: 1 });
      }
      // Recalculate totals
      state.totalAmount = state.items.reduce((sum, item) => sum + ((item.itemPrice || 0) * (item.quantity || 1)), 0);
      state.payableAmount = state.totalAmount - state.discountAmount;
    },
    removeItem: (state, action) => {
      state.items = state.items.filter(item => item.id !== action.payload);
      // Recalculate totals
      state.totalAmount = state.items.reduce((sum, item) => sum + ((item.itemPrice || 0) * (item.quantity || 1)), 0);
      state.payableAmount = state.totalAmount - state.discountAmount;
    },
    updateQuantity: (state, action) => {
      const item = state.items.find(item => item.id === action.payload.id);
      if (item) {
        item.quantity = action.payload.quantity;
        // Recalculate totals
        state.totalAmount = state.items.reduce((sum, item) => sum + ((item.itemPrice || 0) * (item.quantity || 1)), 0);
        state.payableAmount = state.totalAmount - state.discountAmount;
      }
    },
    setDiscount: (state, action) => {
      state.discountAmount = action.payload;
      state.payableAmount = state.totalAmount - state.discountAmount;
    },
    clearCart: (state) => {
      state.items = [];
      state.totalAmount = 0;
      state.discountAmount = 0;
      state.payableAmount = 0;
    },
  },
  extraReducers: (builder) => {
    // Fetch Cart
    builder
      .addCase(fetchCart.pending, (state) => {
        state.loading = true;
      })
      .addCase(fetchCart.fulfilled, (state, action) => {
        state.loading = false;
        const data = action.payload.data;

        if (data?.cartList && data.cartList.length > 0) {
          // Parse cart JSON string
          try {
            const cartJson = JSON.parse(data.cartList[0].cartJson);
            const cartModel = cartJson;

            if (cartModel.itemList) {
              state.items = cartModel.itemList;
              state.totalAmount = cartModel.totalAmount || 0;
              state.discountAmount = cartModel.discountAmount || 0;
              state.payableAmount = cartModel.payableAmount || 0;
            }
          } catch (error) {
            console.error('Error parsing cart data:', error);
          }
        }
      })
      .addCase(fetchCart.rejected, (state) => {
        state.loading = false;
      });

    // Add to Cart
    builder
      .addCase(addToCart.pending, (state) => {
        state.loading = true;
      })
      .addCase(addToCart.fulfilled, (state) => {
        state.loading = false;
        // Cart updated successfully, you might want to refetch cart data
      })
      .addCase(addToCart.rejected, (state) => {
        state.loading = false;
      });

    // Clear Cart
    builder
      .addCase(clearCartItems.pending, (state) => {
        state.loading = true;
      })
      .addCase(clearCartItems.fulfilled, (state) => {
        state.loading = false;
        state.items = [];
        state.totalAmount = 0;
        state.discountAmount = 0;
        state.payableAmount = 0;
      })
      .addCase(clearCartItems.rejected, (state) => {
        state.loading = false;
      });
  },
});

export const {
  setLoading,
  setCartItems,
  addItem,
  removeItem,
  updateQuantity,
  setDiscount,
  clearCart,
} = cartSlice.actions;

export default cartSlice.reducer;
