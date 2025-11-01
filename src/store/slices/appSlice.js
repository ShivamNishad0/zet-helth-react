import { createSlice } from '@reduxjs/toolkit';

// Initial state
const initialState = {
  loading: false,
  toast: {
    message: '',
    type: 'info',
    visible: false,
  },
};

// App slice
const appSlice = createSlice({
  name: 'app',
  initialState,
  reducers: {
    setLoading: (state, action) => {
      state.loading = action.payload;
    },
    showToast: (state, action) => {
      state.toast = {
        message: action.payload.message,
        type: action.payload.type,
        visible: true,
      };
    },
    hideToast: (state) => {
      state.toast.visible = false;
    },
    clearToast: (state) => {
      state.toast = {
        message: '',
        type: 'info',
        visible: false,
      };
    },
  },
});

export const { setLoading, showToast, hideToast, clearToast } = appSlice.actions;
export default appSlice.reducer;
