import React, { useEffect } from 'react';
import {
  Container,
  Box,
  Typography,
  Grid,
  Card,
  CardContent,
  Button,
  Toolbar,
  TextField,
  IconButton,
  Divider,
} from '@mui/material';
import {
  Add,
  Remove,
  Delete,
  LocationOn,
  ShoppingCart,
} from '@mui/icons-material';
import { useDispatch, useSelector } from 'react-redux';
import { useNavigate } from 'react-router-dom';
import { fetchCart, removeItem, updateQuantity, clearCart } from '../../store/slices/cartSlice';
import LoadingSpinner from '../../components/common/LoadingSpinner';
import { COLORS } from '../../utils/constants';
import { toast } from 'react-hot-toast';
import useCurrentAddress from '../../hooks/useCurrentAddress';
import Header from '../../components/common/Header';

const CartScreen = () => {
  const dispatch = useDispatch();
  const navigate = useNavigate();

  const { isAuthenticated } = useSelector((state) => state.auth);
  const { items: cartItems, totalAmount, discountAmount, payableAmount, loading } = useSelector(
    (state) => state.cart
  );

  const { currentAddress } = useCurrentAddress();

  useEffect(() => {
    dispatch(fetchCart());
  }, [dispatch]);

  const handleProtectedNavigation = (path) => {
    if (isAuthenticated) {
      navigate(path);
    } else {
      toast.error('Please login first');
    }
  };

  const handleQuantityChange = (itemId, newQuantity) => {
    if (newQuantity < 1) return;
    dispatch(updateQuantity({ id: itemId, quantity: newQuantity }));
  };

  const handleRemoveItem = (itemId) => {
    dispatch(removeItem(itemId));
    toast.success('Item removed from cart');
  };

  const handleClearCart = () => {
    dispatch(clearCart());
    toast.success('Cart cleared');
  };

  const handleCheckout = () => {
    // Implement checkout logic
    toast.success('Checkout functionality coming soon!');
  };

  if (!isAuthenticated) {
    return (
      <Container maxWidth="md" sx={{ py: 4 }}>
        <Card sx={{ p: 4, textAlign: 'center' }}>
          <Typography variant="h6" color="text.secondary">
            Please login to view your cart
          </Typography>
        </Card>
      </Container>
    );
  }

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

          <Typography variant="h4" fontWeight="bold" sx={{ mb: 3 }}>
            Your Cart
          </Typography>

          {cartItems.length === 0 ? (
            <Card sx={{ p: 4, textAlign: 'center' }}>
              <ShoppingCart sx={{ fontSize: 64, color: 'text.secondary', mb: 2 }} />
              <Typography variant="h6" color="text.secondary" sx={{ mb: 2 }}>
                Your cart is empty
              </Typography>
              <Typography variant="body2" color="text.secondary" sx={{ mb: 3 }}>
                Add some lab tests or packages to get started
              </Typography>
              <Button
                variant="contained"
                color="primary"
                onClick={() => handleProtectedNavigation('/booking')}
              >
                Browse Tests
              </Button>
            </Card>
          ) : (
            <>
              <Grid container spacing={3}>
                <Grid item xs={12} md={8}>
                  {cartItems.map((item) => (
                    <Card key={item.id} sx={{ mb: 2 }}>
                      <CardContent>
                        <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start' }}>
                          <Box sx={{ flex: 1 }}>
                            <Typography variant="h6" fontWeight="bold">
                              {item.itemName || item.testName || item.packageName}
                            </Typography>
                            <Typography variant="body2" color="text.secondary" sx={{ mb: 1 }}>
                              {item.itemDescription || item.testDescription || item.packageDescription}
                            </Typography>
                            <Typography variant="h6" color={COLORS.PRIMARY} fontWeight="bold">
                              ₹{item.itemPrice || item.testPrice || item.packagePrice}
                            </Typography>
                          </Box>

                          <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
                            <IconButton
                              size="small"
                              onClick={() => handleQuantityChange(item.id, (item.quantity || 1) - 1)}
                              disabled={(item.quantity || 1) <= 1}
                            >
                              <Remove />
                            </IconButton>
                            <TextField
                              size="small"
                              value={item.quantity || 1}
                              onChange={(e) => handleQuantityChange(item.id, parseInt(e.target.value) || 1)}
                              inputProps={{ min: 1, style: { textAlign: 'center', width: 40 } }}
                              sx={{ width: 60 }}
                            />
                            <IconButton
                              size="small"
                              onClick={() => handleQuantityChange(item.id, (item.quantity || 1) + 1)}
                            >
                              <Add />
                            </IconButton>
                            <IconButton
                              color="error"
                              onClick={() => handleRemoveItem(item.id)}
                            >
                              <Delete />
                            </IconButton>
                          </Box>
                        </Box>
                      </CardContent>
                    </Card>
                  ))}
                </Grid>

                <Grid item xs={12} md={4}>
                  <Card sx={{ position: 'sticky', top: 20 }}>
                    <CardContent>
                      <Typography variant="h6" fontWeight="bold" sx={{ mb: 2 }}>
                        Order Summary
                      </Typography>

                      <Box sx={{ display: 'flex', justifyContent: 'space-between', mb: 1 }}>
                        <Typography variant="body1">Total Amount:</Typography>
                        <Typography variant="body1">₹{totalAmount}</Typography>
                      </Box>

                      {discountAmount > 0 && (
                        <Box sx={{ display: 'flex', justifyContent: 'space-between', mb: 1 }}>
                          <Typography variant="body1">Discount:</Typography>
                          <Typography variant="body1" color="success.main">-₹{discountAmount}</Typography>
                        </Box>
                      )}

                      <Divider sx={{ my: 2 }} />

                      <Box sx={{ display: 'flex', justifyContent: 'space-between', mb: 3 }}>
                        <Typography variant="h6" fontWeight="bold">Payable Amount:</Typography>
                        <Typography variant="h6" fontWeight="bold" color={COLORS.PRIMARY}>
                          ₹{payableAmount}
                        </Typography>
                      </Box>

                      <Button
                        variant="contained"
                        color="primary"
                        fullWidth
                        size="large"
                        onClick={handleCheckout}
                        sx={{ mb: 2 }}
                      >
                        Proceed to Checkout
                      </Button>

                      <Button
                        variant="outlined"
                        color="error"
                        fullWidth
                        onClick={handleClearCart}
                      >
                        Clear Cart
                      </Button>
                    </CardContent>
                  </Card>
                </Grid>
              </Grid>
            </>
          )}
        </Container>
      </Box>
    </Box>
  );
};

export default CartScreen;
