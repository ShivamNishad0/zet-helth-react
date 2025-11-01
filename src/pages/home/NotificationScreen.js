import React, { useEffect, useState, useCallback, useMemo } from 'react';
import {
  Container,
  Box,
  Typography,
  Card,
  CardContent,
  Button,
  IconButton,
  Chip,
  AppBar,
  Toolbar,
  Drawer,
  Avatar,
  List,
  ListItem,
  ListItemButton,
  ListItemIcon,
  ListItemText,
  Divider,
  Badge,
  Tabs,
  Tab,
} from '@mui/material';
import {
  LocationOn,
  MedicalServices,
  Receipt,
  Chat,
  Settings,
  Logout,
  Menu,
  Search,
  Notifications,
  AccountCircle,
  ShoppingCart,
  Home as HomeIcon,
  NotificationsActive,
  NotificationsNone,
  CheckCircle,
  Error,
  Info,
  Warning,
  Done,
  Delete,
} from '@mui/icons-material';
import { useDispatch, useSelector } from 'react-redux';
import { useNavigate } from 'react-router-dom';
import { logoutUser } from '../../store/slices/authSlice';
import LoadingSpinner from '../../components/common/LoadingSpinner';
import { COLORS } from '../../utils/constants';
import { apiService } from '../../services/api';
import { toast } from 'react-hot-toast';
import useCurrentAddress from '../../hooks/useCurrentAddress';

const drawerWidth = 280;

