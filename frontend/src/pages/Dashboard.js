import React from 'react';
import {
  Container,
  Typography,
  Box,
  AppBar,
  Toolbar,
  Button,
  Grid,
  Card,
  CardContent,
  Paper
} from '@mui/material';
import { useNavigate } from 'react-router-dom';
import {
  Dashboard as DashboardIcon,
  People as PeopleIcon,
  Assessment as AssessmentIcon,
  ExitToApp as ExitToAppIcon
} from '@mui/icons-material';

const Dashboard = () => {
  const navigate = useNavigate();
  const userRole = localStorage.getItem('userRole');
  const userEmail = localStorage.getItem('userEmail');

  const handleLogout = () => {
    // Nettoyer toutes les données utilisateur
    localStorage.removeItem('userRole');
    localStorage.removeItem('userEmail');
    localStorage.removeItem('userId');
    localStorage.removeItem('userName');
    localStorage.removeItem('centreId');
    localStorage.removeItem('centreNom');
    navigate('/');
  };

  const dashboardCards = [
    {
      title: 'Gestion des Candidatures',
      description: 'Valider, rejeter et gérer les candidatures',
      icon: <PeopleIcon sx={{ fontSize: 40, color: 'primary.main' }} />,
      action: () => navigate('/gestion-candidatures')
    },
    {
      title: 'Statistiques',
      description: 'Consulter les rapports et statistiques',
      icon: <AssessmentIcon sx={{ fontSize: 40, color: 'primary.main' }} />,
      action: () => navigate('/statistiques')
    }
  ];

  return (
    <>
      <AppBar position="static">
        <Toolbar>
          <DashboardIcon sx={{ mr: 2 }} />
          <Typography variant="h6" component="div" sx={{ flexGrow: 1 }}>
            Tableau de Bord - {userRole}
          </Typography>
          <Typography variant="body2" sx={{ mr: 2 }}>
            {userEmail}
          </Typography>
          <Button 
            color="inherit" 
            onClick={handleLogout}
            startIcon={<ExitToAppIcon />}
          >
            Déconnexion
          </Button>
        </Toolbar>
      </AppBar>

      <Container maxWidth="lg" sx={{ mt: 4, mb: 4 }}>
        <Paper sx={{ p: 3, mb: 4 }}>
          <Typography variant="h4" gutterBottom>
            Bienvenue, {userRole}
          </Typography>
          <Typography variant="body1" color="text.secondary">
            Accédez rapidement aux fonctionnalités de votre espace de travail
          </Typography>
        </Paper>

        <Grid container spacing={3}>
          {dashboardCards.map((card, index) => (
            <Grid item xs={12} sm={6} md={4} key={index}>
              <Card
                sx={{
                  height: '100%',
                  cursor: 'pointer',
                  transition: 'transform 0.2s',
                  '&:hover': {
                    transform: 'translateY(-4px)',
                    boxShadow: 3
                  }
                }}
                onClick={card.action}
              >
                <CardContent sx={{ textAlign: 'center', p: 3 }}>
                  <Box sx={{ mb: 2 }}>
                    {card.icon}
                  </Box>
                  <Typography variant="h6" component="h3" gutterBottom>
                    {card.title}
                  </Typography>
                  <Typography variant="body2" color="text.secondary">
                    {card.description}
                  </Typography>
                </CardContent>
              </Card>
            </Grid>
          ))}
        </Grid>

        {/* Section statistiques rapides */}
        <Box sx={{ mt: 4 }}>
          <Typography variant="h5" gutterBottom>
            Aperçu Rapide
          </Typography>
          <Grid container spacing={2}>
            <Grid item xs={12} sm={4}>
              <Paper sx={{ p: 2, textAlign: 'center' }}>
                <Typography variant="h4" color="primary.main">
                  156
                </Typography>
                <Typography variant="body2">
                  Candidatures Totales
                </Typography>
              </Paper>
            </Grid>
            <Grid item xs={12} sm={4}>
              <Paper sx={{ p: 2, textAlign: 'center' }}>
                <Typography variant="h4" color="success.main">
                  89
                </Typography>
                <Typography variant="body2">
                  Candidatures Validées
                </Typography>
              </Paper>
            </Grid>
            <Grid item xs={12} sm={4}>
              <Paper sx={{ p: 2, textAlign: 'center' }}>
                <Typography variant="h4" color="warning.main">
                  23
                </Typography>
                <Typography variant="body2">
                  En Attente
                </Typography>
              </Paper>
            </Grid>
          </Grid>
        </Box>
      </Container>
    </>
  );
};

export default Dashboard;
