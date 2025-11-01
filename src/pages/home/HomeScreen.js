import React, { useEffect } from 'react';
import {
  Container,
  Box,
  Typography,
  Grid,
  Card,
  CardContent,
  CardMedia,
  Button,
  Chip,
  Avatar,
  Toolbar,
} from '@mui/material';
import {
  LocationOn,
  Phone,
  Email,
  PlayArrow,
  Star,
  MedicalServices,
  Receipt,
  Chat,
} from '@mui/icons-material';
import { useDispatch, useSelector } from 'react-redux';
import { useNavigate } from 'react-router-dom';
import { fetchHomeData, fetchHomeDataMock } from '../../store/slices/homeSlice';
import { fetchCart } from '../../store/slices/cartSlice';
import LoadingSpinner from '../../components/common/LoadingSpinner';
import Header from '../../components/common/Header';
import { COLORS, IMG_URL } from '../../utils/constants';
import { toast } from 'react-hot-toast';
import useCurrentAddress from '../../hooks/useCurrentAddress';

const HomeScreen = () => {
  const dispatch = useDispatch();
  const navigate = useNavigate();

  const { isAuthenticated } = useSelector((state) => state.auth);
  const { sliderList, popularPackages, lifestylePackages, popularTests, loading } = useSelector(
    (state) => state.home
  );
  const { currentAddress } = useCurrentAddress();

  useEffect(() => {
    // Try to fetch real data first, fallback to mock if fails
    const loadHomeData = async () => {
      try {
        await dispatch(
          fetchHomeData({
            token: localStorage.getItem('token') || undefined,
            device_id: 'web-device-id',
            platform: 'Web',
            app_version: '1.0.0',
          })
        ).unwrap();
      } catch (error) {
        console.warn('Failed to fetch real home data, using mock data:', error);
        dispatch(fetchHomeDataMock());
      }
    };

    loadHomeData();
    dispatch(fetchCart());
  }, [dispatch]);

  const protectedPaths = new Set([
    '/booking',
    '/report',
    '/prescriptions',
    '/chat',
    '/notifications',
    '/profile',
    '/settings',
    '/cart',
    '/address',
  ]);

  const handleProtectedNavigation = (path) => {
    if (!protectedPaths.has(path)) {
      navigate(path);
      return;
    }

    if (isAuthenticated) {
      navigate(path);
    } else {
      toast.error('Please login first');
    }
  };

  if (loading) {
    return <LoadingSpinner fullScreen />;
  }

  return (
    <Box sx={{ display: 'flex' }}>
      <Header />

      <Box component="main" sx={{ flexGrow: 1, p: 3 }}>
        <Toolbar />

        <Container maxWidth="lg">
          {/* Hero Banner Section */}
          <Box
            sx={{
              mb: 4,
              position: 'relative',
              borderRadius: 3,
              overflow: 'hidden',
              background: `linear-gradient(135deg, ${COLORS.PRIMARY} 0%, ${COLORS.SECONDARY} 100%)`,
              minHeight: { xs: 250, md: 350 },
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              color: 'white',
              textAlign: 'center',
              px: 3,
            }}
          >
            <Box
              sx={{
                position: 'absolute',
                top: 0,
                left: 0,
                right: 0,
                bottom: 0,
                backgroundImage: `url(${require('../../assets/images/home.png')})`,
                backgroundSize: 'cover',
                backgroundPosition: 'center',
                opacity: 0.3,
              }}
            />
            <Box sx={{ position: 'relative', zIndex: 1, maxWidth: 600 }}>
              <Typography
                variant="h3"
                fontWeight="bold"
                sx={{
                  mb: 2,
                  fontSize: { xs: '2rem', md: '3rem' },
                  textShadow: '2px 2px 4px rgba(0,0,0,0.3)',
                }}
              >
                Your Health, Our Priority
              </Typography>
              <Typography
                variant="h6"
                sx={{
                  mb: 3,
                  opacity: 0.9,
                  fontSize: { xs: '1rem', md: '1.25rem' },
                }}
              >
                Get accurate lab tests from trusted partners at your doorstep
              </Typography>
              <Button
                variant="contained"
                size="large"
                sx={{
                  bgcolor: 'white',
                  color: COLORS.PRIMARY,
                  px: 4,
                  py: 1.5,
                  borderRadius: 3,
                  fontWeight: 'bold',
                  '&:hover': {
                    bgcolor: 'rgba(255,255,255,0.9)',
                    transform: 'translateY(-2px)',
                    boxShadow: '0 8px 25px rgba(0,0,0,0.15)',
                  },
                  transition: 'all 0.3s ease',
                }}
                onClick={() => handleProtectedNavigation('/booking')}
              >
                Book Now <PlayArrow sx={{ ml: 1 }} />
              </Button>
            </Box>
          </Box>

          <Box sx={{ mb: 3, display: 'flex', alignItems: 'center', gap: 1 }}>
            <LocationOn sx={{ color: COLORS.PRIMARY }} />
            <Typography variant="body1" sx={{ cursor: 'pointer' }} onClick={() => handleProtectedNavigation('/address')}>
              {currentAddress}
            </Typography>
          </Box>

          {/* Quick Actions - Show before featured content */}
          <Box sx={{ mb: 4 }}>
            <Typography variant="h5" fontWeight="bold" sx={{ mb: 2 }}>
              Quick Actions
            </Typography>
            <Grid container spacing={2}>
              <Grid size={{ xs: 6, sm: 3 }}>
                <Card
                  sx={{
                    cursor: 'pointer',
                    textAlign: 'center',
                    p: 2,
                    transition: 'all 0.3s ease',
                    '&:hover': {
                      transform: 'translateY(-4px)',
                      boxShadow: '0 8px 25px rgba(0,0,0,0.15)',
                      bgcolor: COLORS.LIGHT,
                    },
                  }}
                  onClick={() => handleProtectedNavigation('/booking')}
                >
                  <MedicalServices sx={{ fontSize: 40, color: COLORS.PRIMARY, mb: 1 }} />
                  <Typography variant="body2" fontWeight="bold">Book Test</Typography>
                </Card>
              </Grid>
              <Grid size={{ xs: 6, sm: 3 }}>
                <Card
                  sx={{
                    cursor: 'pointer',
                    textAlign: 'center',
                    p: 2,
                    transition: 'all 0.3s ease',
                    '&:hover': {
                      transform: 'translateY(-4px)',
                      boxShadow: '0 8px 25px rgba(0,0,0,0.15)',
                      bgcolor: COLORS.LIGHT,
                    },
                  }}
                  onClick={() => handleProtectedNavigation('/prescriptions')}
                >
                  <Receipt sx={{ fontSize: 40, color: COLORS.PRIMARY, mb: 1 }} />
                  <Typography variant="body2" fontWeight="bold">Upload Rx</Typography>
                </Card>
              </Grid>
              <Grid size={{ xs: 6, sm: 3 }}>
                <Card
                  sx={{
                    cursor: 'pointer',
                    textAlign: 'center',
                    p: 2,
                    transition: 'all 0.3s ease',
                    '&:hover': {
                      transform: 'translateY(-4px)',
                      boxShadow: '0 8px 25px rgba(0,0,0,0.15)',
                      bgcolor: COLORS.LIGHT,
                    },
                  }}
                  onClick={() => {
                    console.log('View Reports clicked, isAuthenticated:', isAuthenticated);
                    handleProtectedNavigation('/report');
                  }}
                >
                  <Receipt sx={{ fontSize: 40, color: COLORS.PRIMARY, mb: 1 }} />
                  <Typography variant="body2" fontWeight="bold">View Reports</Typography>
                </Card>
              </Grid>
              <Grid size={{ xs: 6, sm: 3 }}>
                <Card
                  sx={{
                    cursor: 'pointer',
                    textAlign: 'center',
                    p: 2,
                    transition: 'all 0.3s ease',
                    '&:hover': {
                      transform: 'translateY(-4px)',
                      boxShadow: '0 8px 25px rgba(0,0,0,0.15)',
                      bgcolor: COLORS.LIGHT,
                    },
                  }}
                  onClick={() => handleProtectedNavigation('/chat')}
                >
                  <Chat sx={{ fontSize: 40, color: COLORS.PRIMARY, mb: 1 }} />
                  <Typography variant="body2" fontWeight="bold">Chat Support</Typography>
                </Card>
              </Grid>
            </Grid>
          </Box>

          {sliderList.length > 0 && (
            <Box sx={{ mb: 4 }}>
              <Typography variant="h5" fontWeight="bold" sx={{ mb: 2 }}>
                Featured
              </Typography>
              <Box sx={{ display: 'flex', gap: 2, overflowX: 'auto', pb: 2 }}>
                {sliderList.map((slider) => (
                  <Card
                    key={slider.id}
                    sx={{
                      minWidth: 300,
                      flexShrink: 0,
                      cursor: 'pointer',
                      transition: 'all 0.3s ease',
                      '&:hover': {
                        transform: 'translateY(-4px)',
                        boxShadow: '0 8px 25px rgba(0,0,0,0.15)',
                      },
                    }}
                  >
                    <CardMedia
                      component="img"
                      height="140"
                      image={IMG_URL + slider.image}
                      alt={slider.title}
                      sx={{ objectFit: 'cover' }}
                    />
                    <CardContent>
                      <Typography variant="h6" fontWeight="bold">{slider.title}</Typography>
                      <Typography variant="body2" color="text.secondary">
                        {slider.description}
                      </Typography>
                    </CardContent>
                  </Card>
                ))}
              </Box>
            </Box>
          )}

          {popularPackages.length > 0 && (
            <Box sx={{ mb: 4 }}>
              <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 2 }}>
                <Typography variant="h5" fontWeight="bold">
                  Popular Packages
                </Typography>
                <Button
                  variant="text"
                  color="primary"
                  onClick={() => handleProtectedNavigation('/booking')}
                  sx={{ cursor: 'pointer' }}
                >
                  View All
                </Button>
              </Box>

              <Grid container spacing={2}>
                {popularPackages.slice(0, 6).map((pkg) => (
                  <Grid key={pkg.id} size={{ xs: 12, sm: 6, md: 4 }}>
                    <Card sx={{ cursor: 'pointer' }} onClick={() => handleProtectedNavigation('/booking')}>
                      <CardContent>
                        <Typography variant="h6" fontWeight="bold">
                          {pkg.packageName}
                        </Typography>
                        <Typography variant="body2" color="text.secondary" sx={{ mb: 1 }}>
                          {pkg.packageDescription}
                        </Typography>
                        <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                          <Typography variant="h6" color={COLORS.PRIMARY} fontWeight="bold">
                            ₹{pkg.packageDiscountPrice || pkg.packagePrice}
                          </Typography>
                          {pkg.packageDiscountPrice && <Chip label="Discount" color="success" size="small" />}
                        </Box>
                      </CardContent>
                    </Card>
                  </Grid>
                ))}
              </Grid>
            </Box>
          )}

          {lifestylePackages.length > 0 && (
            <Box sx={{ mb: 4 }}>
              <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 2 }}>
                <Typography variant="h5" fontWeight="bold">
                  Lifestyle Packages
                </Typography>
                <Button
                  variant="text"
                  color="primary"
                  onClick={() => handleProtectedNavigation('/booking')}
                  sx={{ cursor: 'pointer' }}
                >
                  View All
                </Button>
              </Box>

              <Grid container spacing={2}>
                {lifestylePackages.slice(0, 6).map((pkg) => (
                  <Grid key={pkg.id} size={{ xs: 12, sm: 6, md: 4 }}>
                    <Card sx={{ cursor: 'pointer' }} onClick={() => handleProtectedNavigation('/booking')}>
                      <CardContent>
                        <Typography variant="h6" fontWeight="bold">
                          {pkg.packageName}
                        </Typography>
                        <Typography variant="body2" color="text.secondary" sx={{ mb: 1 }}>
                          {pkg.packageDescription}
                        </Typography>
                        <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                          <Typography variant="h6" color={COLORS.PRIMARY} fontWeight="bold">
                            ₹{pkg.packageDiscountPrice || pkg.packagePrice}
                          </Typography>
                          <Chip label="Lifestyle" color="secondary" size="small" />
                        </Box>
                      </CardContent>
                    </Card>
                  </Grid>
                ))}
              </Grid>
            </Box>
          )}

          {popularTests.length > 0 && (
            <Box sx={{ mb: 4 }}>
              <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 2 }}>
                <Typography variant="h5" fontWeight="bold">
                  Popular Lab Tests
                </Typography>
                <Button
                  variant="text"
                  color="primary"
                  onClick={() => handleProtectedNavigation('/booking')}
                  sx={{ cursor: 'pointer' }}
                >
                  View All
                </Button>
              </Box>

              <Grid container spacing={2}>
                {popularTests.slice(0, 6).map((test) => (
                  <Grid key={test.id} size={{ xs: 12, sm: 6, md: 4 }}>
                    <Card sx={{ cursor: 'pointer' }} onClick={() => handleProtectedNavigation('/booking')}>
                      <CardContent>
                        <Typography variant="h6" fontWeight="bold">
                          {test.testName}
                        </Typography>
                        <Typography variant="body2" color="text.secondary" sx={{ mb: 1 }}>
                          {test.testDescription}
                        </Typography>
                        <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                          <Typography variant="h6" color={COLORS.PRIMARY} fontWeight="bold">
                            ₹{test.testDiscountPrice || test.testPrice}
                          </Typography>
                          {test.isPopular && <Chip label="Popular" color="primary" size="small" />}
                        </Box>
                      </CardContent>
                    </Card>
                  </Grid>
                ))}
              </Grid>
            </Box>
          )}

          {/* Features Section */}
          <Box sx={{ mb: 4 }}>
            <Typography variant="h5" fontWeight="bold" sx={{ mb: 3, textAlign: 'center' }}>
              Why Choose Zet Health?
            </Typography>
            <Grid container spacing={3}>
              <Grid size={{ xs: 12, sm: 6, md: 3 }}>
                <Card
                  sx={{
                    textAlign: 'center',
                    p: 3,
                    height: '100%',
                    transition: 'all 0.3s ease',
                    '&:hover': {
                      transform: 'translateY(-4px)',
                      boxShadow: '0 8px 25px rgba(0,0,0,0.15)',
                    },
                  }}
                >
                  <Box
                    component="img"
                    src={require('../../assets/images/trusted.png')}
                    alt="Trusted"
                    sx={{
                      width: 80,
                      height: 80,
                      mb: 2,
                      mx: 'auto',
                      display: 'block',
                    }}
                  />
                  <Typography variant="h6" fontWeight="bold" sx={{ mb: 1 }}>
                    Trusted Labs
                  </Typography>
                  <Typography variant="body2" color="text.secondary">
                    Certified and accredited laboratories
                  </Typography>
                </Card>
              </Grid>
              <Grid size={{ xs: 12, sm: 6, md: 3 }}>
                <Card
                  sx={{
                    textAlign: 'center',
                    p: 3,
                    height: '100%',
                    transition: 'all 0.3s ease',
                    '&:hover': {
                      transform: 'translateY(-4px)',
                      boxShadow: '0 8px 25px rgba(0,0,0,0.15)',
                    },
                  }}
                >
                  <Box
                    component="img"
                    src={require('../../assets/images/speed.png')}
                    alt="Fast Results"
                    sx={{
                      width: 80,
                      height: 80,
                      mb: 2,
                      mx: 'auto',
                      display: 'block',
                    }}
                  />
                  <Typography variant="h6" fontWeight="bold" sx={{ mb: 1 }}>
                    Fast Results
                  </Typography>
                  <Typography variant="body2" color="text.secondary">
                    Quick turnaround time for reports
                  </Typography>
                </Card>
              </Grid>
              <Grid size={{ xs: 12, sm: 6, md: 3 }}>
                <Card
                  sx={{
                    textAlign: 'center',
                    p: 3,
                    height: '100%',
                    transition: 'all 0.3s ease',
                    '&:hover': {
                      transform: 'translateY(-4px)',
                      boxShadow: '0 8px 25px rgba(0,0,0,0.15)',
                    },
                  }}
                >
                  <Box
                    component="img"
                    src={require('../../assets/images/coverage.png')}
                    alt="Wide Coverage"
                    sx={{
                      width: 80,
                      height: 80,
                      mb: 2,
                      mx: 'auto',
                      display: 'block',
                    }}
                  />
                  <Typography variant="h6" fontWeight="bold" sx={{ mb: 1 }}>
                    Wide Coverage
                  </Typography>
                  <Typography variant="body2" color="text.secondary">
                    Extensive network across cities
                  </Typography>
                </Card>
              </Grid>
              <Grid size={{ xs: 12, sm: 6, md: 3 }}>
                <Card
                  sx={{
                    textAlign: 'center',
                    p: 3,
                    height: '100%',
                    transition: 'all 0.3s ease',
                    '&:hover': {
                      transform: 'translateY(-4px)',
                      boxShadow: '0 8px 25px rgba(0,0,0,0.15)',
                    },
                  }}
                >
                  <Box
                    component="img"
                    src={require('../../assets/images/sameday.png')}
                    alt="Same Day Service"
                    sx={{
                      width: 80,
                      height: 80,
                      mb: 2,
                      mx: 'auto',
                      display: 'block',
                    }}
                  />
                  <Typography variant="h6" fontWeight="bold" sx={{ mb: 1 }}>
                    Same Day Service
                  </Typography>
                  <Typography variant="body2" color="text.secondary">
                    Home collection within hours
                  </Typography>
                </Card>
              </Grid>
            </Grid>
          </Box>

          {/* Testimonials Section */}
          <Box sx={{ mb: 4 }}>
            <Typography variant="h5" fontWeight="bold" sx={{ mb: 3, textAlign: 'center' }}>
              What Our Customers Say
            </Typography>
            <Grid container spacing={3}>
              <Grid size={{ xs: 12, md: 4 }}>
                <Card
                  sx={{
                    p: 3,
                    height: '100%',
                    textAlign: 'center',
                    transition: 'all 0.3s ease',
                    '&:hover': {
                      transform: 'translateY(-4px)',
                      boxShadow: '0 8px 25px rgba(0,0,0,0.15)',
                    },
                  }}
                >
                  <Avatar
                    sx={{
                      width: 80,
                      height: 80,
                      mx: 'auto',
                      mb: 2,
                      bgcolor: COLORS.PRIMARY,
                      fontSize: '2rem',
                    }}
                  >
                    R
                  </Avatar>
                  <Box sx={{ display: 'flex', justifyContent: 'center', mb: 2 }}>
                    {[...Array(5)].map((_, i) => (
                      <Star key={i} sx={{ color: '#FFD700' }} />
                    ))}
                  </Box>
                  <Typography variant="body1" sx={{ mb: 2, fontStyle: 'italic' }}>
                    "Excellent service! The home collection was prompt and the reports were delivered quickly. Highly recommended."
                  </Typography>
                  <Typography variant="subtitle2" fontWeight="bold">
                    Rajesh Kumar
                  </Typography>
                  <Typography variant="body2" color="text.secondary">
                    Mumbai
                  </Typography>
                </Card>
              </Grid>
              <Grid size={{ xs: 12, md: 4 }}>
                <Card
                  sx={{
                    p: 3,
                    height: '100%',
                    textAlign: 'center',
                    transition: 'all 0.3s ease',
                    '&:hover': {
                      transform: 'translateY(-4px)',
                      boxShadow: '0 8px 25px rgba(0,0,0,0.15)',
                    },
                  }}
                >
                  <Avatar
                    sx={{
                      width: 80,
                      height: 80,
                      mx: 'auto',
                      mb: 2,
                      bgcolor: COLORS.PRIMARY,
                      fontSize: '2rem',
                    }}
                  >
                    P
                  </Avatar>
                  <Box sx={{ display: 'flex', justifyContent: 'center', mb: 2 }}>
                    {[...Array(5)].map((_, i) => (
                      <Star key={i} sx={{ color: '#FFD700' }} />
                    ))}
                  </Box>
                  <Typography variant="body1" sx={{ mb: 2, fontStyle: 'italic' }}>
                    "Very professional staff and accurate results. The app is user-friendly and makes booking tests so easy."
                  </Typography>
                  <Typography variant="subtitle2" fontWeight="bold">
                    Priya Sharma
                  </Typography>
                  <Typography variant="body2" color="text.secondary">
                    Delhi
                  </Typography>
                </Card>
              </Grid>
              <Grid size={{ xs: 12, md: 4 }}>
                <Card
                  sx={{
                    p: 3,
                    height: '100%',
                    textAlign: 'center',
                    transition: 'all 0.3s ease',
                    '&:hover': {
                      transform: 'translateY(-4px)',
                      boxShadow: '0 8px 25px rgba(0,0,0,0.15)',
                    },
                  }}
                >
                  <Avatar
                    sx={{
                      width: 80,
                      height: 80,
                      mx: 'auto',
                      mb: 2,
                      bgcolor: COLORS.PRIMARY,
                      fontSize: '2rem',
                    }}
                  >
                    A
                  </Avatar>
                  <Box sx={{ display: 'flex', justifyContent: 'center', mb: 2 }}>
                    {[...Array(5)].map((_, i) => (
                      <Star key={i} sx={{ color: '#FFD700' }} />
                    ))}
                  </Box>
                  <Typography variant="body1" sx={{ mb: 2, fontStyle: 'italic' }}>
                    "Great experience with Zet Health. The customer support is excellent and the pricing is very reasonable."
                  </Typography>
                  <Typography variant="subtitle2" fontWeight="bold">
                    Amit Patel
                  </Typography>
                  <Typography variant="body2" color="text.secondary">
                    Ahmedabad
                  </Typography>
                </Card>
              </Grid>
            </Grid>
          </Box>

          <Box sx={{ textAlign: 'center', py: 4, bgcolor: 'grey.50', borderRadius: 2 }}>
            <Typography variant="h6" fontWeight="bold" sx={{ mb: 2 }}>
              Need Help?
            </Typography>
            <Box sx={{ display: 'flex', justifyContent: 'center', gap: 4, flexWrap: 'wrap' }}>
              <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
                <Phone sx={{ color: COLORS.PRIMARY }} />
                <Typography variant="body2">
                  Call: {localStorage.getItem('support_mobile') || '+91-XXXXXXXXXX'}
                </Typography>
              </Box>
              <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
                <Email sx={{ color: COLORS.PRIMARY }} />
                <Typography variant="body2">
                  Email: {localStorage.getItem('support_email') || 'support@zethealth.com'}
                </Typography>
              </Box>
            </Box>
          </Box>
        </Container>
      </Box>
    </Box>
  );
};

export default HomeScreen;
