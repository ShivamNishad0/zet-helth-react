import React, { useState, useEffect } from 'react';
import {
  Container,
  Paper,
  TextField,
  Button,
  Typography,
  Box,
  Alert,
  InputAdornment,
  FormControl,
  InputLabel,
  Select,
  MenuItem,
} from '@mui/material';
import { Person, Email, Phone } from '@mui/icons-material';
import { useDispatch, useSelector } from 'react-redux';
import { useNavigate, useLocation } from 'react-router-dom';
import { registerUser } from '../../store/slices/authSlice';
import { clearToast } from '../../store/slices/appSlice';
import LoadingSpinner from '../../components/common/LoadingSpinner';
import { COLORS } from '../../utils/constants';

const RegisterDetailsScreen = () => {
  const dispatch = useDispatch();
  const navigate = useNavigate();
  const location = useLocation();

  const { loading, error, isAuthenticated } = useSelector((state) => state.auth);

  const [formData, setFormData] = useState({
    name: '',
    email: '',
    gender: '',
  });

  const [mobile, setMobile] = useState('');
  const [otp, setOtp] = useState('');
  const [errors, setErrors] = useState({});

  // Get mobile and otp from location state
  useEffect(() => {
    if (location.state?.mobile && location.state?.otp) {
      setMobile(location.state.mobile);
      setOtp(location.state.otp);
    } else {
      navigate('/register');
    }
  }, [location.state, navigate]);

  // Redirect if already authenticated
  useEffect(() => {
    if (isAuthenticated) {
      navigate('/home', { replace: true });
    }
  }, [isAuthenticated, navigate]);

  // Clear toast on component mount
  useEffect(() => {
    dispatch(clearToast());
  }, [dispatch]);

  const handleInputChange = (field) => (event) => {
    setFormData(prev => ({
      ...prev,
      [field]: event.target.value,
    }));

    // Clear error when user starts typing
    if (errors[field]) {
      setErrors(prev => ({
        ...prev,
        [field]: undefined,
      }));
    }
  };

  const validateForm = () => {
    const newErrors = {};

    // Name validation
    if (!formData.name.trim()) {
      newErrors.name = 'Name is required';
    } else if (formData.name.trim().length < 2) {
      newErrors.name = 'Name must be at least 2 characters';
    }

    // Email validation
    if (!formData.email.trim()) {
      newErrors.email = 'Email is required';
    } else if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(formData.email)) {
      newErrors.email = 'Please enter a valid email address';
    }

    // Gender validation
    if (!formData.gender) {
      newErrors.gender = 'Please select your gender';
    }

    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  const handleSubmit = async (event) => {
    event.preventDefault();

    if (!validateForm()) {
      return;
    }

    try {
      await dispatch(registerUser({
        user_name: formData.name,
        mobile_number: mobile,
        user_email: formData.email,
        user_gender: formData.gender,
        otp: otp,
        user_type: 'patient',
        device_id: 'web-app',
      })).unwrap();

      // Registration successful, redirect to login
      navigate('/login', {
        state: {
          message: 'Registration successful! Please login with your mobile number.'
        }
      });
    } catch (error) {
      // Error is handled by the reducer
      console.error('Registration failed:', error);
    }
  };

  return (
    <Container component="main" maxWidth="sm" sx={{ py: 8 }}>
      <Paper
        elevation={3}
        sx={{
          p: 4,
          display: 'flex',
          flexDirection: 'column',
          alignItems: 'center',
          borderRadius: 3,
        }}
      >
        {/* Logo/Brand */}
        <Box sx={{ mb: 3, textAlign: 'center' }}>
          <Typography
            component="h1"
            variant="h4"
            sx={{
              fontWeight: 700,
              color: COLORS.PRIMARY,
              mb: 1,
            }}
          >
            <img
              src={require('../../assets/images/logo.png')}
              alt="Zet Health Logo"
              style={{ height: 40, marginRight: 8, cursor: 'pointer' }}
              onClick={() => navigate('/home')}
            />
          </Typography>
          <Typography variant="body2" color="text.secondary">
            Complete your registration
          </Typography>
        </Box>

        {/* Registration Form */}
        <Box component="form" onSubmit={handleSubmit} sx={{ mt: 1, width: '100%' }}>
          <Typography component="h2" variant="h5" sx={{ mb: 3, textAlign: 'center' }}>
            Personal Details
          </Typography>

          {/* Mobile Display */}
          <Box sx={{ mb: 2, textAlign: 'center' }}>
            <Typography variant="body2" color="text.secondary">
              Register Number
            </Typography>
            <Typography variant="body1" sx={{ fontWeight: 600 }}>
              +91 {mobile}
            </Typography>
          </Box>

          {/* Error Alert */}
          {error && (
            <Alert severity="error" sx={{ mb: 2 }}>
              {error}
            </Alert>
          )}

          {/* Name Field */}
          <TextField
            margin="normal"
            required
            fullWidth
            id="name"
            label="Full Name"
            name="name"
            autoComplete="name"
            autoFocus
            value={formData.name}
            onChange={handleInputChange('name')}
            error={!!errors.name}
            helperText={errors.name}
            InputProps={{
              startAdornment: (
                <InputAdornment position="start">
                  <Person sx={{ color: 'action.active' }} />
                </InputAdornment>
              ),
            }}
            sx={{ mb: 2 }}
          />

          {/* Register Number Field */}
          <TextField
            margin="normal"
            required
            fullWidth
            id="registerNumber"
            label="Register Number"
            name="registerNumber"
            autoComplete="off"
            value={mobile}
            InputProps={{
              startAdornment: (
                <InputAdornment position="start">
                  <Phone sx={{ color: 'action.active' }} />
                </InputAdornment>
              ),
            }}
            sx={{ mb: 2 }}
            disabled
          />

          {/* Email Field */}
          <TextField
            margin="normal"
            required
            fullWidth
            id="email"
            label="Email ID"
            name="email"
            autoComplete="email"
            type="email"
            value={formData.email}
            onChange={handleInputChange('email')}
            error={!!errors.email}
            helperText={errors.email}
            InputProps={{
              startAdornment: (
                <InputAdornment position="start">
                  <Email sx={{ color: 'action.active' }} />
                </InputAdornment>
              ),
            }}
            sx={{ mb: 2 }}
          />

          {/* Gender Field */}
          <FormControl fullWidth margin="normal" error={!!errors.gender} sx={{ mb: 3 }}>
            <InputLabel id="gender-label">Sex</InputLabel>
            <Select
              labelId="gender-label"
              id="gender"
              value={formData.gender}
              label="Sex"
              onChange={handleInputChange('gender')}
            >
              <MenuItem value="male">Male</MenuItem>
              <MenuItem value="female">Female</MenuItem>
              <MenuItem value="other">Other</MenuItem>
            </Select>
            {errors.gender && (
              <Typography variant="body2" color="error" sx={{ mt: 1, ml: 2 }}>
                {errors.gender}
              </Typography>
            )}
          </FormControl>

          {/* Submit Button */}
          <Button
            type="submit"
            fullWidth
            variant="contained"
            disabled={loading}
            sx={{
              mt: 2,
              mb: 2,
              py: 1.5,
              fontSize: '1rem',
              fontWeight: 600,
            }}
          >
            {loading ? <LoadingSpinner size={20} message="" /> : 'Register'}
          </Button>

          {/* Back to Register */}
          <Box sx={{ textAlign: 'center', mt: 2 }}>
            <Button
              variant="text"
              onClick={() => navigate('/register')}
              sx={{
                color: COLORS.PRIMARY,
                textDecoration: 'none',
                fontWeight: 600,
                '&:hover': {
                  textDecoration: 'underline',
                  backgroundColor: 'transparent',
                },
              }}
            >
              Change Mobile Number
            </Button>
          </Box>
        </Box>
      </Paper>
    </Container>
  );
};

export default RegisterDetailsScreen;
