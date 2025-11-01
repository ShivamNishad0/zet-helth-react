import React, { useEffect, useState, useMemo, useCallback } from 'react';
import {
  Container,
  Box,
  Typography,
  Grid,
  Card,
  CardContent,
  Button,
  TextField,
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  Chip,
  Alert,
  Toolbar,
  InputAdornment,
  MenuItem,
} from '@mui/material';
import {
  LocationOn,
  Description,
  Download,
  Visibility,
  FilterList,
  Search,
  MedicalServices,
} from '@mui/icons-material';
import { useSelector } from 'react-redux';
import { useNavigate } from 'react-router-dom';
import LoadingSpinner from '../../components/common/LoadingSpinner';
import { COLORS } from '../../utils/constants';
import { apiService } from '../../services/api';
import { toast } from 'react-hot-toast';
import useCurrentAddress from '../../hooks/useCurrentAddress';
import Header from '../../components/common/Header';



const ReportScreen = () => {
  const navigate = useNavigate();

  const { isAuthenticated } = useSelector((state) => state.auth);

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

  const [reports, setReports] = useState([]);
  const [loading, setLoading] = useState(true);
  const { currentAddress } = useCurrentAddress();
  const [searchQuery, setSearchQuery] = useState('');
  const [filterStatus, setFilterStatus] = useState('all');
  const [selectedReport, setSelectedReport] = useState(null);
  const [viewDialogOpen, setViewDialogOpen] = useState(false);

  useEffect(() => {
    loadReports();
  }, []);

  const loadReports = async () => {
    try {
      const response = await apiService.getReports();
      if (response && response.status && response.data && response.data.reportList) {
        setReports(response.data.reportList);
      }
    } catch (error) {
      console.error('Error loading reports:', error);
      toast.error('Failed to load reports');
    } finally {
      setLoading(false);
    }
  };



  const handleViewReport = useCallback((report) => {
    setSelectedReport(report);
    setViewDialogOpen(true);
  }, []);

  const handleDownloadReport = useCallback((report) => {
    if (report.reportPdf) {
      // Create a temporary link to download the PDF
      const link = document.createElement('a');
      link.href = report.reportPdf;
      link.download = `Report_${report.id}.pdf`;
      link.target = '_blank';
      document.body.appendChild(link);
      link.click();
      document.body.removeChild(link);
    } else {
      toast.error('Report PDF not available for download');
    }
  }, []);

  const getStatusColor = (status) => {
    switch (status?.toLowerCase()) {
      case 'completed':
      case 'available':
        return 'success';
      case 'pending':
      case 'processing':
        return 'warning';
      case 'failed':
        return 'error';
      default:
        return 'default';
    }
  };

  const filteredReports = useMemo(() => {
    return reports.filter((report) => {
      const matchesSearch = report.testName?.toLowerCase().includes(searchQuery.toLowerCase()) ||
                           report.bookingId?.toString().includes(searchQuery);
      const matchesFilter = filterStatus === 'all' || report.status?.toLowerCase() === filterStatus;
      return matchesSearch && matchesFilter;
    });
  }, [reports, searchQuery, filterStatus]);

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

          <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 4 }}>
            <Typography variant="h4" fontWeight="bold">
              My Reports
            </Typography>
          </Box>

          {/* Search and Filter */}
          <Box sx={{ display: 'flex', gap: 2, mb: 3, flexWrap: 'wrap' }}>
            <TextField
              placeholder="Search by test name or booking ID..."
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              InputProps={{
                startAdornment: (
                  <InputAdornment position="start">
                    <Search />
                  </InputAdornment>
                ),
              }}
              sx={{ minWidth: 300, flexGrow: 1 }}
            />

            <TextField
              select
              label="Filter by Status"
              value={filterStatus}
              onChange={(e) => setFilterStatus(e.target.value)}
              sx={{ minWidth: 150 }}
              InputProps={{
                startAdornment: (
                  <InputAdornment position="start">
                    <FilterList />
                  </InputAdornment>
                ),
              }}
            >
              <MenuItem value="all">All Status</MenuItem>
              <MenuItem value="completed">Completed</MenuItem>
              <MenuItem value="pending">Pending</MenuItem>
              <MenuItem value="processing">Processing</MenuItem>
              <MenuItem value="failed">Failed</MenuItem>
            </TextField>
          </Box>

          {filteredReports.length === 0 ? (
            <Box sx={{ textAlign: 'center', py: 8 }}>
              <Description sx={{ fontSize: 64, color: 'grey.400', mb: 2 }} />
              <Typography variant="h6" color="text.secondary" sx={{ mb: 2 }}>
                {reports.length === 0 ? 'No reports found' : 'No reports match your search'}
              </Typography>
              <Typography variant="body2" color="text.secondary" sx={{ mb: 3 }}>
                {reports.length === 0
                  ? 'Your lab test reports will appear here once they are ready'
                  : 'Try adjusting your search or filter criteria'
                }
              </Typography>
              {reports.length === 0 && (
                <Button
                  variant="contained"
                  startIcon={<MedicalServices />}
                  onClick={() => handleProtectedNavigation('/booking')}
                >
                  Book a Test
                </Button>
              )}
            </Box>
          ) : (
            <Grid container spacing={3}>
              {filteredReports.map((report) => (
                <Grid item xs={12} md={6} lg={4} key={report.id}>
                  <Card>
                    <CardContent>
                      <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', mb: 2 }}>
                        <Typography variant="h6" fontWeight="bold" sx={{ mb: 1 }}>
                          {report.testName || `Test Report #${report.id}`}
                        </Typography>
                        <Chip
                          label={report.status || 'Pending'}
                          color={getStatusColor(report.status)}
                          size="small"
                        />
                      </Box>

                      <Typography variant="body2" color="text.secondary" sx={{ mb: 1 }}>
                        Booking ID: {report.bookingId}
                      </Typography>

                      <Typography variant="body2" color="text.secondary" sx={{ mb: 1 }}>
                        Date: {report.testDate ? new Date(report.testDate).toLocaleDateString() : 'N/A'}
                      </Typography>

                      {report.labName && (
                        <Typography variant="body2" color="text.secondary" sx={{ mb: 2 }}>
                          Lab: {report.labName}
                        </Typography>
                      )}

                      <Box sx={{ display: 'flex', gap: 1, flexWrap: 'wrap' }}>
                        <Button
                          size="small"
                          variant="outlined"
                          startIcon={<Visibility />}
                          onClick={() => handleViewReport(report)}
                          disabled={!report.reportPdf && !report.reportImage}
                        >
                          View
                        </Button>
                        <Button
                          size="small"
                          variant="contained"
                          startIcon={<Download />}
                          onClick={() => handleDownloadReport(report)}
                          disabled={!report.reportPdf}
                        >
                          Download
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

      {/* View Report Dialog */}
      <Dialog
        open={viewDialogOpen}
        onClose={() => setViewDialogOpen(false)}
        maxWidth="md"
        fullWidth
        keepMounted={false}
      >
        <DialogTitle>
          {selectedReport?.testName || 'Test Report'}
        </DialogTitle>
        <DialogContent>
          {selectedReport && (
            <Box>
              <Typography variant="body2" color="text.secondary" sx={{ mb: 2 }}>
                Booking ID: {selectedReport.bookingId} | Date: {selectedReport.testDate ? new Date(selectedReport.testDate).toLocaleDateString() : 'N/A'}
              </Typography>

              {selectedReport.reportPdf ? (
                <Box sx={{ textAlign: 'center' }}>
                  <Typography variant="body2" sx={{ mb: 2 }}>
                    PDF Report
                  </Typography>
                  <iframe
                    src={selectedReport.reportPdf}
                    width="100%"
                    height="600px"
                    style={{ border: '1px solid #ccc' }}
                    title="Report PDF"
                  />
                </Box>
              ) : selectedReport.reportImage ? (
                <Box sx={{ textAlign: 'center' }}>
                  <Typography variant="body2" sx={{ mb: 2 }}>
                    Report Image
                  </Typography>
                  <img
                    src={selectedReport.reportImage}
                    alt="Test Report"
                    style={{ maxWidth: '100%', maxHeight: '600px', border: '1px solid #ccc' }}
                  />
                </Box>
              ) : (
                <Alert severity="info">
                  Report file is not available for viewing at this time.
                </Alert>
              )}
            </Box>
          )}
        </DialogContent>
        <DialogActions>
          <Button onClick={() => setViewDialogOpen(false)}>Close</Button>
          {selectedReport?.reportPdf && (
            <Button
              variant="contained"
              startIcon={<Download />}
              onClick={() => handleDownloadReport(selectedReport)}
            >
              Download PDF
            </Button>
          )}
        </DialogActions>
      </Dialog>
    </Box>
  );
};
export default ReportScreen;
