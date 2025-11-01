import React, { useState, useCallback } from 'react';
import {
  AppBar,
  Toolbar,
  IconButton,
  Box,
  Badge,
  Drawer,
  List,
  ListItem,
  ListItemButton,
  ListItemIcon,
  ListItemText,
  Divider,
  Avatar,
  Typography,
} from '@mui/material';
import {
  Menu,
  Search,
  ShoppingCart,
  Notifications,
  AccountCircle,
  Home as HomeIcon,
  MedicalServices,
  Receipt,
  Chat,
  Settings,
  Logout,
} from '@mui/icons-material';
import { useDispatch, useSelector } from 'react-redux';
import { useNavigate } from 'react-router-dom';
import { logoutUser } from '../../store/slices/authSlice';
import { COLORS } from '../../utils/constants';
import { toast } from 'react-hot-toast';

const drawerWidth = 280;

const Header = () => {
  const dispatch = useDispatch();
  const navigate = useNavigate();

  const { user, isAuthenticated } = useSelector((state) => state.auth);
  const { items: cartItems } = useSelector((state) => state.cart);

  const [drawerOpen, setDrawerOpen] = useState(false);

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
    { text: 'Home', icon: <HomeIcon />, path: '/home' },
    { text: 'Lab Tests', icon: <MedicalServices />, path: '/booking' },
    { text: 'Reports', icon: <Receipt />, path: '/report' },
    { text: 'Prescriptions', icon: <Receipt />, path: '/prescriptions' },
    { text: 'Chat Support', icon: <Chat />, path: '/chat' },
    { text: 'Notifications', icon: <Notifications />, path: '/notifications' },
    { text: 'Profile', icon: <AccountCircle />, path: '/profile' },
    { text: 'Settings', icon: <Settings />, path: '/settings' },
  ];

  return (
    <>
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
              <Notifications />
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
    </>
  );
};

export default Header;
