import React from 'react';
import { Box, Typography, Button } from '@mui/material';
import { useNavigate } from 'react-router-dom';
import { COLORS, WHATSAPP_URL } from '../../utils/constants';
import logo from '../../assets/images/logo.png';
import image from '../../assets/images/image.png';

const WelcomeScreen = () => {
  const navigate = useNavigate();

  const handleGetStarted = () => {
    navigate('/login');
  };

  const handleLetsTalk = () => {
    window.open(WHATSAPP_URL, '_blank');
  };

  return (
    <Box
      sx={{
        height: '100vh',
        backgroundColor: COLORS.PRIMARY,
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
        padding: 2,
        position: 'relative',
      }}
    >
      {/* Logo in the corner */}
      <Box
        sx={{
          position: 'absolute',
          top: 16,
          left: 16,
        }}
      >
        <img
          src={logo}
          alt="Zet Health Logo"
          style={{
            maxWidth: '200px',
            width: '100%',
            height: 'auto',
          }}
        />
      </Box>

      {/* Floating white panel that peeks from the top-right like the provided design */}
      <Box
        component="button"
        onClick={handleLetsTalk}
        aria-label="Let's Talk"
        sx={{
          position: 'fixed',
          top: { xs: -5, sm: -5 }, // negative so only bottom portion shows
          right: { xs: 12, sm: 18 },
          zIndex: 1400,
          width: { xs: 100, sm: 100 },
          height: { xs: 10, sm: 140 },
          backgroundColor: COLORS.WHITE,
          borderTopLeftRadius: 0,
          borderTopRightRadius: 0,
          borderBottomLeftRadius: { xs: 10, sm: 28 },
          borderBottomRightRadius: { xs: 22, sm: 28 },
          boxShadow: '0 8px 24px rgba(0,0,0,0.18)',
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
          padding: 0,
          cursor: 'pointer',
          border: 'none',
          transition: 'background-color 200ms ease, box-shadow 200ms ease, color 200ms ease',
          '&:hover': {
            backgroundColor: '#004d33',
            boxShadow: '0 10px 30px rgba(0,0,0,0.24)',
            '& span': {
              color: COLORS.WHITE,
            },
          },
          '&:focus': {
            outline: 'none',
            boxShadow: '0 0 0 3px rgba(0,77,51,0.18)',
            backgroundColor: '#004d33',
            '& span': {
              color: COLORS.WHITE,
            },
          },
          '&:active': {
            backgroundColor: '#003e2b',
          },
        }}
      >
        <Typography
          component="span"
          sx={{
            color: COLORS.PRIMARY,
            fontWeight: 800,
            textAlign: 'center',
            lineHeight: 1,
            fontSize: { xs: '1.1rem', sm: '1.4rem' },
            whiteSpace: 'pre-line',
            display: 'block',
            paddingBottom: { xs: 6, sm: 8 },
          }}
        >
          {"Let's\nTalk"}
        </Typography>
      </Box>

      <Box
        sx={{
          display: 'flex',
          flexDirection: { xs: 'column', md: 'row' },
          alignItems: 'center',
          justifyContent: 'space-between',
          width: '100%',
          maxWidth: 1200,
        }}
      >
        {/* Text Section - Left Half */}
        <Box
          sx={{
            flex: 1,
            display: 'flex',
            flexDirection: 'column',
            alignItems: { xs: 'center', md: 'flex-start' },
            justifyContent: 'center',
            textAlign: { xs: 'center', md: 'left' },
            color: COLORS.WHITE,
            mb: { xs: 4, md: 0 },
          }}
        >

          <Typography variant="h4" component="h2" gutterBottom sx={{ fontSize: '5.5rem', fontWeight: 1000 }}>
            India's First 10-min Healthcare App!
          </Typography>
          <Typography variant="body1" sx={{ mb: 3 }}>
            Experience seamless healthcare with ZetHealth. From pathology tests to <br />radiology services and soon, medicine deliveries – all from the comfort <br />of your home.
          </Typography>
          <Button
            variant="contained"
            onClick={handleGetStarted}
            sx={{
              backgroundColor: COLORS.WHITE,
              color: COLORS.PRIMARY,
              '&:hover': {
                backgroundColor: COLORS.LIGHT,
              },
            }}
          >
            Get Started
          </Button>
        </Box>

        {/* Image Section - Right Half */}
        <Box
          sx={{
            flex: 1,
            display: 'flex',
            justifyContent: 'center',
            alignItems: 'center',
          }}
        >
          <img
            src={image}
            alt="healthcare illustration"
            style={{
              maxWidth: '800px',
              width: '200%',
              height: '150%',
            }}
          />
        </Box>
      </Box>
    </Box>
  );
};

export default WelcomeScreen;
