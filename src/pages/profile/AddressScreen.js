import React, { useEffect, useState, useCallback } from 'react';
import {
  Container,
  Box,
  Typography,
  Grid,
  Card,
  CardContent,
  Button,
  TextField,
  FormControl,
  InputLabel,
  Select,
  MenuItem,
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  IconButton,
  Chip,
  Toolbar,
} from '@mui/material';
import {
  Add,
  Edit,
  Delete,
  LocationOn,
} from '@mui/icons-material';
import { useNavigate } from 'react-router-dom';
import LoadingSpinner from '../../components/common/LoadingSpinner';
import { COLORS } from '../../utils/constants';
import { apiService } from '../../services/api';
import { toast } from 'react-hot-toast';
import useCurrentAddress from '../../hooks/useCurrentAddress';
import Header from '../../components/common/Header';

const AddressScreen = () => {
  const navigate = useNavigate();

  const [addresses, setAddresses] = useState([]);
  const [loading, setLoading] = useState(true);
  const { currentAddress } = useCurrentAddress();
  const [addDialogOpen, setAddDialogOpen] = useState(false);
  const [editingAddress, setEditingAddress] = useState(null);
  const [formData, setFormData] = useState({
    addressType: 'Home',
    addressLine1: '',
    addressLine2: '',
    city: '',
    state: '',
    pincode: '',
    landmark: '',
  });

  useEffect(() => {
    loadAddresses();
  }, []);

  const loadAddresses = async () => {
    try {
      const response = await apiService.getAddressList();
      if (response && response.status && response.data && response.data.addressList) {
        setAddresses(response.data.addressList);
      }
    } catch (error) {
      console.error('Error loading addresses:', error);
      toast.error('Failed to load addresses');
    } finally {
      setLoading(false);
    }
  };



  const handleAddAddress = useCallback(() => {
    setEditingAddress(null);
    setFormData({
      addressType: 'Home',
      addressLine1: '',
      addressLine2: '',
      city: '',
      state: '',
      pincode: '',
      landmark: '',
    });
    setAddDialogOpen(true);
  }, []);

  const handleEditAddress = useCallback((address) => {
    setEditingAddress(address);
    setFormData({
      addressType: address.addressType || 'Home',
      addressLine1: address.addressLine1 || '',
      addressLine2: address.addressLine2 || '',
      city: address.city || '',
      state: address.state || '',
      pincode: address.pincode || '',
      landmark: address.landmark || '',
    });
    setAddDialogOpen(true);
  }, []);

  const handleDeleteAddress = useCallback(async (addressId) => {
    if (!window.confirm('Are you sure you want to delete this address?')) {
      return;
    }

    try {
      const response = await apiService.deleteAddress(addressId);
      if (response && response.status) {
        toast.success('Address deleted successfully');
        loadAddresses();
      }
    } catch (error) {
      console.error('Error deleting address:', error);
      toast.error('Failed to delete address');
    }
  }, []);

  const handleSaveAddress = useCallback(async () => {
    // Validation
    if (!formData.addressLine1 || !formData.city || !formData.state || !formData.pincode) {
      toast.error('Please fill all required fields');
      return;
    }

    try {
      const addressData = {
        address_type: formData.addressType,
        address_line_1: formData.addressLine1,
        address_line_2: formData.addressLine2,
        city: formData.city,
        state: formData.state,
        pincode: formData.pincode,
        landmark: formData.landmark,
      };

      let response;
      if (editingAddress) {
        // For update, we might need a different endpoint or method
        // Since the API might not have update, we'll delete and add new
        await apiService.deleteAddress(editingAddress.id);
        response = await apiService.addAddress(addressData);
      } else {
        response = await apiService.addAddress(addressData);
      }

      if (response && response.status) {
        toast.success(editingAddress ? 'Address updated successfully' : 'Address added successfully');
        setAddDialogOpen(false);
        loadAddresses();
      }
    } catch (error) {
      console.error('Error saving address:', error);
      toast.error('Failed to save address');
    }
  }, [formData, editingAddress]);

  const handleSelectAddress = useCallback((address) => {
    const fullAddress = `${address.addressLine1}${address.addressLine2 ? ', ' + address.addressLine2 : ''}, ${address.city}, ${address.state} - ${address.pincode}`;
    localStorage.setItem('current_address', fullAddress);
    localStorage.setItem('selected_address_id', address.id);
    toast.success('Address selected successfully');
    navigate(-1); // Go back to previous screen
  }, [navigate]);

  if (loading) {
    return <LoadingSpinner fullScreen />;
  }

  return (
    <Box sx={{ display: 'flex' }}>
      <Header />

      <Box component="main" sx={{ flexGrow: 1, p: 3 }}>
        <Toolbar />

        <Container maxWidth="md">
          <Box sx={{ mb: 3, display: 'flex', alignItems: 'center', gap: 1 }}>
            <LocationOn sx={{ color: COLORS.PRIMARY }} />
            <Typography variant="body1">
              {currentAddress}
            </Typography>
          </Box>

          <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 4 }}>
            <Typography variant="h4" fontWeight="bold">
              My Addresses
            </Typography>
            <Button
              variant="contained"
              startIcon={<Add />}
              onClick={handleAddAddress}
            >
              Add Address
            </Button>
          </Box>

          {addresses.length === 0 ? (
            <Box sx={{ textAlign: 'center', py: 8 }}>
              <LocationOn sx={{ fontSize: 64, color: 'grey.400', mb: 2 }} />
              <Typography variant="h6" color="text.secondary" sx={{ mb: 2 }}>
                No addresses found
              </Typography>
              <Typography variant="body2" color="text.secondary" sx={{ mb: 3 }}>
                Add your delivery addresses to make booking easier
              </Typography>
              <Button
                variant="contained"
                startIcon={<Add />}
                onClick={handleAddAddress}
              >
                Add Your First Address
              </Button>
            </Box>
          ) : (
            <Grid container spacing={3}>
              {addresses.map((address) => (
                <Grid item xs={12} md={6} key={address.id}>
                  <Card sx={{ position: 'relative' }}>
                    <CardContent>
                      <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', mb: 2 }}>
                        <Chip
                          label={address.addressType || 'Home'}
                          color="primary"
                          size="small"
                        />
                        <Box>
                          <IconButton
                            size="small"
                            onClick={() => handleEditAddress(address)}
                            sx={{ mr: 1 }}
                          >
                            <Edit fontSize="small" />
                          </IconButton>
                          <IconButton
                            size="small"
                            color="error"
                            onClick={() => handleDeleteAddress(address.id)}
                          >
                            <Delete fontSize="small" />
                          </IconButton>
                        </Box>
                      </Box>

                      <Typography variant="body1" sx={{ mb: 1 }}>
                        {address.addressLine1}
                      </Typography>
                      {address.addressLine2 && (
                        <Typography variant="body1" sx={{ mb: 1 }}>
                          {address.addressLine2}
                        </Typography>
                      )}
                      <Typography variant="body2" color="text.secondary" sx={{ mb: 1 }}>
                        {address.city}, {address.state} - {address.pincode}
                      </Typography>
                      {address.landmark && (
                        <Typography variant="body2" color="text.secondary">
                          Landmark: {address.landmark}
                        </Typography>
                      )}

                      <Button
                        variant="outlined"
                        fullWidth
                        sx={{ mt: 2 }}
                        onClick={() => handleSelectAddress(address)}
                      >
                        Select This Address
                      </Button>
                    </CardContent>
                  </Card>
                </Grid>
              ))}
            </Grid>
          )}
        </Container>
      </Box>

      {/* Add/Edit Address Dialog */}
      <Dialog
        open={addDialogOpen}
        onClose={() => setAddDialogOpen(false)}
        maxWidth="sm"
        fullWidth
        keepMounted={false}
      >
        <DialogTitle>
          {editingAddress ? 'Edit Address' : 'Add New Address'}
        </DialogTitle>
        <DialogContent>
          <Box sx={{ pt: 2 }}>
            <FormControl fullWidth sx={{ mb: 3 }}>
              <InputLabel>Address Type</InputLabel>
              <Select
                value={formData.addressType}
                onChange={(e) => setFormData({ ...formData, addressType: e.target.value })}
                label="Address Type"
              >
                <MenuItem value="Home">Home</MenuItem>
                <MenuItem value="Work">Work</MenuItem>
                <MenuItem value="Other">Other</MenuItem>
              </Select>
            </FormControl>

            <TextField
              fullWidth
              label="Address Line 1 *"
              value={formData.addressLine1}
              onChange={(e) => setFormData({ ...formData, addressLine1: e.target.value })}
              sx={{ mb: 2 }}
              required
            />

            <TextField
              fullWidth
              label="Address Line 2"
              value={formData.addressLine2}
              onChange={(e) => setFormData({ ...formData, addressLine2: e.target.value })}
              sx={{ mb: 2 }}
            />

            <Grid container spacing={2} sx={{ mb: 2 }}>
              <Grid item xs={6}>
                <TextField
                  fullWidth
                  label="City *"
                  value={formData.city}
                  onChange={(e) => setFormData({ ...formData, city: e.target.value })}
                  required
                />
              </Grid>
              <Grid item xs={6}>
                <TextField
                  fullWidth
                  label="State *"
                  value={formData.state}
                  onChange={(e) => setFormData({ ...formData, state: e.target.value })}
                  required
                />
              </Grid>
            </Grid>

            <Grid container spacing={2} sx={{ mb: 2 }}>
              <Grid item xs={6}>
                <TextField
                  fullWidth
                  label="Pincode *"
                  value={formData.pincode}
                  onChange={(e) => setFormData({ ...formData, pincode: e.target.value })}
                  required
                />
              </Grid>
              <Grid item xs={6}>
                <TextField
                  fullWidth
                  label="Landmark"
                  value={formData.landmark}
                  onChange={(e) => setFormData({ ...formData, landmark: e.target.value })}
                />
              </Grid>
            </Grid>
          </Box>
        </DialogContent>
        <DialogActions>
          <Button onClick={() => setAddDialogOpen(false)}>Cancel</Button>
          <Button onClick={handleSaveAddress} variant="contained">
            {editingAddress ? 'Update' : 'Save'} Address
          </Button>
        </DialogActions>
      </Dialog>
    </Box>
  );
};

export default AddressScreen;
