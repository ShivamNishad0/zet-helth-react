import React, { useEffect, useState, useCallback } from 'react';
import {
  Container,
  Box,
  Typography,
  Grid,
  Card,
  CardContent,
  Button,
  Chip,
  TextField,
  FormControl,
  InputLabel,
  Select,
  MenuItem,
  List,
  ListItem,

  ListItemText,
  ListItemSecondaryAction,
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  Stepper,
  Step,
  StepLabel,
  Paper,
  Divider,
  Alert,
  Avatar,
  LinearProgress,
  Fade,
  Slide,
  Zoom,
  CircularProgress,
  useTheme,
  useMediaQuery,
  Toolbar,
} from '@mui/material';
import {
  ShoppingCart,
  LocationOn,
  CalendarToday,
  AccessTime,
  Person,
  MedicalServices,
  CheckCircle,
  Cancel,
  Schedule,
  ArrowForward,
  ArrowBack,
  LocalHospital,
  Science,
  Payment,
  DoneAll,
  Receipt,
  Notifications,
} from '@mui/icons-material';
import { useDispatch, useSelector } from 'react-redux';
import { useNavigate } from 'react-router-dom';
import { DatePicker } from 'react-datepicker';
import 'react-datepicker/dist/react-datepicker.css';
import { fetchBookings, createBooking, getSlots } from '../../store/slices/bookingSlice';
import { fetchCart } from '../../store/slices/cartSlice';
import LoadingSpinner from '../../components/common/LoadingSpinner';
import Header from '../../components/common/Header';
import { COLORS } from '../../utils/constants';
import { apiService } from '../../services/api';
import { toast } from 'react-hot-toast';
import useCurrentAddress from '../../hooks/useCurrentAddress';



const steps = ['Select Tests/Packages', 'Choose Date & Time', 'Patient Details', 'Review & Book'];

const CustomStepIcon = ({ active, completed, icon }) => {
  return (
    <Box
      sx={{
        width: 40,
        height: 40,
        borderRadius: '50%',
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
        bgcolor: active ? COLORS.PRIMARY : completed ? 'success.main' : 'grey.300',
        color: active || completed ? 'white' : 'text.secondary',
        transition: 'all 0.3s ease',
      }}
    >
      {completed ? <DoneAll fontSize="small" /> : icon}
    </Box>
  );
};

