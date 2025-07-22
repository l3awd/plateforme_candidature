import React from 'react';
import {
  Container,
  Typography,
  Button,
  Box,
  Grid,
  Card,
  CardContent,
  AppBar,
  Toolbar,
  Paper
} from '@mui/material';
import { useNavigate } from 'react-router-dom';
import {
  PersonAdd as PersonAddIcon,
  Login as LoginIcon,
  Assessment as AssessmentIcon,
  School as SchoolIcon
} from '@mui/icons-material';

const HomePage = () => {
  const navigate = useNavigate();

  const handleLoginClick = () => {
    navigate('/login');
  };


  const handleCandidatureClick = () => {
    // Navigation vers le formulaire de candidature
    navigate('/candidature');
  };

  const features = [
    {
      icon: <PersonAddIcon sx={{ fontSize: 40, color: 'primary.main' }} />,
      title: 'Carrière Enrichissante',
      description: 'Rejoignez une institution prestigieuse et contribuez au développement économique du pays.'
    },
    {
      icon: <AssessmentIcon sx={{ fontSize: 40, color: 'primary.main' }} />,
      title: 'Formation Continue',
      description: 'Bénéficiez de programmes de formation avancés et d\'évolution professionnelle constante.'
    },
    {
      icon: <SchoolIcon sx={{ fontSize: 40, color: 'primary.main' }} />,
      title: 'Impact National',
      description: 'Participez à la gestion des finances publiques et aux politiques économiques stratégiques.'
    }
  ];

  return (
    <>
      {/* Header/Navigation */}
      <AppBar position="static" elevation={0}>
        <Toolbar>
          <Typography variant="h6" component="div" sx={{ flexGrow: 1 }}>
            CandidaturePlus
          </Typography>
          <Button color="inherit" onClick={handleLoginClick} startIcon={<LoginIcon />}>
            Connexion Gestionnaire
          </Button>
  
        </Toolbar>
      </AppBar>

      {/* Section Hero */}
      <Box
        sx={{
          background: 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)',
          color: 'white',
          py: 8,
          textAlign: 'center'
        }}
      >
        <Container maxWidth="md">
          <Typography variant="h2" component="h1" gutterBottom fontWeight="bold">
            Plateforme de Gestion des Candidatures
          </Typography>
          <Typography variant="h5" component="p" sx={{ mb: 4, opacity: 0.9 }}>
            Simplifiez votre processus de candidature aux concours avec notre solution moderne et sécurisée
          </Typography>
          <Box sx={{ mt: 4 }}>
            <Button
              variant="contained"
              size="large"
              onClick={handleCandidatureClick}
              sx={{
                mr: 2,
                py: 1.5,
                px: 4,
                fontSize: '1.1rem',
                backgroundColor: 'rgba(255,255,255,0.2)',
                '&:hover': {
                  backgroundColor: 'rgba(255,255,255,0.3)',
                }
              }}
            >
              Déposer une Candidature
            </Button>
            <Button
              variant="outlined"
              size="large"
              onClick={() => navigate('/suivi')}
              sx={{
                py: 1.5,
                px: 4,
                fontSize: '1.1rem',
                color: 'white',
                borderColor: 'white',
                '&:hover': {
                  borderColor: 'white',
                  backgroundColor: 'rgba(255,255,255,0.1)',
                }
              }}
            >
              Suivre ma Candidature
            </Button>
          </Box>
        </Container>
      </Box>

      {/* Section Fonctionnalités */}
      <Container maxWidth="lg" sx={{ py: 8 }}>
        <Typography variant="h3" component="h2" textAlign="center" gutterBottom>
          Pourquoi choisir le Ministère de la Finance ?
        </Typography>
        <Typography variant="h6" textAlign="center" color="text.secondary" sx={{ mb: 6 }}>
          Une institution d'excellence au service de l'économie nationale
        </Typography>

        <Grid container spacing={4}>
          {features.map((feature, index) => (
            <Grid item xs={12} md={4} key={index}>
              <Card
                sx={{
                  height: '100%',
                  textAlign: 'center',
                  p: 3,
                  transition: 'transform 0.3s ease-in-out',
                  '&:hover': {
                    transform: 'translateY(-5px)',
                    boxShadow: 3
                  }
                }}
              >
                <CardContent>
                  <Box sx={{ mb: 2 }}>
                    {feature.icon}
                  </Box>
                  <Typography variant="h5" component="h3" gutterBottom>
                    {feature.title}
                  </Typography>
                  <Typography variant="body1" color="text.secondary">
                    {feature.description}
                  </Typography>
                </CardContent>
              </Card>
            </Grid>
          ))}
        </Grid>
      </Container>

      {/* Section Accès Rapide */}
      <Box sx={{ backgroundColor: '#f5f5f5', py: 6 }}>
        <Container maxWidth="md">
          <Paper elevation={3} sx={{ p: 4, textAlign: 'center' }}>
            <Typography variant="h4" component="h2" gutterBottom>
              Accès Candidat
            </Typography>
            <Typography variant="body1" sx={{ mb: 3 }}>
              Vous avez déjà soumis une candidature ? Saisissez votre numéro unique pour accéder à votre dossier.
            </Typography>
            <Box sx={{ display: 'flex', gap: 2, justifyContent: 'center', flexWrap: 'wrap' }}>
              <Button
                variant="contained"
                size="large"
                onClick={() => navigate('/candidature')}
                startIcon={<PersonAddIcon />}
              >
                Nouvelle Candidature
              </Button>
              <Button
                variant="outlined"
                size="large"
                onClick={() => navigate('/suivi')}
              >
                Suivre ma Candidature
              </Button>
            </Box>
          </Paper>
        </Container>
      </Box>

      {/* Footer */}
      <Box
        component="footer"
        sx={{
          backgroundColor: '#333',
          color: 'white',
          py: 3,
          textAlign: 'center'
        }}
      >
        <Container>
          <Typography variant="body2">
            © 2025 CandidaturePlus. Tous droits réservés.
          </Typography>
        </Container>
      </Box>
    </>
  );
};

export default HomePage;
