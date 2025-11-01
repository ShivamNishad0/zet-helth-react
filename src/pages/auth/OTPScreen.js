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
} from '@mui/material';
import { Lock } from '@mui/icons-material';
import { useDispatch, useSelector } from 'react-redux';
import { useNavigate, useLocation } from 'react-router-dom';
import { verifyOtp, sendOtp, sendOtpForRegistration } from '../../store/slices/authSlice';
import { clearToast } from '../../store/slices/appSlice';
import LoadingSpinner from '../../components/common/LoadingSpinner';
import { COLORS } from '../../utils/constants';

const OTPScreen = () => {
  const dispatch = useDispatch();
  const navigate = useNavigate();
  const location = useLocation();

  const { loading, error, isAuthenticated } = useSelector((state) => state.auth);

  const [otp, setOtp] = useState('');
  const [mobile, setMobile] = useState('');
  const [errors, setErrors] = useState({});
  const [resendTimer, setResendTimer] = useState(30);
  const [canResend, setCanResend] = useState(false);

  // Get mobile from location state
  useEffect(() => {
    if (location.state?.mobile) {
      setMobile(location.state.mobile);
    } else {
      navigate('/login');
    }
  }, [location.state, navigate]);

  // Redirect if already authenticated
  useEffect(() => {
    if (isAuthenticated) {
      const isLogin = location.state?.isLogin;
      if (isLogin) {
        navigate('/home', { replace: true });
      } else {
        // For registration, redirect to register-details after OTP verification
        navigate('/register-details', { state: { mobile: location.state?.mobile } });
      }
    }
  }, [isAuthenticated, navigate, location.state]);

  // Clear toast on component mount
  useEffect(() => {
    dispatch(clearToast());
  }, [dispatch]);

  // Resend timer
  useEffect(() => {
    if (resendTimer > 0) {
      const timer = setTimeout(() => setResendTimer(resendTimer - 1), 1000);
      return () => clearTimeout(timer);
    } else {
      setCanResend(true);
    }
  }, [resendTimer]);

  const handleOtpChange = (event) => {
    const value = event.target.value.replace(/\D/g, ''); // Only allow digits
    if (value.length <= 6) {
      setOtp(value);
      if (errors.otp) {
        setErrors(prev => ({ ...prev, otp: undefined }));
      }
    }
  };

  const validateForm = () => {
    const newErrors = {};

    if (!otp.trim()) {
      newErrors.otp = 'OTP is required';
    } else if (otp.length !== 6) {
      newErrors.otp = 'Please enter a valid 6-digit OTP';
    }

    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  const handleSubmit = async (event) => {
    event.preventDefault();

    if (!validateForm()) {
      return;
    }

    // Additional client-side validation: prevent API call if OTP is obviously invalid
    // (though backend doesn't validate, this prevents unnecessary calls)
    if (otp.length !== 6 || !/^\d{6}$/.test(otp)) {
      setErrors({ otp: 'Please enter a valid 6-digit OTP' });
      return;
    }

    try {
      const isLogin = location.state?.isLogin;
      if (isLogin) {
        // For login, use verifyOtp (login-user endpoint)
        await dispatch(verifyOtp({
          mobile_number: mobile,
          otp: otp,
          user_type: 'User',
        })).unwrap();
      } else {
        // For registration, redirect to register-details without verifying OTP here
        // The registration will be completed on the register-details screen
        navigate('/register-details', { state: { mobile: mobile, otp: otp } });
        return;
      }

      // Navigation will be handled by the useEffect that watches isAuthenticated
      console.log('OTP verified successfully, isLogin:', isLogin);
    } catch (error) {
      // Error is handled by the reducer
      console.error('OTP verification failed:', error);
    }
  };

  const handleResendOtp = async () => {
    try {
      const isLogin = location.state?.isLogin;
      if (isLogin) {
        await dispatch(sendOtp({
          mobile_number: mobile,
          user_type: 'User',
        })).unwrap();
      } else {
        await dispatch(sendOtpForRegistration({
          mobile_number: mobile,
          user_type: 'patient',
          device_id: 'web-app',
        })).unwrap();
      }

      setResendTimer(30);
      setCanResend(false);
    } catch (error) {
      console.error('Resend OTP failed:', error);
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
            Verify your mobile number
          </Typography>
        </Box>

        {/* OTP Form */}
        <Box component="form" onSubmit={handleSubmit} sx={{ mt: 1, width: '100%' }}>
          <Typography component="h2" variant="h5" sx={{ mb: 3, textAlign: 'center' }}>
            Enter OTP
          </Typography>

          {/* Mobile Display */}
          <Box sx={{ mb: 2, textAlign: 'center' }}>
            <Typography variant="body2" color="text.secondary">
              We sent a 6-digit code to
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

          {/* OTP Field */}
          <TextField
            margin="normal"
            required
            fullWidth
            id="otp"
            label="Enter 6-digit OTP"
            name="otp"
            autoComplete="one-time-code"
            autoFocus
            value={otp}
            onChange={handleOtpChange}
            error={!!errors.otp}
            helperText={errors.otp}
            inputProps={{ maxLength: 6 }}
            InputProps={{
              startAdornment: (
                <InputAdornment position="start">
                  <Lock sx={{ color: 'action.active' }} />
                </InputAdornment>
              ),
            }}
            sx={{ mb: 3 }}
          />

          {/* Submit Button */}
          <Button
            type="submit"
            fullWidth
            variant="contained"
            disabled={loading || otp.length !== 6}
            sx={{
              mt: 2,
              mb: 2,
              py: 1.5,
              fontSize: '1rem',
              fontWeight: 600,
            }}
          >
            {loading ? <LoadingSpinner size={20} message="" /> : 'Verify OTP'}
          </Button>

          {/* Resend OTP */}
          <Box sx={{ textAlign: 'center', mt: 2 }}>
            <Typography variant="body2" color="text.secondary">
              Didn't receive the code?{' '}
              {canResend ? (
                <Button
                  variant="text"
                  onClick={handleResendOtp}
                  disabled={loading}
                  sx={{
                    color: COLORS.PRIMARY,
                    textDecoration: 'none',
                    fontWeight: 600,
                    p: 0,
                    minWidth: 'auto',
                    '&:hover': {
                      textDecoration: 'underline',
                      backgroundColor: 'transparent',
                    },
                  }}
                >
                  Resend OTP
                </Button>
              ) : (
                <Typography
                  component="span"
                  variant="body2"
                  sx={{ color: COLORS.PRIMARY, fontWeight: 600 }}
                >
                  Resend in {resendTimer}s
                </Typography>
              )}
            </Typography>
          </Box>

          {/* Back to Login/Register */}
          <Box sx={{ textAlign: 'center', mt: 2 }}>
            <Button
              type="button"
              variant="text"
              onClick={() => navigate(location.state?.isLogin ? '/login' : '/register')}
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

export default OTPScreen;
