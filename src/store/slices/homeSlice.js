import { createSlice, createAsyncThunk } from '@reduxjs/toolkit';

// Initial state
const initialState = {
  sliderList: [],
  popularPackages: [],
  lifestylePackages: [],
  popularTests: [],
  popularProfiles: [],
  branchList: [],
  loading: false,
};

// Async thunks
export const fetchHomeData = createAsyncThunk(
  'home/fetchHomeData',
  async (params, { rejectWithValue }) => {
    try {
      const { apiService } = await import('../../services/api');
      const response = await apiService.getHomeData(params);
      return response;
    } catch (error) {
      return rejectWithValue(error.message);
    }
  }
);

export const fetchHomeDataMock = createAsyncThunk(
  'home/fetchHomeDataMock',
  async (params, { rejectWithValue }) => {
    try {
      // Mock API call with sample data
      const mockData = {
        sliderList: [
          {
            id: 1,
            title: "Complete Health Checkup",
            description: "Comprehensive health screening package",
            image: "/images/slider1.jpg"
          },
          {
            id: 2,
            title: "Diabetes Care Package",
            description: "Monitor your blood sugar levels",
            image: "/images/slider2.jpg"
          }
        ],
        popularPackageList: [
          {
            id: 1,
            packageName: "Full Body Checkup",
            packageDescription: "Complete health assessment including 50+ tests",
            packagePrice: 2500,
            packageDiscountPrice: 1999
          },
          {
            id: 2,
            packageName: "Cardiac Health Package",
            packageDescription: "Comprehensive heart health screening",
            packagePrice: 1800,
            packageDiscountPrice: 1499
          },
          {
            id: 3,
            packageName: "Diabetes Screening",
            packageDescription: "Blood sugar and HbA1c monitoring",
            packagePrice: 800,
            packageDiscountPrice: 699
          },
          {
            id: 4,
            packageName: "Thyroid Profile",
            packageDescription: "Complete thyroid function assessment",
            packagePrice: 1200,
            packageDiscountPrice: 999
          },
          {
            id: 5,
            packageName: "Liver Function Test",
            packageDescription: "Comprehensive liver health check",
            packagePrice: 1500,
            packageDiscountPrice: 1299
          },
          {
            id: 6,
            packageName: "Kidney Function Test",
            packageDescription: "Complete kidney health assessment",
            packagePrice: 1000,
            packageDiscountPrice: 899
          }
        ],
        lifestylePackageList: [
          {
            id: 7,
            packageName: "Fitness Package",
            packageDescription: "Sports and fitness health screening",
            packagePrice: 2200,
            packageDiscountPrice: 1899
          },
          {
            id: 8,
            packageName: "Women's Health Package",
            packageDescription: "Comprehensive women's health check",
            packagePrice: 2800,
            packageDiscountPrice: 2399
          },
          {
            id: 9,
            packageName: "Senior Citizen Package",
            packageDescription: "Age-specific health screening for seniors",
            packagePrice: 3200,
            packageDiscountPrice: 2799
          },
          {
            id: 10,
            packageName: "Pre-Marital Package",
            packageDescription: "Health check before marriage",
            packagePrice: 3500,
            packageDiscountPrice: 2999
          },
          {
            id: 11,
            packageName: "Corporate Health Package",
            packageDescription: "Employee health screening program",
            packagePrice: 4000,
            packageDiscountPrice: 3499
          },
          {
            id: 12,
            packageName: "Travel Health Package",
            packageDescription: "Health check for international travel",
            packagePrice: 1800,
            packageDiscountPrice: 1599
          }
        ],
        testList: [
          {
            id: 13,
            testName: "Complete Blood Count (CBC)",
            testDescription: "Comprehensive blood analysis",
            testPrice: 300,
            testDiscountPrice: 250,
            isPopular: true
          },
          {
            id: 14,
            testName: "Lipid Profile",
            testDescription: "Cholesterol and triglyceride levels",
            testPrice: 500,
            testDiscountPrice: 450,
            isPopular: true
          },
          {
            id: 15,
            testName: "Blood Sugar (Fasting)",
            testDescription: "Fasting blood glucose test",
            testPrice: 100,
            testDiscountPrice: 80,
            isPopular: true
          },
          {
            id: 16,
            testName: "Thyroid Profile (T3, T4, TSH)",
            testDescription: "Complete thyroid function test",
            testPrice: 600,
            testDiscountPrice: 550,
            isPopular: true
          },
          {
            id: 17,
            testName: "Vitamin D Test",
            testDescription: "25-Hydroxy Vitamin D test",
            testPrice: 1200,
            testDiscountPrice: 1000,
            isPopular: true
          },
          {
            id: 18,
            testName: "Vitamin B12 Test",
            testDescription: "Vitamin B12 deficiency test",
            testPrice: 800,
            testDiscountPrice: 700,
            isPopular: true
          },
          {
            id: 19,
            testName: "Hemoglobin A1c (HbA1c)",
            testDescription: "3-month average blood sugar",
            testPrice: 400,
            testDiscountPrice: 350,
            isPopular: false
          },
          {
            id: 20,
            testName: "Liver Function Test (LFT)",
            testDescription: "SGOT, SGPT, Bilirubin, Albumin",
            testPrice: 700,
            testDiscountPrice: 650,
            isPopular: false
          },
          {
            id: 21,
            testName: "Kidney Function Test (KFT)",
            testDescription: "Creatinine, Urea, Uric Acid",
            testPrice: 500,
            testDiscountPrice: 450,
            isPopular: false
          }
        ],
        popularProfilesList: [],
        branchList: [
          {
            id: 1,
            branchName: "Zet Health Lab - Andheri",
            branchAddress: "Shop No. 5, ABC Complex, Andheri West, Mumbai - 400058"
          },
          {
            id: 2,
            branchName: "Zet Health Lab - Bandra",
            branchAddress: "Unit 12, XYZ Tower, Bandra East, Mumbai - 400051"
          },
          {
            id: 3,
            branchName: "Zet Health Lab - Thane",
            branchAddress: "Ground Floor, PQR Mall, Thane West - 400601"
          }
        ]
      };

      const response = { status: true, data: mockData };
      if (response.status) {
        return response;
      } else {
        return rejectWithValue(response.message || 'Failed to fetch home data');
      }
    } catch (error) {
      return rejectWithValue(error.message);
    }
  }
);

