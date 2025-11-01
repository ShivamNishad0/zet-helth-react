import React, { useEffect, useState, useCallback } from 'react';
import {
  Container,
  Box,
  Typography,
  Grid,
  Card,
  CardContent,
  Button,
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  Chip,
  Alert,
  Toolbar,
} from '@mui/material';
import {
  LocationOn,
  Description,
  CloudUpload,
  Visibility,
} from '@mui/icons-material';
import { useSelector } from 'react-redux';
import { useNavigate } from 'react-router-dom';
import LoadingSpinner from '../../components/common/LoadingSpinner';
import { COLORS } from '../../utils/constants';
import { apiService } from '../../services/api';
import { toast } from 'react-hot-toast';
import useCurrentAddress from '../../hooks/useCurrentAddress';
import Header from '../../components/common/Header';

const PrescriptionScreen = () => {
  const navigate = useNavigate();

  const { isAuthenticated } = useSelector((state) => state.auth);

  const [prescriptions, setPrescriptions] = useState([]);
  const [loading, setLoading] = useState(true);
  const { currentAddress } = useCurrentAddress();
  const [uploadDialogOpen, setUploadDialogOpen] = useState(false);
  const [selectedFile, setSelectedFile] = useState(null);
  const [uploading, setUploading] = useState(false);

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

  useEffect(() => {
    loadPrescriptions();
  }, []);

  const loadPrescriptions = async () => {
    try {
      const response = await apiService.getPrescriptions();
      if (response && response.status && response.data && response.data.prescriptionList) {
        setPrescriptions(response.data.prescriptionList);
      }
    } catch (error) {
      console.error('Error loading prescriptions:', error);
      toast.error('Failed to load prescriptions');
    } finally {
      setLoading(false);
    }
  };



  const handleFileSelect = useCallback((event) => {
    const file = event.target.files[0];
    if (file) {
      // Validate file type
      const allowedTypes = ['image/jpeg', 'image/jpg', 'image/png', 'application/pdf'];
      if (!allowedTypes.includes(file.type)) {
        toast.error('Please select a valid image (JPEG, PNG) or PDF file');
        return;
      }

      // Validate file size (5MB max)
      if (file.size > 5 * 1024 * 1024) {
        toast.error('File size should not exceed 5MB');
        return;
      }

      setSelectedFile(file);
    }
  }, []);

  const handleUploadPrescription = useCallback(async () => {
    if (!selectedFile) {
      toast.error('Please select a file to upload');
      return;
    }

    setUploading(true);
    try {
      const formData = new FormData();
      formData.append('prescription', selectedFile);

      const response = await apiService.uploadPrescription(formData);
      if (response && response.status) {
        toast.success('Prescription uploaded successfully');
        setUploadDialogOpen(false);
        setSelectedFile(null);
        loadPrescriptions();
      }
    } catch (error) {
      console.error('Error uploading prescription:', error);
      toast.error('Failed to upload prescription');
    } finally {
      setUploading(false);
    }
  }, [selectedFile]);

  const handleViewPrescription = useCallback((prescription) => {
    if (prescription.prescriptionImage) {
      window.open(prescription.prescriptionImage, '_blank');
    }
  }, []);

  const getStatusColor = (status) => {
    switch (status?.toLowerCase()) {
      case 'approved':
      case 'completed':
        return 'success';
      case 'pending':
        return 'warning';
      case 'rejected':
        return 'error';
      default:
        return 'default';
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

        <Container maxWidth="md">
          <Box sx={{ mb: 3, display: 'flex', alignItems: 'center', gap: 1 }}>
            <LocationOn sx={{ color: COLORS.PRIMARY }} />
            <Typography variant="body1" sx={{ cursor: 'pointer' }} onClick={() => handleProtectedNavigation('/address')}>
              {currentAddress}
            </Typography>
          </Box>

          <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 4 }}>
            <Typography variant="h4" fontWeight="bold">
              My Prescriptions
            </Typography>
            <Button
              variant="contained"
              startIcon={<CloudUpload />}
              onClick={() => setUploadDialogOpen(true)}
            >
              Upload Prescription
            </Button>
          </Box>

          {prescriptions.length === 0 ? (
            <Box sx={{ textAlign: 'center', py: 8 }}>
              <Description sx={{ fontSize: 64, color: 'grey.400', mb: 2 }} />
              <Typography variant="h6" color="text.secondary" sx={{ mb: 2 }}>
                No prescriptions found
              </Typography>
              <Typography variant="body2" color="text.secondary" sx={{ mb: 3 }}>
                Upload your prescriptions to get personalized test recommendations
              </Typography>
              <Button
                variant="contained"
                startIcon={<CloudUpload />}
                onClick={() => setUploadDialogOpen(true)}
              >
                Upload Your First Prescription
              </Button>
            </Box>
          ) : (
            <Grid container spacing={3}>
              {prescriptions.map((prescription) => (
                <Grid item xs={12} md={6} key={prescription.id}>
                  <Card>
                    <CardContent>
                      <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', mb: 2 }}>
                        <Typography variant="h6" fontWeight="bold">
                          Prescription #{prescription.id}
                        </Typography>
                        <Chip
                          label={prescription.status || 'Pending'}
                          color={getStatusColor(prescription.status)}
                          size="small"
                        />
                      </Box>

                      <Typography variant="body2" color="text.secondary" sx={{ mb: 1 }}>
                        Uploaded: {new Date(prescription.createdAt).toLocaleDateString()}
                      </Typography>

                      {prescription.notes && (
                        <Typography variant="body2" color="text.secondary" sx={{ mb: 2 }}>
                          Notes: {prescription.notes}
                        </Typography>
                      )}

                      <Box sx={{ display: 'flex', gap: 1 }}>
                        <Button
                          size="small"
                          variant="outlined"
                          startIcon={<Visibility />}
                          onClick={() => handleViewPrescription(prescription)}
                          disabled={!prescription.prescriptionImage}
                        >
                          View
                        </Button>
                      </Box>
                    </CardContent>
                  </Card>
                </Grid>
              ))}
            </Grid>
          )}
        </Container>
      </Box>

      {/* Upload Prescription Dialog */}
      <Dialog
        open={uploadDialogOpen}
        onClose={() => setUploadDialogOpen(false)}
        maxWidth="sm"
        fullWidth
        keepMounted={false}
      >
        <DialogTitle>
          Upload Prescription
        </DialogTitle>
        <DialogContent>
          <Box sx={{ pt: 2 }}>
            <Alert severity="info" sx={{ mb: 3 }}>
              Please upload a clear image of your prescription. Supported formats: JPEG, PNG, PDF. Maximum file size: 5MB.
            </Alert>

            <Box sx={{ textAlign: 'center', mb: 3 }}>
              <input
                accept="image/jpeg,image/jpg,image/png,application/pdf"
                style={{ display: 'none' }}
                id="prescription-file"
                type="file"
                onChange={handleFileSelect}
              />
              <label htmlFor="prescription-file">
                <Button
                  variant="outlined"
                  component="span"
                  startIcon={<CloudUpload />}
                  sx={{ mb: 2 }}
                >
                  Choose File
                </Button>
              </label>

              {selectedFile && (
                <Typography variant="body2" color="text.secondary">
                  Selected: {selectedFile.name}
                </Typography>
              )}
            </Box>
          </Box>
        </DialogContent>
        <DialogActions>
          <Button onClick={() => setUploadDialogOpen(false)}>Cancel</Button>
          <Button
            onClick={handleUploadPrescription}
            variant="contained"
            disabled={!selectedFile || uploading}
          >
            {uploading ? 'Uploading...' : 'Upload'}
          </Button>
        </DialogActions>
      </Dialog>
    </Box>
  );
};

export default PrescriptionScreen;
