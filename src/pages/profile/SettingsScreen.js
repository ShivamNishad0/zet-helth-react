import React, { useEffect, useState } from 'react';
import {
  Container,
  Box,
  Typography,
  Grid,
  Card,
  CardContent,
  Button,
  Switch,
  FormControlLabel,
  Select,
  MenuItem,
  FormControl,
  InputLabel,
  Toolbar,
} from '@mui/material';
import {
  LocationOn,
  Security,
  NotificationsActive,
  Palette,
  Help,
  Info,
  Logout,
  Chat,
} from '@mui/icons-material';
import { useSelector } from 'react-redux';
import { useNavigate } from 'react-router-dom';
import { COLORS } from '../../utils/constants';
import { toast } from 'react-hot-toast';
import useCurrentAddress from '../../hooks/useCurrentAddress';
import Header from '../../components/common/Header';

const SettingsScreen = () => {
  const navigate = useNavigate();

  const { isAuthenticated } = useSelector((state) => state.auth);

  const { currentAddress } = useCurrentAddress();
  const [settings, setSettings] = useState({
    notifications: {
      push: true,
      email: true,
      sms: false,
      marketing: false,
    },
    privacy: {
      profileVisibility: 'private',
      dataSharing: false,
    },
    preferences: {
      language: 'en',
      theme: 'light',
    },
  });

  useEffect(() => {
    // Load settings from localStorage
    const savedSettings = localStorage.getItem('user_settings');
    if (savedSettings) {
      setSettings(JSON.parse(savedSettings));
    }
  }, []);

  const handleSettingChange = (category, key, value) => {
    const newSettings = {
      ...settings,
      [category]: {
        ...settings[category],
        [key]: value,
      },
    };
    setSettings(newSettings);
    localStorage.setItem('user_settings', JSON.stringify(newSettings));
    toast.success('Setting updated successfully');
  };

  const protectedPaths = new Set(['/booking', '/report', '/prescriptions', '/chat', '/notifications', '/profile', '/settings', '/cart', '/address']);

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

  const settingsSections = [
    {
      title: 'Notifications',
      icon: <NotificationsActive />,
      items: [
        {
          label: 'Push Notifications',
          description: 'Receive push notifications for important updates',
          type: 'switch',
          value: settings.notifications.push,
          onChange: (value) => handleSettingChange('notifications', 'push', value),
        },
        {
          label: 'Email Notifications',
          description: 'Receive notifications via email',
          type: 'switch',
          value: settings.notifications.email,
          onChange: (value) => handleSettingChange('notifications', 'email', value),
        },
        {
          label: 'SMS Notifications',
          description: 'Receive notifications via SMS',
          type: 'switch',
          value: settings.notifications.sms,
          onChange: (value) => handleSettingChange('notifications', 'sms', value),
        },
        {
          label: 'Marketing Communications',
          description: 'Receive promotional offers and updates',
          type: 'switch',
          value: settings.notifications.marketing,
          onChange: (value) => handleSettingChange('notifications', 'marketing', value),
        },
      ],
    },
    {
      title: 'Privacy & Security',
      icon: <Security />,
      items: [
        {
          label: 'Profile Visibility',
          description: 'Control who can see your profile information',
          type: 'select',
          value: settings.privacy.profileVisibility,
          options: [
            { value: 'public', label: 'Public' },
            { value: 'private', label: 'Private' },
            { value: 'friends', label: 'Friends Only' },
          ],
          onChange: (value) => handleSettingChange('privacy', 'profileVisibility', value),
        },
        {
          label: 'Data Sharing',
          description: 'Allow sharing of anonymized data for research',
          type: 'switch',
          value: settings.privacy.dataSharing,
          onChange: (value) => handleSettingChange('privacy', 'dataSharing', value),
        },
      ],
    },
    {
      title: 'Preferences',
      icon: <Palette />,
      items: [
        {
          label: 'Language',
          description: 'Choose your preferred language',
          type: 'select',
          value: settings.preferences.language,
          options: [
            { value: 'en', label: 'English' },
            { value: 'hi', label: 'Hindi' },
            { value: 'es', label: 'Spanish' },
          ],
          onChange: (value) => handleSettingChange('preferences', 'language', value),
        },
        {
          label: 'Theme',
          description: 'Choose your app theme',
          type: 'select',
          value: settings.preferences.theme,
          options: [
            { value: 'light', label: 'Light' },
            { value: 'dark', label: 'Dark' },
            { value: 'system', label: 'System Default' },
          ],
          onChange: (value) => handleSettingChange('preferences', 'theme', value),
        },
      ],
    },
  ];

  const accountActions = [
    {
      title: 'Change Password',
      subtitle: 'Update your account password',
      icon: <Security />,
      action: () => toast('Change password feature coming soon!'),
    },
    {
      title: 'Download My Data',
      subtitle: 'Request a copy of your personal data',
      icon: <Info />,
      action: () => toast('Data download feature coming soon!'),
    },
    {
      title: 'Delete Account',
      subtitle: 'Permanently delete your account',
      icon: <Logout />,
      action: () => toast('Account deletion feature coming soon!'),
      danger: true,
    },
  ];

  if (!isAuthenticated) {
    return (
      <Container maxWidth="md" sx={{ py: 4 }}>
        <Card sx={{ p: 4, textAlign: 'center' }}>
          <Typography variant="h6" color="text.secondary">
            Please login to access settings
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
            <Typography variant="body1" sx={{ cursor: 'pointer' }} onClick={() => handleProtectedNavigation('/address')}>
              {currentAddress}
            </Typography>
          </Box>

          <Typography variant="h4" fontWeight="bold" sx={{ mb: 3 }}>
            Settings
          </Typography>

          <Grid container spacing={3}>
            {/* Settings Sections */}
            {settingsSections.map((section, index) => (
              <Grid item xs={12} md={6} key={index}>
                <Card>
                  <CardContent>
                    <Box sx={{ display: 'flex', alignItems: 'center', mb: 3 }}>
                      {section.icon}
                      <Typography variant="h6" fontWeight="bold" sx={{ ml: 1 }}>
                        {section.title}
                      </Typography>
                    </Box>
                    <Box sx={{ display: 'flex', flexDirection: 'column', gap: 2 }}>
                      {section.items.map((item, itemIndex) => (
                        <Box key={itemIndex}>
                          <Typography variant="body1" fontWeight="medium" sx={{ mb: 1 }}>
                            {item.label}
                          </Typography>
                          <Typography variant="body2" color="text.secondary" sx={{ mb: 2 }}>
                            {item.description}
                          </Typography>
                          {item.type === 'switch' && (
                            <FormControlLabel
                              control={
                                <Switch
                                  checked={item.value}
                                  onChange={(e) => item.onChange(e.target.checked)}
                                  color="primary"
                                />
                              }
                              label={item.value ? 'Enabled' : 'Disabled'}
                            />
                          )}
                          {item.type === 'select' && (
                            <FormControl fullWidth size="small">
                              <InputLabel>Select Option</InputLabel>
                              <Select
                                value={item.value}
                                label="Select Option"
                                onChange={(e) => item.onChange(e.target.value)}
                              >
                                {item.options.map((option) => (
                                  <MenuItem key={option.value} value={option.value}>
                                    {option.label}
                                  </MenuItem>
                                ))}
                              </Select>
                            </FormControl>
                          )}
                        </Box>
                      ))}
                    </Box>
                  </CardContent>
                </Card>
              </Grid>
            ))}

            {/* Account Actions */}
            <Grid item xs={12}>
              <Typography variant="h5" fontWeight="bold" sx={{ mb: 2 }}>
                Account Management
              </Typography>
              <Grid container spacing={2}>
                {accountActions.map((action, index) => (
                  <Grid item xs={12} sm={6} md={4} key={index}>
                    <Card
                      sx={{
                        cursor: 'pointer',
                        transition: 'all 0.3s ease',
                        '&:hover': { transform: 'translateY(-4px)', boxShadow: 3 },
                        border: action.danger ? '1px solid #f44336' : 'none',
                      }}
                      onClick={action.action}
                    >
                      <CardContent sx={{ textAlign: 'center', py: 3 }}>
                        <Box sx={{ color: action.danger ? '#f44336' : COLORS.PRIMARY, mb: 1 }}>
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

            {/* Help & Support */}
            <Grid item xs={12}>
              <Card sx={{ p: 3, textAlign: 'center' }}>
                <Help sx={{ fontSize: 48, color: COLORS.PRIMARY, mb: 2 }} />
                <Typography variant="h6" fontWeight="bold" sx={{ mb: 1 }}>
                  Need Help?
                </Typography>
                <Typography variant="body1" color="text.secondary" sx={{ mb: 3 }}>
                  Contact our support team for assistance with your account or app usage.
                </Typography>
                <Button
                  variant="contained"
                  startIcon={<Chat />}
                  onClick={() => handleProtectedNavigation('/chat')}
                >
                  Contact Support
                </Button>
              </Card>
            </Grid>
          </Grid>
        </Container>
      </Box>
    </Box>
  );
};

export default SettingsScreen;
