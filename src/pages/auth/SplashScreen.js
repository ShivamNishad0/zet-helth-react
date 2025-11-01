import React from 'react';
import { Box, Typography, Container } from '@mui/material';
import { COLORS } from '../../utils/constants';

const SplashScreen = () => {
  return (
    <Box
      sx={{
        minHeight: '100vh',
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
        backgroundColor: COLORS.PRIMARY,
        color: COLORS.WHITE,
      }}
    >
      <Container maxWidth="sm" sx={{ textAlign: 'center' }}>
        <Typography variant="h2" component="h1" gutterBottom>
          Zet Health
        </Typography>
        <Typography variant="h5" component="p">
          Your Health, Our Priority
        </Typography>
      </Container>
    </Box>
  );
};

export default SplashScreen;