const BookingScreen = () => {
  const dispatch = useDispatch();
  const navigate = useNavigate();
  const theme = useTheme();
  const isMobile = useMediaQuery(theme.breakpoints.down('md'));

  const { isAuthenticated } = useSelector((state) => state.auth); // eslint-disable-line no-unused-vars
  const { bookings, loading } = useSelector((state) => state.booking);
  const { items: cartItems, totalAmount, payableAmount } = useSelector((state) => state.cart);

  const [activeStep, setActiveStep] = useState(0);
  const [selectedDate, setSelectedDate] = useState(null);
  const [selectedTime, setSelectedTime] = useState('');
  const [availableSlots, setAvailableSlots] = useState([]);
  const [selectedPatient, setSelectedPatient] = useState('');
  const [patients, setPatients] = useState([]);
  const [labs, setLabs] = useState([]);
  const [selectedLab, setSelectedLab] = useState('');
  const [bookingDialog, setBookingDialog] = useState(false);
  const [currentBooking, setCurrentBooking] = useState(null);
  const { currentAddress } = useCurrentAddress();
  const [isLoadingSlots, setIsLoadingSlots] = useState(false);
  const [animationKey, setAnimationKey] = useState(0);

  useEffect(() => {
    // Fetch initial data
    dispatch(fetchBookings());
    dispatch(fetchCart());
    loadPatients();
    loadLabs();
  }, [dispatch]);

  const loadPatients = async () => {
    try {
      const response = await apiService.getPatientList();
      if (response && response.status && response.data && response.data.patientList) {
        setPatients(response.data.patientList);
      }
    } catch (error) {
      console.error('Error loading patients:', error);
    }
  };

  const loadLabs = async () => {
    try {
      const response = await apiService.getLabList();
      if (response && response.status && response.data && response.data.branchList) {
        setLabs(response.data.branchList);
      }
    } catch (error) {
      console.error('Error loading labs:', error);
    }
  };

  const handleNext = () => {
    setActiveStep((prevActiveStep) => prevActiveStep + 1);
    setAnimationKey(prev => prev + 1);
  };

  const handleBack = () => {
    setActiveStep((prevActiveStep) => prevActiveStep - 1);
    setAnimationKey(prev => prev + 1);
  };

  const handleDateChange = async (date) => {
    setSelectedDate(date);
    setSelectedTime('');
    setIsLoadingSlots(true);

    if (date && selectedLab) {
      try {
        const response = await dispatch(getSlots({
          lab_id: selectedLab,
          booking_date: date.toISOString().split('T')[0],
        })).unwrap();

        if (response.status && response.data.slots) {
          setAvailableSlots(response.data.slots);
        }
      } catch (error) {
        console.error('Error fetching slots:', error);
        toast.error('Failed to load available slots');
      } finally {
        setIsLoadingSlots(false);
      }
    } else {
      setIsLoadingSlots(false);
    }
  };



  const handleBookNow = useCallback(async () => {
    if (!selectedDate || !selectedTime || !selectedPatient || !selectedLab) {
      alert('Please fill all required fields');
      return;
    }

    const bookingData = {
      patient_id: selectedPatient,
      test_ids: cartItems.filter(item => item.type === 'test').map(item => item.itemId).join(','),
      package_ids: cartItems.filter(item => item.type === 'package').map(item => item.itemId).join(','),
      lab_id: selectedLab,
      booking_date: selectedDate.toISOString().split('T')[0],
      booking_time: selectedTime,
      address_id: localStorage.getItem('selected_address_id') || '',
    };

    try {
      const response = await dispatch(createBooking(bookingData)).unwrap();
      if (response.status) {
        setCurrentBooking(response.data.booking);
        setBookingDialog(true);
        // Clear cart after successful booking
        // dispatch(clearCart());
      }
    } catch (error) {
      console.error('Booking failed:', error);
      alert('Booking failed. Please try again.');
    }
  }, [selectedDate, selectedTime, selectedPatient, selectedLab, cartItems, dispatch]);

  const getStatusColor = (status) => {
    switch (status?.toLowerCase()) {
      case 'confirmed':
      case 'completed':
        return 'success';
      case 'pending':
        return 'warning';
      case 'cancelled':
        return 'error';
      default:
        return 'default';
    }
  };

  const getStatusIcon = (status) => {
    switch (status?.toLowerCase()) {
      case 'confirmed':
        return <CheckCircle color="success" />;
      case 'completed':
        return <CheckCircle color="success" />;
      case 'pending':
        return <Schedule color="warning" />;
      case 'cancelled':
        return <Cancel color="error" />;
      default:
        return null;
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
          <Box sx={{ mb: 3, display: 'flex', alignItems: 'center', gap: 1 }}>
            <LocationOn sx={{ color: COLORS.PRIMARY }} />
            <Typography variant="body1">
              {currentAddress}
            </Typography>
          </Box>

          <Typography variant="h4" fontWeight="bold" sx={{ mb: 4, textAlign: 'center' }}>
            Book Your Lab Tests
          </Typography>

      {/* Stepper */}
      <Paper sx={{ p: 3, mb: 4, background: `linear-gradient(135deg, ${COLORS.PRIMARY}15, ${COLORS.SECONDARY}15)` }}>
        <Stepper activeStep={activeStep} alternativeLabel={!isMobile} orientation={isMobile ? 'vertical' : 'horizontal'}>
          {steps.map((label, index) => (
            <Step key={label}>
              <StepLabel
                StepIconComponent={CustomStepIcon}
              >
                <Typography variant="body2" fontWeight={activeStep === index ? 'bold' : 'normal'}>
                  {label}
                </Typography>
              </StepLabel>
            </Step>
          ))}
        </Stepper>
        <LinearProgress
          variant="determinate"
          value={(activeStep + 1) * 25}
          sx={{
            mt: 2,
            height: 4,
            borderRadius: 2,
            bgcolor: 'grey.200',
            '& .MuiLinearProgress-bar': {
              bgcolor: COLORS.PRIMARY,
              borderRadius: 2,
            }
          }}
        />
      </Paper>

      {/* Step Content */}
      <Slide direction="right" in={activeStep === 0} mountOnEnter unmountOnExit key={`step-0-${animationKey}`}>
        <Paper sx={{ p: 3, minHeight: 400 }}>
          <Typography variant="h6" sx={{ mb: 3, display: 'flex', alignItems: 'center', gap: 1 }}>
            <Science sx={{ color: COLORS.PRIMARY }} />
            Step 1: Select Tests/Packages
          </Typography>

          {cartItems.length === 0 ? (
            <Fade in timeout={600}>
              <Box sx={{ textAlign: 'center', py: 6 }}>
                <Zoom in timeout={800}>
                  <ShoppingCart sx={{ fontSize: 80, color: 'grey.400', mb: 3 }} />
                </Zoom>
                <Typography variant="h6" color="text.secondary" sx={{ mb: 2 }}>
                  Your cart is empty
                </Typography>
                <Typography variant="body2" color="text.secondary" sx={{ mb: 4 }}>
                  Add tests or packages to continue booking
                </Typography>
                <Button
                  variant="contained"
                  size="large"
                  startIcon={<ArrowForward />}
                  onClick={() => navigate('/home')}
                  sx={{
                    px: 4,
                    py: 1.5,
                    borderRadius: 3,
                    textTransform: 'none',
                    fontSize: '1.1rem',
                    boxShadow: '0 4px 12px rgba(0,0,0,0.15)',
                    '&:hover': {
                      transform: 'translateY(-2px)',
                      boxShadow: '0 6px 20px rgba(0,0,0,0.2)',
                    },
                    transition: 'all 0.3s ease',
                  }}
                >
                  Browse Tests & Packages
                </Button>
              </Box>
            </Fade>
          ) : (
            <Fade in timeout={400}>
              <Box>
                <Typography variant="h6" sx={{ mb: 3, color: COLORS.PRIMARY }}>
                  Selected Items ({cartItems.length})
                </Typography>
                <List sx={{ mb: 3 }}>
                  {cartItems.map((item, index) => (
                    <Zoom in timeout={400 + index * 100} key={item.id}>
                      <ListItem
                        divider
                        sx={{
                          borderRadius: 2,
                          mb: 1,
                          bgcolor: 'grey.50',
                          '&:hover': { bgcolor: 'grey.100' },
                          transition: 'all 0.2s ease',
                        }}
                      >
                        <ListItemText
                          primary={
                            <Typography variant="subtitle1" fontWeight="medium">
                              {item.itemName}
                            </Typography>
                          }
                          secondary={
                            <Typography variant="body2" color="text.secondary">
                              ₹{item.itemDiscountPrice || item.itemPrice} × {item.quantity}
                            </Typography>
                          }
                        />
                        <ListItemSecondaryAction>
                          <Typography
                            variant="h6"
                            color={COLORS.PRIMARY}
                            sx={{
                              fontWeight: 'bold',
                              bgcolor: `${COLORS.PRIMARY}15`,
                              px: 2,
                              py: 1,
                              borderRadius: 2,
                            }}
                          >
                            ₹{(item.itemDiscountPrice || item.itemPrice) * item.quantity}
                          </Typography>
                        </ListItemSecondaryAction>
                      </ListItem>
                    </Zoom>
                  ))}
                </List>

                <Divider sx={{ my: 3 }} />

                <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', flexWrap: 'wrap', gap: 2 }}>
                  <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
                    <Payment sx={{ color: COLORS.PRIMARY }} />
                    <Box>
                      <Typography variant="h6" sx={{ color: COLORS.PRIMARY, fontWeight: 'bold' }}>
                        Total: ₹{payableAmount}
                      </Typography>
                      {totalAmount !== payableAmount && (
                        <Typography variant="body2" color="success.main">
                          Saved: ₹{totalAmount - payableAmount}
                        </Typography>
                      )}
                    </Box>
                  </Box>
                  <Button
                    variant="contained"
                    size="large"
                    endIcon={<ArrowForward />}
                    onClick={handleNext}
                    sx={{
                      px: 4,
                      py: 1.5,
                      borderRadius: 3,
                      textTransform: 'none',
                      fontSize: '1.1rem',
                      boxShadow: '0 4px 12px rgba(0,0,0,0.15)',
                      '&:hover': {
                        transform: 'translateY(-2px)',
                        boxShadow: '0 6px 20px rgba(0,0,0,0.2)',
                      },
                      transition: 'all 0.3s ease',
                    }}
                  >
                    Continue to Date & Time
                  </Button>
                </Box>
              </Box>
            </Fade>
          )}
        </Paper>
      </Slide>

      <Slide direction={activeStep > 0 ? "left" : "right"} in={activeStep === 1} mountOnEnter unmountOnExit key={`step-1-${animationKey}`}>
        <Paper sx={{ p: 3, minHeight: 400 }}>
          <Typography variant="h6" sx={{ mb: 3, display: 'flex', alignItems: 'center', gap: 1 }}>
            <CalendarToday sx={{ color: COLORS.PRIMARY }} />
            Step 2: Choose Date & Time
          </Typography>

          <Grid container spacing={4}>
            <Grid item xs={12} md={6}>
              <Card sx={{ p: 3, height: 'fit-content' }}>
                <Typography variant="h6" sx={{ mb: 3, display: 'flex', alignItems: 'center', gap: 1 }}>
                  <LocalHospital sx={{ color: COLORS.PRIMARY }} />
                  Select Lab Location
                </Typography>

                <FormControl fullWidth sx={{ mb: 2 }}>
                  <InputLabel>Select Lab</InputLabel>
                  <Select
                    value={selectedLab}
                    onChange={(e) => setSelectedLab(e.target.value)}
                    label="Select Lab"
                    sx={{
                      '& .MuiOutlinedInput-root': {
                        borderRadius: 2,
                      }
                    }}
                  >
                    {labs.map((lab) => (
                      <MenuItem key={lab.id} value={lab.id}>
                        <Box>
                          <Typography variant="subtitle2" fontWeight="medium">
                            {lab.branchName}
                          </Typography>
                          <Typography variant="body2" color="text.secondary">
                            {lab.branchAddress}
                          </Typography>
                        </Box>
                      </MenuItem>
                    ))}
                  </Select>
                </FormControl>

                <Box sx={{ mt: 3 }}>
                  <Typography variant="subtitle1" sx={{ mb: 2, display: 'flex', alignItems: 'center', gap: 1 }}>
                    <CalendarToday sx={{ color: COLORS.PRIMARY }} />
                    Select Date
                  </Typography>
                  <DatePicker
                    selected={selectedDate}
                    onChange={handleDateChange}
                    minDate={new Date()}
                    dateFormat="dd/MM/yyyy"
                    customInput={
                      <TextField
                        fullWidth
                        label="Booking Date"
                        InputProps={{
                          startAdornment: <CalendarToday sx={{ mr: 1, color: 'action.active' }} />,
                        }}
                        sx={{
                          '& .MuiOutlinedInput-root': {
                            borderRadius: 2,
                          }
                        }}
                      />
                    }
                  />
                </Box>
              </Card>
            </Grid>

            <Grid item xs={12} md={6}>
              <Card sx={{ p: 3, height: 'fit-content' }}>
                <Typography variant="subtitle1" sx={{ mb: 3, display: 'flex', alignItems: 'center', gap: 1 }}>
                  <AccessTime sx={{ color: COLORS.PRIMARY }} />
                  Available Time Slots
                </Typography>

                {isLoadingSlots ? (
                  <Box sx={{ display: 'flex', justifyContent: 'center', py: 4 }}>
                    <CircularProgress size={40} sx={{ color: COLORS.PRIMARY }} />
                    <Typography sx={{ ml: 2 }}>Loading slots...</Typography>
                  </Box>
                ) : availableSlots.length === 0 ? (
                  <Box sx={{ textAlign: 'center', py: 4 }}>
                    <AccessTime sx={{ fontSize: 48, color: 'grey.400', mb: 2 }} />
                    <Typography color="text.secondary">
                      {selectedLab && selectedDate ? 'No slots available for selected date' : 'Please select a lab and date to view available slots'}
                    </Typography>
                  </Box>
                ) : (
                  <Box>
                    <Typography variant="body2" color="text.secondary" sx={{ mb: 2 }}>
                      Available slots for {selectedDate?.toLocaleDateString()}
                    </Typography>
                    <Grid container spacing={1}>
                      {availableSlots.map((slot, index) => (
                        <Grid item xs={6} sm={4} key={slot.time}>
                          <Zoom in timeout={300 + index * 50}>
                            <Button
                              variant={selectedTime === slot.time ? 'contained' : 'outlined'}
                              fullWidth
                              onClick={() => setSelectedTime(slot.time)}
                              disabled={!slot.available}
                              sx={{
                                py: 1.5,
                                borderRadius: 2,
                                textTransform: 'none',
                                fontWeight: 'medium',
                                transition: 'all 0.2s ease',
                                '&:hover': {
                                  transform: 'translateY(-1px)',
                                  boxShadow: '0 4px 8px rgba(0,0,0,0.1)',
                                },
                                ...(selectedTime === slot.time && {
                                  bgcolor: COLORS.PRIMARY,
                                  '&:hover': {
                                    bgcolor: COLORS.PRIMARY,
                                  }
                                }),
                                ...(!slot.available && {
                                  opacity: 0.5,
                                  cursor: 'not-allowed',
                                })
                              }}
                            >
                              {slot.time}
                            </Button>
                          </Zoom>
                        </Grid>
                      ))}
                    </Grid>
                  </Box>
                )}
              </Card>
            </Grid>
          </Grid>

          <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mt: 4, flexWrap: 'wrap', gap: 2 }}>
            <Button
              startIcon={<ArrowBack />}
              onClick={handleBack}
              sx={{
                px: 3,
                py: 1.5,
                borderRadius: 2,
                textTransform: 'none',
              }}
            >
              Back to Tests
            </Button>
            <Button
              variant="contained"
              endIcon={<ArrowForward />}
              onClick={handleNext}
              disabled={!selectedDate || !selectedTime || !selectedLab}
              sx={{
                px: 4,
                py: 1.5,
                borderRadius: 3,
                textTransform: 'none',
                fontSize: '1.1rem',
                boxShadow: '0 4px 12px rgba(0,0,0,0.15)',
                '&:hover': {
                  transform: 'translateY(-2px)',
                  boxShadow: '0 6px 20px rgba(0,0,0,0.2)',
                },
                '&:disabled': {
                  opacity: 0.6,
                  transform: 'none',
                },
                transition: 'all 0.3s ease',
              }}
            >
              Continue to Patient Details
            </Button>
          </Box>
        </Paper>
      </Slide>

      <Slide direction={activeStep > 1 ? "left" : "right"} in={activeStep === 2} mountOnEnter unmountOnExit key={`step-2-${animationKey}`}>
        <Paper sx={{ p: 3, minHeight: 400 }}>
          <Typography variant="h6" sx={{ mb: 3, display: 'flex', alignItems: 'center', gap: 1 }}>
            <Person sx={{ color: COLORS.PRIMARY }} />
            Step 3: Patient Details
          </Typography>

          <Card sx={{ p: 4, textAlign: 'center', mb: 3 }}>
            <Avatar
              sx={{
                width: 80,
                height: 80,
                bgcolor: COLORS.PRIMARY,
                mx: 'auto',
                mb: 2,
                fontSize: '2rem'
              }}
            >
              <Person fontSize="large" />
            </Avatar>
            <Typography variant="h6" sx={{ mb: 1 }}>
              Select Patient for Booking
            </Typography>
            <Typography variant="body2" color="text.secondary">
              Choose who will be taking the tests
            </Typography>
          </Card>

          {patients.length === 0 ? (
            <Fade in timeout={600}>
              <Alert
                severity="info"
                sx={{
                  mb: 3,
                  p: 3,
                  borderRadius: 2,
                  '& .MuiAlert-icon': {
                    fontSize: '2rem',
                  }
                }}
                action={
                  <Button
                    color="inherit"
                    size="small"
                    onClick={() => toast('Add patient feature coming soon!')}
                  >
                    Add Patient
                  </Button>
                }
              >
                <Typography variant="subtitle1" sx={{ mb: 1 }}>
                  No patients found
                </Typography>
                <Typography variant="body2">
                  Please add a patient profile first to continue with booking.
                </Typography>
              </Alert>
            </Fade>
          ) : (
            <Box sx={{ mb: 3 }}>
              <Typography variant="subtitle1" sx={{ mb: 3, color: COLORS.PRIMARY }}>
                Available Patients ({patients.length})
              </Typography>
              <Grid container spacing={2}>
                {patients.map((patient, index) => (
                  <Grid item xs={12} sm={6} md={4} key={patient.id}>
                    <Zoom in timeout={400 + index * 100}>
                      <Card
                        sx={{
                          cursor: 'pointer',
                          border: selectedPatient === patient.id ? `2px solid ${COLORS.PRIMARY}` : '1px solid #e0e0e0',
                          bgcolor: selectedPatient === patient.id ? `${COLORS.PRIMARY}08` : 'white',
                          transition: 'all 0.3s ease',
                          '&:hover': {
                            transform: 'translateY(-4px)',
                            boxShadow: '0 8px 25px rgba(0,0,0,0.15)',
                            borderColor: COLORS.PRIMARY,
                          },
                        }}
                        onClick={() => setSelectedPatient(patient.id)}
                      >
                        <CardContent sx={{ textAlign: 'center', py: 3 }}>
                          <Avatar
                            sx={{
                              width: 60,
                              height: 60,
                              bgcolor: selectedPatient === patient.id ? COLORS.PRIMARY : 'grey.300',
                              mx: 'auto',
                              mb: 2,
                              color: selectedPatient === patient.id ? 'white' : 'text.primary',
                            }}
                          >
                            {patient.patientName?.charAt(0)?.toUpperCase() || 'P'}
                          </Avatar>
                          <Typography variant="h6" fontWeight="medium" sx={{ mb: 1 }}>
                            {patient.patientName}
                          </Typography>
                          <Typography variant="body2" color="text.secondary" sx={{ mb: 1 }}>
                            Age: {patient.patientAge} years
                          </Typography>
                          <Typography variant="body2" color="text.secondary">
                            Gender: {patient.patientGender}
                          </Typography>
                          {selectedPatient === patient.id && (
                            <Box sx={{ mt: 2 }}>
                              <Chip
                                label="Selected"
                                color="primary"
                                size="small"
                                icon={<CheckCircle />}
                              />
                            </Box>
                          )}
                        </CardContent>
                      </Card>
                    </Zoom>
                  </Grid>
                ))}
              </Grid>
            </Box>
          )}

          <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mt: 4, flexWrap: 'wrap', gap: 2 }}>
            <Button
              startIcon={<ArrowBack />}
              onClick={handleBack}
              sx={{
                px: 3,
                py: 1.5,
                borderRadius: 2,
                textTransform: 'none',
              }}
            >
              Back to Date & Time
            </Button>
            <Button
              variant="contained"
              endIcon={<ArrowForward />}
              onClick={handleNext}
              disabled={!selectedPatient}
              sx={{
                px: 4,
                py: 1.5,
                borderRadius: 3,
                textTransform: 'none',
                fontSize: '1.1rem',
                boxShadow: '0 4px 12px rgba(0,0,0,0.15)',
                '&:hover': {
                  transform: 'translateY(-2px)',
                  boxShadow: '0 6px 20px rgba(0,0,0,0.2)',
                },
                '&:disabled': {
                  opacity: 0.6,
                  transform: 'none',
                },
                transition: 'all 0.3s ease',
              }}
            >
              Review & Book
            </Button>
          </Box>
        </Paper>
      </Slide>

      <Slide direction={activeStep > 2 ? "left" : "right"} in={activeStep === 3} mountOnEnter unmountOnExit key={`step-3-${animationKey}`}>
        <Paper sx={{ p: 3, minHeight: 400 }}>
          <Typography variant="h6" sx={{ mb: 3, display: 'flex', alignItems: 'center', gap: 1 }}>
            <DoneAll sx={{ color: COLORS.PRIMARY }} />
            Step 4: Review & Book
          </Typography>

          <Grid container spacing={4}>
            <Grid item xs={12} lg={8}>
              <Typography variant="h6" sx={{ mb: 3, color: COLORS.PRIMARY, display: 'flex', alignItems: 'center', gap: 1 }}>
                <Receipt sx={{ color: COLORS.PRIMARY }} />
                Booking Summary
              </Typography>

              <Card sx={{ mb: 3, borderRadius: 3, boxShadow: '0 4px 20px rgba(0,0,0,0.08)' }}>
                <CardContent sx={{ p: 3 }}>
                  <Typography variant="h6" fontWeight="bold" sx={{ mb: 3, display: 'flex', alignItems: 'center', gap: 1 }}>
                    <Science sx={{ color: COLORS.PRIMARY }} />
                    Tests & Packages
                  </Typography>
                  <List sx={{ py: 0 }}>
                    {cartItems.map((item, index) => (
                      <Zoom in timeout={300 + index * 100} key={item.id}>
                        <ListItem
                          sx={{
                            borderRadius: 2,
                            mb: 1,
                            bgcolor: 'grey.50',
                            border: '1px solid #f0f0f0',
                          }}
                        >
                          <ListItemText
                            primary={
                              <Typography variant="subtitle1" fontWeight="medium">
                                {item.itemName}
                              </Typography>
                            }
                            secondary={
                              <Typography variant="body2" color="text.secondary">
                                Quantity: {item.quantity}
                              </Typography>
                            }
                          />
                          <Typography
                            variant="h6"
                            color={COLORS.PRIMARY}
                            sx={{
                              fontWeight: 'bold',
                              bgcolor: `${COLORS.PRIMARY}15`,
                              px: 2,
                              py: 1,
                              borderRadius: 2,
                            }}
                          >
                            ₹{(item.itemDiscountPrice || item.itemPrice) * item.quantity}
                          </Typography>
                        </ListItem>
                      </Zoom>
                    ))}
                  </List>
                </CardContent>
              </Card>

              <Card sx={{ borderRadius: 3, boxShadow: '0 4px 20px rgba(0,0,0,0.08)' }}>
                <CardContent sx={{ p: 3 }}>
                  <Typography variant="h6" fontWeight="bold" sx={{ mb: 3, display: 'flex', alignItems: 'center', gap: 1 }}>
                    <Schedule sx={{ color: COLORS.PRIMARY }} />
                    Booking Details
                  </Typography>
                  <Grid container spacing={3}>
                    <Grid item xs={12} sm={6}>
                      <Box sx={{ display: 'flex', alignItems: 'center', p: 2, bgcolor: 'grey.50', borderRadius: 2 }}>
                        <CalendarToday sx={{ mr: 2, color: COLORS.PRIMARY, fontSize: '2rem' }} />
                        <Box>
                          <Typography variant="body2" color="text.secondary">
                            Date
                          </Typography>
                          <Typography variant="subtitle1" fontWeight="medium">
                            {selectedDate?.toLocaleDateString('en-IN', {
                              weekday: 'long',
                              year: 'numeric',
                              month: 'long',
                              day: 'numeric'
                            })}
                          </Typography>
                        </Box>
                      </Box>
                    </Grid>
                    <Grid item xs={12} sm={6}>
                      <Box sx={{ display: 'flex', alignItems: 'center', p: 2, bgcolor: 'grey.50', borderRadius: 2 }}>
                        <AccessTime sx={{ mr: 2, color: COLORS.PRIMARY, fontSize: '2rem' }} />
                        <Box>
                          <Typography variant="body2" color="text.secondary">
                            Time
                          </Typography>
                          <Typography variant="subtitle1" fontWeight="medium">
                            {selectedTime}
                          </Typography>
                        </Box>
                      </Box>
                    </Grid>
                    <Grid item xs={12} sm={6}>
                      <Box sx={{ display: 'flex', alignItems: 'center', p: 2, bgcolor: 'grey.50', borderRadius: 2 }}>
                        <LocalHospital sx={{ mr: 2, color: COLORS.PRIMARY, fontSize: '2rem' }} />
                        <Box>
                          <Typography variant="body2" color="text.secondary">
                            Lab Location
                          </Typography>
                          <Typography variant="subtitle1" fontWeight="medium">
                            {labs.find(lab => lab.id === selectedLab)?.branchName}
                          </Typography>
                          <Typography variant="body2" color="text.secondary">
                            {labs.find(lab => lab.id === selectedLab)?.branchAddress}
                          </Typography>
                        </Box>
                      </Box>
                    </Grid>
                    <Grid item xs={12} sm={6}>
                      <Box sx={{ display: 'flex', alignItems: 'center', p: 2, bgcolor: 'grey.50', borderRadius: 2 }}>
                        <Person sx={{ mr: 2, color: COLORS.PRIMARY, fontSize: '2rem' }} />
                        <Box>
                          <Typography variant="body2" color="text.secondary">
                            Patient
                          </Typography>
                          <Typography variant="subtitle1" fontWeight="medium">
                            {patients.find(p => p.id === selectedPatient)?.patientName}
                          </Typography>
                          <Typography variant="body2" color="text.secondary">
                            {patients.find(p => p.id === selectedPatient)?.patientAge} years, {patients.find(p => p.id === selectedPatient)?.patientGender}
                          </Typography>
                        </Box>
                      </Box>
                    </Grid>
                  </Grid>
                </CardContent>
              </Card>
            </Grid>

            <Grid item xs={12} lg={4}>
              <Card sx={{ borderRadius: 3, boxShadow: '0 4px 20px rgba(0,0,0,0.08)', position: 'sticky', top: 20 }}>
                <CardContent sx={{ p: 3 }}>
                  <Typography variant="h6" sx={{ mb: 3, display: 'flex', alignItems: 'center', gap: 1 }}>
                    <Payment sx={{ color: COLORS.PRIMARY }} />
                    Payment Summary
                  </Typography>

                  <Box sx={{ display: 'flex', justifyContent: 'space-between', mb: 2 }}>
                    <Typography variant="body1">Subtotal:</Typography>
                    <Typography variant="body1">₹{totalAmount}</Typography>
                  </Box>

                  {totalAmount !== payableAmount && (
                    <Box sx={{ display: 'flex', justifyContent: 'space-between', mb: 2 }}>
                      <Typography variant="body1">Discount:</Typography>
                      <Typography variant="body1" color="success.main" fontWeight="medium">
                        -₹{totalAmount - payableAmount}
                      </Typography>
                    </Box>
                  )}

                  <Divider sx={{ my: 2 }} />

                  <Box sx={{ display: 'flex', justifyContent: 'space-between', mb: 3, alignItems: 'center' }}>
                    <Typography variant="h6" fontWeight="bold">
                      Total Amount:
                    </Typography>
                    <Typography
                      variant="h5"
                      fontWeight="bold"
                      color={COLORS.PRIMARY}
                      sx={{
                        bgcolor: `${COLORS.PRIMARY}15`,
                        px: 2,
                        py: 1,
                        borderRadius: 2,
                      }}
                    >
                      ₹{payableAmount}
                    </Typography>
                  </Box>

                  <Button
                    variant="contained"
                    fullWidth
                    size="large"
                    onClick={handleBookNow}
                    disabled={loading}
                    sx={{
                      py: 1.5,
                      borderRadius: 3,
                      textTransform: 'none',
                      fontSize: '1.1rem',
                      fontWeight: 'bold',
                      boxShadow: '0 4px 12px rgba(0,0,0,0.15)',
                      '&:hover': {
                        transform: 'translateY(-2px)',
                        boxShadow: '0 6px 20px rgba(0,0,0,0.2)',
                      },
                      '&:disabled': {
                        opacity: 0.6,
                        transform: 'none',
                      },
                      transition: 'all 0.3s ease',
                    }}
                    startIcon={loading ? <CircularProgress size={20} color="inherit" /> : <CheckCircle />}
                  >
                    {loading ? 'Processing...' : 'Confirm Booking'}
                  </Button>

                  <Typography variant="body2" color="text.secondary" sx={{ mt: 2, textAlign: 'center' }}>
                    By booking, you agree to our terms & conditions
                  </Typography>
                </CardContent>
              </Card>
            </Grid>
          </Grid>

          <Box sx={{ display: 'flex', justifyContent: 'flex-start', mt: 4 }}>
            <Button
              startIcon={<ArrowBack />}
              onClick={handleBack}
              sx={{
                px: 3,
                py: 1.5,
                borderRadius: 2,
                textTransform: 'none',
              }}
            >
              Back to Patient Details
            </Button>
          </Box>
        </Paper>
      </Slide>

      {/* My Bookings Section */}
      <Fade in timeout={800}>
        <Paper sx={{ p: 4, mt: 4, borderRadius: 3, boxShadow: '0 4px 20px rgba(0,0,0,0.08)' }}>
          <Typography variant="h6" sx={{ mb: 4, display: 'flex', alignItems: 'center', gap: 1 }}>
            <Receipt sx={{ color: COLORS.PRIMARY }} />
            My Bookings
          </Typography>

          {bookings.length === 0 ? (
            <Box sx={{ textAlign: 'center', py: 6 }}>
              <Zoom in timeout={600}>
                <MedicalServices sx={{ fontSize: 80, color: 'grey.400', mb: 3 }} />
              </Zoom>
              <Typography variant="h6" color="text.secondary" sx={{ mb: 2 }}>
                No bookings found
              </Typography>
              <Typography variant="body2" color="text.secondary" sx={{ mb: 4 }}>
                Your lab test bookings will appear here
              </Typography>
              <Button
                variant="outlined"
                startIcon={<ArrowForward />}
                onClick={() => navigate('/home')}
                sx={{
                  px: 3,
                  py: 1.5,
                  borderRadius: 2,
                  textTransform: 'none',
                }}
              >
                Book Your First Test
              </Button>
            </Box>
          ) : (
            <Grid container spacing={3}>
              {bookings.map((booking, index) => (
                <Grid item xs={12} md={6} key={booking.id}>
                  <Zoom in timeout={400 + index * 100}>
                    <Card
                      sx={{
                        borderRadius: 3,
                        boxShadow: '0 4px 20px rgba(0,0,0,0.08)',
                        transition: 'all 0.3s ease',
                        '&:hover': {
                          transform: 'translateY(-4px)',
                          boxShadow: '0 8px 30px rgba(0,0,0,0.12)',
                        },
                        cursor: 'pointer',
                      }}
                      onClick={() => navigate(`/booking/${booking.id}`)}
                    >
                      <CardContent sx={{ p: 3 }}>
                        <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', mb: 3 }}>
                          <Box>
                            <Typography variant="h6" fontWeight="bold" sx={{ mb: 1 }}>
                              Booking #{booking.bookingId}
                            </Typography>
                            <Typography variant="body2" color="text.secondary">
                              {new Date(booking.bookingDate).toLocaleDateString('en-IN', {
                                weekday: 'short',
                                year: 'numeric',
                                month: 'short',
                                day: 'numeric'
                              })} at {booking.bookingTime}
                            </Typography>
                          </Box>
                          <Chip
                            label={booking.bookingStatus}
                            color={getStatusColor(booking.bookingStatus)}
                            size="small"
                            icon={getStatusIcon(booking.bookingStatus)}
                            sx={{
                              fontWeight: 'medium',
                              textTransform: 'capitalize',
                            }}
                          />
                        </Box>

                        <Box sx={{ display: 'flex', alignItems: 'center', mb: 2 }}>
                          <Payment sx={{ mr: 1, color: COLORS.PRIMARY }} />
                          <Typography variant="h6" color={COLORS.PRIMARY} fontWeight="bold">
                            ₹{booking.payableAmount}
                          </Typography>
                        </Box>

                        <Box sx={{ display: 'flex', gap: 1, flexWrap: 'wrap' }}>
                          <Button
                            size="small"
                            variant="outlined"
                            onClick={(e) => {
                              e.stopPropagation();
                              navigate(`/booking/${booking.id}`);
                            }}
                            sx={{
                              borderRadius: 2,
                              textTransform: 'none',
                              fontWeight: 'medium',
                            }}
                          >
                            View Details
                          </Button>
                          {booking.bookingStatus === 'pending' && (
                            <Button
                              size="small"
                              color="error"
                              variant="outlined"
                              onClick={(e) => {
                                e.stopPropagation();
                                // Handle cancel booking
                                toast('Cancel booking feature coming soon!');
                              }}
                              sx={{
                                borderRadius: 2,
                                textTransform: 'none',
                                fontWeight: 'medium',
                              }}
                            >
                              Cancel
                            </Button>
                          )}
                        </Box>
                      </CardContent>
                    </Card>
                  </Zoom>
                </Grid>
              ))}
            </Grid>
          )}
        </Paper>
      </Fade>

          {/* Booking Success Dialog */}
          <Dialog
            open={bookingDialog}
            onClose={() => setBookingDialog(false)}
            maxWidth="sm"
            fullWidth
            keepMounted={false}
            PaperProps={{
              sx: {
                borderRadius: 3,
                boxShadow: '0 8px 32px rgba(0,0,0,0.2)',
              }
            }}
          >
            <DialogTitle sx={{ textAlign: 'center', pb: 1 }}>
              <Zoom in timeout={600}>
                <CheckCircle sx={{ fontSize: 64, color: 'success.main', mb: 2 }} />
              </Zoom>
              <Typography variant="h4" fontWeight="bold" color="success.main">
                Booking Confirmed!
              </Typography>
            </DialogTitle>
            <DialogContent sx={{ px: 4, pb: 2 }}>
              {currentBooking && (
                <Fade in timeout={800}>
                  <Box sx={{ textAlign: 'center' }}>
                    <Box sx={{ bgcolor: 'success.light', borderRadius: 2, p: 2, mb: 3 }}>
                      <Typography variant="h6" sx={{ mb: 1, color: 'success.dark' }}>
                        Booking ID: #{currentBooking.bookingId}
                      </Typography>
                    </Box>

                    <Grid container spacing={2} sx={{ mb: 3 }}>
                      <Grid item xs={6}>
                        <Box sx={{ display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 1 }}>
                          <CalendarToday sx={{ color: COLORS.PRIMARY }} />
                          <Box>
                            <Typography variant="body2" color="text.secondary">
                              Date
                            </Typography>
                            <Typography variant="body1" fontWeight="medium">
                              {new Date(currentBooking.bookingDate).toLocaleDateString('en-IN')}
                            </Typography>
                          </Box>
                        </Box>
                      </Grid>
                      <Grid item xs={6}>
                        <Box sx={{ display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 1 }}>
                          <AccessTime sx={{ color: COLORS.PRIMARY }} />
                          <Box>
                            <Typography variant="body2" color="text.secondary">
                              Time
                            </Typography>
                            <Typography variant="body1" fontWeight="medium">
                              {currentBooking.bookingTime}
                            </Typography>
                          </Box>
                        </Box>
                      </Grid>
                    </Grid>

                    <Box sx={{ display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 1, mb: 3 }}>
                      <Payment sx={{ color: COLORS.PRIMARY, fontSize: '1.5rem' }} />
                      <Typography variant="h5" color={COLORS.PRIMARY} fontWeight="bold">
                        Total: ₹{currentBooking.payableAmount}
                      </Typography>
                    </Box>

                    <Alert
                      severity="info"
                      sx={{
                        borderRadius: 2,
                        '& .MuiAlert-icon': {
                          fontSize: '1.5rem',
                        }
                      }}
                      icon={<Notifications />}
                    >
                      <Typography variant="body2">
                        You will receive a confirmation SMS and email shortly with all booking details.
                      </Typography>
                    </Alert>
                  </Box>
                </Fade>
              )}
            </DialogContent>
            <DialogActions sx={{ justifyContent: 'center', pb: 3, px: 4, gap: 2 }}>
              <Button
                onClick={() => setBookingDialog(false)}
                variant="outlined"
                sx={{
                  px: 3,
                  py: 1.5,
                  borderRadius: 2,
                  textTransform: 'none',
                  fontWeight: 'medium',
                }}
              >
                Close
              </Button>
              <Button
                variant="contained"
                onClick={() => {
                  setBookingDialog(false);
                  navigate('/report');
                }}
                sx={{
                  px: 4,
                  py: 1.5,
                  borderRadius: 2,
                  textTransform: 'none',
                  fontWeight: 'medium',
                  boxShadow: '0 4px 12px rgba(0,0,0,0.15)',
                  '&:hover': {
                    transform: 'translateY(-1px)',
                    boxShadow: '0 6px 20px rgba(0,0,0,0.2)',
                  },
                  transition: 'all 0.3s ease',
                }}
                startIcon={<Receipt />}
              >
                View Reports
              </Button>
            </DialogActions>
          </Dialog>
        </Container>
      </Box>
    </Box>
  );
};

export default BookingScreen;
