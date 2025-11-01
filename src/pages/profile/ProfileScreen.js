import React from 'react';
import {
  Container,
  Box,
  Typography,
  Grid,
  Card,
  CardContent,
  Button,
  Toolbar,
  Avatar,
} from '@mui/material';
import {
  LocationOn,
  Edit,
  Person,
  CreditCard,
  History,
  Help,
  Settings,
} from '@mui/icons-material';
import { useSelector } from 'react-redux';
import { useNavigate } from 'react-router-dom';
import { COLORS } from '../../utils/constants';
import { toast } from 'react-hot-toast';
import useCurrentAddress from '../../hooks/useCurrentAddress';
import Header from '../../components/common/Header';

const ProfileScreen = () => {
  const navigate = useNavigate();

  const { user, isAuthenticated } = useSelector((state) => state.auth);

  const { currentAddress } = useCurrentAddress();

  const handleProtectedNavigation = (path) => {
    if (isAuthenticated) {
      navigate(path);
    } else {
      toast.error('Please login first');
    }
  };

  const profileSections = [
    {
      title: 'Personal Information',
      icon: <Person />,
      items: [
        { label: 'Full Name', value: user?.userName || 'Not provided', editable: true },
        { label: 'Mobile Number', value: user?.userMobile || 'Not provided', editable: false },
        { label: 'Email', value: user?.userEmail || 'Not provided', editable: true },
        { label: 'Date of Birth', value: user?.userDob || 'Not provided', editable: true },
      ],
    },
    {
      title: 'Account & Preferences',
      icon: <Settings />,
      items: [
        { label: 'Account Type', value: 'Individual', editable: false },
        { label: 'Member Since', value: user?.createdAt ? new Date(user.createdAt).toLocaleDateString() : 'Not available', editable: false },
        { label: 'Preferred Language', value: 'English', editable: true },
        { label: 'Notification Preferences', value: 'Email & SMS', editable: true },
      ],
    },
  ];

  const quickActions = [
    {
      title: 'Manage Addresses',
      subtitle: 'Add, edit or remove delivery addresses',
      icon: <LocationOn />,
      action: () => handleProtectedNavigation('/address'),
    },
    {
      title: 'Order History',
      subtitle: 'View your previous orders and reports',
      icon: <History />,
      action: () => handleProtectedNavigation('/report'),
    },
    {
      title: 'Payment Methods',
      subtitle: 'Manage your saved payment options',
      icon: <CreditCard />,
      action: () => toast('Payment methods coming soon!'),
    },
    {
      title: 'Help & Support',
      subtitle: 'Get help or contact customer support',
      icon: <Help />,
      action: () => handleProtectedNavigation('/chat'),
    },
  ];

  if (!isAuthenticated) {
    return (
      <Container maxWidth="md" sx={{ py: 4 }}>
        <Card sx={{ p: 4, textAlign: 'center' }}>
          <Typography variant="h6" color="text.secondary">
            Please login to view your profile
          </Typography>
        </Card>
      </Container>
    );
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

          <Typography variant="h4" fontWeight="bold" sx={{ mb: 3 }}>
            My Profile
          </Typography>

          <Grid container spacing={3}>
            {/* Profile Header */}
            <Grid item xs={12}>
              <Card sx={{ p: 3, textAlign: 'center' }}>
                <Avatar
                  sx={{
                    width: 100,
                    height: 100,
                    bgcolor: COLORS.PRIMARY,
                    mx: 'auto',
                    mb: 2,
                    fontSize: '2rem'
                  }}
                >
                  {user?.userName?.charAt(0)?.toUpperCase() || 'U'}
                </Avatar>
                <Typography variant="h5" fontWeight="bold" sx={{ mb: 1 }}>
                  {user?.userName || 'User'}
                </Typography>
                <Typography variant="body1" color="text.secondary" sx={{ mb: 2 }}>
                  {user?.userMobile || ''}
                </Typography>
                <Button
                  variant="outlined"
                  startIcon={<Edit />}
                  onClick={() => toast('Edit profile coming soon!')}
                >
                  Edit Profile
                </Button>
              </Card>
            </Grid>

            {/* Profile Information */}
            {profileSections.map((section, index) => (
              <Grid item xs={12} md={6} key={index}>
                <Card>
                  <CardContent>
                    <Box sx={{ display: 'flex', alignItems: 'center', mb: 2 }}>
                      {section.icon}
                      <Typography variant="h6" fontWeight="bold" sx={{ ml: 1 }}>
                        {section.title}
                      </Typography>
                    </Box>
                    <Box sx={{ display: 'flex', flexDirection: 'column', gap: 2 }}>
                      {section.items.map((item, itemIndex) => (
                        <Box key={itemIndex} sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                          <Typography variant="body2" color="text.secondary">
                            {item.label}
                          </Typography>
                          <Typography variant="body1">
                            {item.value}
                          </Typography>
                        </Box>
                      ))}
                    </Box>
                  </CardContent>
                </Card>
              </Grid>
            ))}

            {/* Quick Actions */}
            <Grid item xs={12}>
              <Typography variant="h5" fontWeight="bold" sx={{ mb: 2 }}>
                Quick Actions
              </Typography>
              <Grid container spacing={2}>
                {quickActions.map((action, index) => (
                  <Grid item xs={12} sm={6} md={3} key={index}>
                    <Card
                      sx={{
                        cursor: 'pointer',
                        transition: 'all 0.3s ease',
                        '&:hover': { transform: 'translateY(-4px)', boxShadow: 3 }
                      }}
                      onClick={action.action}
                    >
                      <CardContent sx={{ textAlign: 'center', py: 3 }}>
                        <Box sx={{ color: COLORS.PRIMARY, mb: 1 }}>
                          {action.icon}
                        </Box>
                        <Typography variant="h6" fontWeight="bold" sx={{ mb: 1 }}>
                          {action.title}
                        </Typography>
                        <Typography variant="body2" color="text.secondary">
                          {action.subtitle}
                        </Typography>
                      </CardContent>
                    </Card>
                  </Grid>
                ))}
              </Grid>
            </Grid>
          </Grid>
        </Container>
      </Box>
    </Box>
  );
};

export default ProfileScreen;