export const fetchPopularPackages = createAsyncThunk(
  'home/fetchPopularPackages',
  async (pincode, { rejectWithValue }) => {
    try {
      // Mock API call for now
      const response = { status: true, data: { packages: [] } };
      if (response.status) {
        return response;
      } else {
        return rejectWithValue(response.message || 'Failed to fetch packages');
      }
    } catch (error) {
      return rejectWithValue(error.message);
    }
  }
);

export const fetchPopularTests = createAsyncThunk(
  'home/fetchPopularTests',
  async (_, { rejectWithValue }) => {
    try {
      // Mock API call for now
      const response = { status: true, data: { testList: [] } };
      if (response.status) {
        return response;
      } else {
        return rejectWithValue(response.message || 'Failed to fetch tests');
      }
    } catch (error) {
      return rejectWithValue(error.message);
    }
  }
);

// Home slice
const homeSlice = createSlice({
  name: 'home',
  initialState,
  reducers: {
    setLoading: (state, action) => {
      state.loading = action.payload;
    },
    setSliderList: (state, action) => {
      state.sliderList = action.payload;
    },
    setPopularPackages: (state, action) => {
      state.popularPackages = action.payload;
    },
    setLifestylePackages: (state, action) => {
      state.lifestylePackages = action.payload;
    },
    setPopularTests: (state, action) => {
      state.popularTests = action.payload;
    },
    setPopularProfiles: (state, action) => {
      state.popularProfiles = action.payload;
    },
    setBranchList: (state, action) => {
      state.branchList = action.payload;
    },
    clearHomeData: (state) => {
      state.sliderList = [];
      state.popularPackages = [];
      state.lifestylePackages = [];
      state.popularTests = [];
      state.popularProfiles = [];
      state.branchList = [];
    },
  },
  extraReducers: (builder) => {
    // Fetch Home Data
    builder
      .addCase(fetchHomeData.pending, (state) => {
        state.loading = true;
      })
      .addCase(fetchHomeData.fulfilled, (state, action) => {
        state.loading = false;
        const data = action.payload.data;

        if (data?.sliderList) {
          state.sliderList = data.sliderList;
        }
        if (data?.popularPackageList) {
          state.popularPackages = data.popularPackageList;
        }
        if (data?.lifestylePackageList) {
          state.lifestylePackages = data.lifestylePackageList;
        }
        if (data?.testList) {
          state.popularTests = data.testList;
        }
        if (data?.popularProfilesList) {
          state.popularProfiles = data.popularProfilesList;
        }
        if (data?.branchList) {
          state.branchList = data.branchList;
        }
      })
      .addCase(fetchHomeData.rejected, (state) => {
        state.loading = false;
      });

    // Fetch Popular Packages
    builder
      .addCase(fetchPopularPackages.pending, (state) => {
        state.loading = true;
      })
      .addCase(fetchPopularPackages.fulfilled, (state, action) => {
        state.loading = false;
        if (action.payload.data?.packages) {
          // Separate lifestyle and regular packages
          const lifestylePackages = action.payload.data.packages.filter((pkg) => pkg.type === 'Lifestyle');
          const regularPackages = action.payload.data.packages.filter((pkg) => pkg.type !== 'Lifestyle');

          state.lifestylePackages = lifestylePackages;
          state.popularPackages = regularPackages;
        }
      })
      .addCase(fetchPopularPackages.rejected, (state) => {
        state.loading = false;
      });

    // Fetch Popular Tests
    builder
      .addCase(fetchPopularTests.pending, (state) => {
        state.loading = true;
      })
      .addCase(fetchPopularTests.fulfilled, (state, action) => {
        state.loading = false;
        if (action.payload.data?.testList) {
          state.popularTests = action.payload.data.testList;
        }
      })
      .addCase(fetchPopularTests.rejected, (state) => {
        state.loading = false;
      });
  },
});

export const {
  setLoading,
  setSliderList,
  setPopularPackages,
  setLifestylePackages,
  setPopularTests,
  setPopularProfiles,
  setBranchList,
  clearHomeData,
} = homeSlice.actions;

export default homeSlice.reducer;