const NotificationScreen = () => {
  const dispatch = useDispatch();
  const navigate = useNavigate();

  const { user, isAuthenticated } = useSelector((state) => state.auth);
  const { items: cartItems } = useSelector((state) => state.cart);

  const [notifications, setNotifications] = useState([]);
  const [loading, setLoading] = useState(true);
  const [drawerOpen, setDrawerOpen] = useState(false);
  const { currentAddress } = useCurrentAddress();
  const [activeTab, setActiveTab] = useState(0);

  useEffect(() => {
    loadNotifications();
  }, []);

  const loadNotifications = async () => {
    try {
      const response = await apiService.getNotifications();
      if (response && response.status && response.data && response.data.notificationList) {
        setNotifications(response.data.notificationList);
      }
    } catch (error) {
      console.error('Error loading notifications:', error);
      toast.error('Failed to load notifications');
    } finally {
      setLoading(false);
    }
  };

  const handleDrawerToggle = useCallback(() => {
    setDrawerOpen(!drawerOpen);
  }, [drawerOpen]);

  const handleLogout = useCallback(async () => {
    try {
      await dispatch(logoutUser()).unwrap();
      navigate('/login');
    } catch (error) {
      navigate('/login');
    }
  }, [dispatch, navigate]);

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

  const drawerItems = [
    { text: 'Home', icon: <HomeIcon />, path: '/' },
    { text: 'Lab Tests', icon: <MedicalServices />, path: '/booking' },
    { text: 'Reports', icon: <Receipt />, path: '/report' },
    { text: 'Prescriptions', icon: <Receipt />, path: '/prescriptions' },
    { text: 'Chat Support', icon: <Chat />, path: '/chat' },
    { text: 'Notifications', icon: <Notifications />, path: '/notifications' },
    { text: 'Profile', icon: <AccountCircle />, path: '/profile' },
    { text: 'Settings', icon: <Settings />, path: '/settings' },
  ];

  const handleMarkAsRead = useCallback(async (notificationId) => {
    try {
      const response = await apiService.markNotificationAsRead(notificationId);
      if (response && response.status) {
        setNotifications(prev =>
          prev.map(notification =>
            notification.id === notificationId
              ? { ...notification, isRead: true }
              : notification
          )
        );
        toast.success('Notification marked as read');
      }
    } catch (error) {
      console.error('Error marking notification as read:', error);
      toast.error('Failed to mark notification as read');
    }
  }, []);

  const handleDeleteNotification = useCallback(async (notificationId) => {
    try {
      const response = await apiService.deleteNotification(notificationId);
      if (response && response.status) {
        setNotifications(prev => prev.filter(notification => notification.id !== notificationId));
        toast.success('Notification deleted');
      }
    } catch (error) {
      console.error('Error deleting notification:', error);
      toast.error('Failed to delete notification');
    }
  }, []);

  const handleMarkAllAsRead = useCallback(async () => {
    try {
      const unreadNotifications = notifications.filter(n => !n.isRead);
      if (unreadNotifications.length === 0) {
        toast.info('All notifications are already read');
        return;
      }

      const response = await apiService.markAllNotificationsAsRead();
      if (response && response.status) {
        setNotifications(prev =>
          prev.map(notification => ({ ...notification, isRead: true }))
        );
        toast.success('All notifications marked as read');
      }
    } catch (error) {
      console.error('Error marking all notifications as read:', error);
      toast.error('Failed to mark all notifications as read');
    }
  }, [notifications]);

  const getNotificationIcon = (type) => {
    switch (type?.toLowerCase()) {
      case 'success':
      case 'completed':
        return <CheckCircle sx={{ color: 'success.main' }} />;
      case 'error':
      case 'failed':
        return <Error sx={{ color: 'error.main' }} />;
      case 'warning':
        return <Warning sx={{ color: 'warning.main' }} />;
      case 'info':
      default:
        return <Info sx={{ color: 'info.main' }} />;
    }
  };



  const filteredNotifications = useMemo(() => {
    return notifications.filter(notification => {
      if (activeTab === 0) return true; // All
      if (activeTab === 1) return !notification.isRead; // Unread
      if (activeTab === 2) return notification.isRead; // Read
      return true;
    });
  }, [notifications, activeTab]);

  const unreadCount = useMemo(() => {
    return notifications.filter(n => !n.isRead).length;
  }, [notifications]);

  if (loading) {
    return <LoadingSpinner fullScreen />;
  }

  return (
    <Box sx={{ display: 'flex' }}>
      <AppBar position="fixed" sx={{ zIndex: (theme) => theme.zIndex.drawer + 1 }}>
        <Toolbar>
          <IconButton
            color="inherit"
            aria-label="open drawer"
            edge="start"
            onClick={handleDrawerToggle}
            sx={{ mr: 2 }}
          >
            <Menu />
          </IconButton>

          <Box sx={{ display: 'flex', alignItems: 'center', flexGrow: 1 }}>
            <img
              src={require('../../assets/images/logo.png')}
              alt="Zet Health Logo"
              style={{ height: 40, marginRight: 8, cursor: 'pointer' }}
              onClick={() => navigate('/home')}
            />
          </Box>

          <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
            <IconButton color="inherit">
              <Search />
            </IconButton>

            <IconButton color="inherit" onClick={() => handleProtectedNavigation('/cart')}>
              <Badge badgeContent={cartItems.length} color="error">
                <ShoppingCart />
              </Badge>
            </IconButton>

            <IconButton color="inherit" onClick={() => handleProtectedNavigation('/notifications')}>
              <Badge badgeContent={unreadCount} color="error">
                <Notifications />
              </Badge>
            </IconButton>

            <IconButton color="inherit" onClick={() => handleProtectedNavigation('/profile')}>
              <AccountCircle />
            </IconButton>
          </Box>
        </Toolbar>
      </AppBar>

      <Drawer
        variant="temporary"
        open={drawerOpen}
        onClose={handleDrawerToggle}
        ModalProps={{
          keepMounted: false,
        }}
        sx={{ '& .MuiDrawer-paper': { boxSizing: 'border-box', width: drawerWidth } }}
      >
        <Toolbar />
        <Box sx={{ overflow: 'auto' }}>
          <Box sx={{ p: 2, display: 'flex', alignItems: 'center', gap: 2 }}>
            <Avatar sx={{ bgcolor: COLORS.PRIMARY }}>
              {user?.userName?.charAt(0)?.toUpperCase() || 'U'}
            </Avatar>
            <Box>
              <Typography variant="subtitle1" fontWeight="bold">
                {user?.userName || 'User'}
              </Typography>
              <Typography variant="body2" color="text.secondary">
                {user?.userMobile || ''}
              </Typography>
            </Box>
          </Box>

          <Divider />

          <List>
            {drawerItems.map((item) => (
              <ListItem key={item.text} disablePadding>
                <ListItemButton
                  onClick={() => {
                    handleProtectedNavigation(item.path);
                    setDrawerOpen(false);
                  }}
                >
                  <ListItemIcon>{item.icon}</ListItemIcon>
                  <ListItemText primary={item.text} />
                </ListItemButton>
              </ListItem>
            ))}
          </List>

          <Divider />

          <List>
            <ListItem disablePadding>
              <ListItemButton onClick={handleLogout}>
                <ListItemIcon>
                  <Logout />
                </ListItemIcon>
                <ListItemText primary="Logout" />
              </ListItemButton>
            </ListItem>
          </List>
        </Box>
      </Drawer>

      <Box component="main" sx={{ flexGrow: 1, p: 3 }}>
        <Toolbar />

        <Container maxWidth="md">
          <Box sx={{ mb: 3, display: 'flex', alignItems: 'center', gap: 1 }}>
            <LocationOn sx={{ color: COLORS.PRIMARY }} />
            <Typography variant="body1" sx={{ cursor: 'pointer' }} onClick={() => handleProtectedNavigation('/address')}>
              {currentAddress}
            </Typography>
          </Box>

          <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 4 }}>
            <Typography variant="h4" fontWeight="bold">
              Notifications
            </Typography>
            {unreadCount > 0 && (
              <Button
                variant="outlined"
                startIcon={<Done />}
                onClick={handleMarkAllAsRead}
              >
                Mark All as Read
              </Button>
            )}
          </Box>

          <Box sx={{ borderBottom: 1, borderColor: 'divider', mb: 3 }}>
            <Tabs value={activeTab} onChange={(e, newValue) => setActiveTab(newValue)}>
              <Tab
                label={`All (${notifications.length})`}
                icon={<NotificationsNone />}
                iconPosition="start"
              />
              <Tab
                label={`Unread (${unreadCount})`}
                icon={<NotificationsActive />}
                iconPosition="start"
              />
              <Tab
                label={`Read (${notifications.length - unreadCount})`}
                icon={<CheckCircle />}
                iconPosition="start"
              />
            </Tabs>
          </Box>

          {filteredNotifications.length === 0 ? (
            <Box sx={{ textAlign: 'center', py: 8 }}>
              <NotificationsNone sx={{ fontSize: 64, color: 'grey.400', mb: 2 }} />
              <Typography variant="h6" color="text.secondary" sx={{ mb: 2 }}>
                {activeTab === 0 ? 'No notifications found' :
                 activeTab === 1 ? 'No unread notifications' :
                 'No read notifications'}
              </Typography>
              <Typography variant="body2" color="text.secondary">
                {activeTab === 0 ? 'You will receive notifications about your bookings, reports, and updates here' :
                 activeTab === 1 ? 'All caught up! No unread notifications.' :
                 'No read notifications yet.'}
              </Typography>
            </Box>
          ) : (
            <Box sx={{ display: 'flex', flexDirection: 'column', gap: 2 }}>
              {filteredNotifications.map((notification) => (
                <Card
                  key={notification.id}
                  sx={{
                    backgroundColor: notification.isRead ? 'grey.50' : 'white',
                    borderLeft: notification.isRead ? 'none' : `4px solid ${COLORS.PRIMARY}`,
                  }}
                >
                  <CardContent>
                    <Box sx={{ display: 'flex', alignItems: 'flex-start', gap: 2 }}>
                      {getNotificationIcon(notification.type)}

                      <Box sx={{ flexGrow: 1 }}>
                        <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', mb: 1 }}>
                          <Typography variant="h6" fontWeight={!notification.isRead ? 'bold' : 'normal'}>
                            {notification.title}
                          </Typography>
                          <Box sx={{ display: 'flex', gap: 1 }}>
                            {!notification.isRead && (
                              <Chip
                                label="New"
                                color="primary"
                                size="small"
                                variant="outlined"
                              />
                            )}
                            <Typography variant="body2" color="text.secondary">
                              {new Date(notification.createdAt).toLocaleDateString()}
                            </Typography>
                          </Box>
                        </Box>

                        <Typography variant="body1" sx={{ mb: 2 }}>
                          {notification.message}
                        </Typography>

                        {notification.actionUrl && (
                          <Button
                            size="small"
                            variant="outlined"
                            onClick={() => handleProtectedNavigation(notification.actionUrl)}
                            sx={{ mr: 1 }}
                          >
                            {notification.actionText || 'View Details'}
                          </Button>
                        )}

                        <Box sx={{ display: 'flex', gap: 1, mt: 1 }}>
                          {!notification.isRead && (
                            <Button
                              size="small"
                              startIcon={<Done />}
                              onClick={() => handleMarkAsRead(notification.id)}
                            >
                              Mark as Read
                            </Button>
                          )}
                          <Button
                            size="small"
                            color="error"
                            startIcon={<Delete />}
                            onClick={() => handleDeleteNotification(notification.id)}
                          >
                            Delete
                          </Button>
                        </Box>
                      </Box>
                    </Box>
                  </CardContent>
                </Card>
              ))}
            </Box>
          )}
        </Container>
      </Box>
    </Box>
  );
};

export default NotificationScreen;
