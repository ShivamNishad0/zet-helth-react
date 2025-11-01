import React, { useState, useEffect } from 'react';
import {
  Container,
  Paper,
  TextField,
  Button,
  Typography,
  Box,
  Link,
  Alert,
  InputAdornment,
} from '@mui/material';
import { Phone } from '@mui/icons-material';
import { useDispatch, useSelector } from 'react-redux';
import { useNavigate, Link as RouterLink } from 'react-router-dom';
import { sendOtp, setError } from '../../store/slices/authSlice';
import { clearToast } from '../../store/slices/appSlice';
import LoadingSpinner from '../../components/common/LoadingSpinner';
import { COLORS } from '../../utils/constants';

const LoginScreen = () => {
  const dispatch = useDispatch();
  const navigate = useNavigate();

  const { loading, error, isAuthenticated } = useSelector((state) => state.auth);

  const [formData, setFormData] = useState({
    mobile: '',
  });


  const [errors, setErrors] = useState({});

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

    // Mobile validation
    if (!formData.mobile.trim()) {
      newErrors.mobile = 'Mobile number is required';
    } else if (!/^[6-9]\d{9}$/.test(formData.mobile)) {
      newErrors.mobile = 'Please enter a valid 10-digit mobile number';
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
      // Dispatch sendOtp to send OTP
      await dispatch(sendOtp({
        mobile_number: formData.mobile,
        user_type: 'User',
      })).unwrap();

      // Navigate to OTP page after successful OTP send
      navigate('/otp', { state: { mobile: formData.mobile, isLogin: true } });
    } catch (error) {
      // Check if user needs to register first
      const errorMessage = error?.toLowerCase() || '';
      if (errorMessage.includes('not registered') ||
          errorMessage.includes('user not found') ||
          errorMessage.includes('signup') ||
          errorMessage.includes('register')) {
        // Show specific message for unregistered users
        dispatch(setError('Please signup first. This mobile number is not registered.'));
      } else {
        // Error is handled by the reducer for other cases
        console.error('Send OTP failed:', error);
      }
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
            Your trusted healthcare partner
          </Typography>
        </Box>

        {/* Login Form */}
        <Box component="form" onSubmit={handleSubmit} sx={{ mt: 1, width: '100%' }}>
          <Typography component="h2" variant="h5" sx={{ mb: 3, textAlign: 'center' }}>
            Sign In
          </Typography>

          {/* Error Alert */}
          {error && (
            <Alert severity="error" sx={{ mb: 2 }}>
              {error}
            </Alert>
          )}

          {/* Mobile Number Field */}
          <TextField
            margin="normal"
            required
            fullWidth
            id="mobile"
            label="Mobile Number"
            name="mobile"
            autoComplete="tel"
            autoFocus
            value={formData.mobile}
            onChange={handleInputChange('mobile')}
            error={!!errors.mobile}
            helperText={errors.mobile}
            InputProps={{
              startAdornment: (
                <InputAdornment position="start">
                  <Phone sx={{ color: 'action.active' }} />
                </InputAdornment>
              ),
            }}
            sx={{ mb: 2 }}
          />



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
            {loading ? <LoadingSpinner size={20} message="" /> : 'Sign In'}
          </Button>

          {/* Skip Login */}
          <Box sx={{ textAlign: 'center', mt: 1 }}>
            <Button
              type="button"
              variant="text"
              onClick={() => navigate('/home')}
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
              Skip for now
            </Button>
          </Box>

          {/* Register Link */}
          <Box sx={{ textAlign: 'center', mt: 2 }}>
            <Typography variant="body2" color="text.secondary">
              Don't have an account?{' '}
              <Link
                component={RouterLink}
                to="/register"
                sx={{
                  color: COLORS.PRIMARY,
                  textDecoration: 'none',
                  fontWeight: 600,
                  '&:hover': {
                    textDecoration: 'underline',
                  },
                }}
              >
                Sign Up
              </Link>
            </Typography>
          </Box>
        </Box>
      </Paper>
    </Container>
  );
};

export default LoginScreen;
