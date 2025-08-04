import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import {
  Container, Typography, Grid, Card, CardContent, CardActions,
  Button, Box, FormControl, InputLabel, Select, MenuItem,
  Chip, CircularProgress, Alert, Dialog, DialogTitle, DialogContent,
  DialogActions, List, ListItem, ListItemText, ListItemButton,
  Divider, Badge, IconButton, Tooltip, Paper
} from '@mui/material';
import {
  LocationOn as LocationIcon,
  School as SchoolIcon,
  Event as EventIcon,
  People as PeopleIcon,
  Assignment as AssignmentIcon
} from '@mui/icons-material';
import axios from 'axios';

const PostesPageComplete = () => {
  const navigate = useNavigate();
  const [concours, setConcours] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [filtreSpecialite, setFiltreSpecialite] = useState('');
  
  // État pour la sélection détaillée
  const [selectedConcours, setSelectedConcours] = useState(null);
  const [openSelectionDialog, setOpenSelectionDialog] = useState(false);
  const [specialitesDisponibles, setSpecialitesDisponibles] = useState([]);
  const [centresDisponibles, setCentresDisponibles] = useState([]);

  useEffect(() => {
    loadConcours();
  }, []);

  const loadConcours = async () => {
    try {
      const response = await axios.get('http://localhost:8080/api/concours');
      setConcours(response.data || []);
    } catch (err) {
      console.error('Erreur lors du chargement des concours:', err);
      setError('Erreur lors du chargement des concours');
    } finally {
      setLoading(false);
    }
  };

  const loadConcoursDetails = async (concoursId) => {
    try {
      const [specialitesRes, centresRes] = await Promise.all([
        axios.get(`http://localhost:8080/api/concours/${concoursId}/specialites`),
        axios.get(`http://localhost:8080/api/concours/${concoursId}/centres`)
      ]);
      
      setSpecialitesDisponibles(specialitesRes.data || []);
      setCentresDisponibles(centresRes.data || []);
    } catch (err) {
      console.error('Erreur chargement détails:', err);
      setError('Erreur lors du chargement des détails du concours');
    }
  };

  const handleCandidater = async (concour) => {
    setSelectedConcours(concour);
    await loadConcoursDetails(concour.id);
    setOpenSelectionDialog(true);
  };

  const handleSelectionComplete = (specialiteId, centreId) => {
    setOpenSelectionDialog(false);
    
    // Rediriger vers la page de candidature avec les valeurs pré-sélectionnées
    navigate('/candidature-complete', {
      state: {
        concoursId: selectedConcours.id,
        specialiteId: specialiteId,
        centreId: centreId
      }
    });
  };

  const concoursFiltered = filtreSpecialite 
    ? concours.filter(c => c.specialites?.some(s => s.id === parseInt(filtreSpecialite)))
    : concours;

  const specialitesUniques = [...new Set(
    concours.flatMap(c => c.specialites || [])
      .map(s => ({ id: s.id, nom: s.nom }))
  )];

  const renderSelectionDialog = () => (
    <Dialog open={openSelectionDialog} onClose={() => setOpenSelectionDialog(false)} maxWidth="md" fullWidth>
      <DialogTitle>
        <Typography variant="h6">
          Choisir Spécialité et Centre - {selectedConcours?.nom}
        </Typography>
      </DialogTitle>
      <DialogContent>
        <Grid container spacing={3}>
          {/* Spécialités disponibles */}
          <Grid item xs={12} md={6}>
            <Paper sx={{ p: 2 }}>
              <Typography variant="h6" gutterBottom color="primary">
                <SchoolIcon sx={{ mr: 1, verticalAlign: 'middle' }} />
                Spécialités Disponibles
              </Typography>
              <Divider sx={{ mb: 2 }} />
              
              <List>
                {specialitesDisponibles.map((specialite) => (
                  <ListItem key={specialite.id} disablePadding>
                    <ListItemButton
                      onClick={() => {
                        // Pour simplifier, on prend le premier centre disponible
                        // Dans une version plus avancée, on pourrait permettre de choisir
                        const premierCentre = centresDisponibles[0];
                        if (premierCentre) {
                          handleSelectionComplete(specialite.id, premierCentre.id);
                        }
                      }}
                      sx={{ 
                        border: 1, 
                        borderColor: 'grey.300', 
                        borderRadius: 1, 
                        mb: 1,
                        '&:hover': {
                          borderColor: 'primary.main',
                          bgcolor: 'primary.50'
                        }
                      }}
                    >
                      <ListItemText
                        primary={specialite.nom}
                        secondary={specialite.description}
                      />
                      <Badge badgeContent={specialite.placesDisponibles || '∞'} color="primary" />
                    </ListItemButton>
                  </ListItem>
                ))}
              </List>
            </Paper>
          </Grid>

          {/* Centres disponibles */}
          <Grid item xs={12} md={6}>
            <Paper sx={{ p: 2 }}>
              <Typography variant="h6" gutterBottom color="primary">
                <LocationIcon sx={{ mr: 1, verticalAlign: 'middle' }} />
                Centres d'Examen
              </Typography>
              <Divider sx={{ mb: 2 }} />
              
              <List>
                {centresDisponibles.map((centre) => (
                  <ListItem key={centre.id} sx={{ 
                    border: 1, 
                    borderColor: 'grey.300', 
                    borderRadius: 1, 
                    mb: 1 
                  }}>
                    <ListItemText
                      primary={centre.nom}
                      secondary={
                        <Box>
                          <Typography variant="body2" color="text.secondary">
                            {centre.ville} - {centre.adresse}
                          </Typography>
                          <Typography variant="caption" color="primary">
                            Capacité: {centre.capacite || 'Non spécifiée'}
                          </Typography>
                        </Box>
                      }
                    />
                  </ListItem>
                ))}
              </List>
            </Paper>
          </Grid>

          {/* Instructions */}
          <Grid item xs={12}>
            <Alert severity="info">
              <Typography variant="body2">
                <strong>Instructions :</strong><br />
                • Cliquez sur une spécialité pour continuer vers la candidature<br />
                • Le centre sera assigné automatiquement selon la disponibilité<br />
                • Vous pourrez modifier votre choix dans le formulaire de candidature
              </Typography>
            </Alert>
          </Grid>
        </Grid>
      </DialogContent>
      <DialogActions>
        <Button onClick={() => setOpenSelectionDialog(false)}>
          Annuler
        </Button>
      </DialogActions>
    </Dialog>
  );

  if (loading) {
    return (
      <Box display="flex" justifyContent="center" alignItems="center" minHeight="50vh">
        <CircularProgress />
      </Box>
    );
  }

  return (
    <Container maxWidth="lg" sx={{ py: 4 }}>
      <Typography variant="h4" gutterBottom align="center">
        Postes Disponibles
      </Typography>

      <Typography variant="body1" align="center" color="text.secondary" sx={{ mb: 4 }}>
        Explorez les concours disponibles et candidatez directement avec une sélection guidée
      </Typography>

      {error && (
        <Alert severity="error" sx={{ mb: 3 }}>
          {error}
        </Alert>
      )}

      {/* Filtre par spécialité */}
      <Box sx={{ mb: 4, maxWidth: 300 }}>
        <FormControl fullWidth>
          <InputLabel>Filtrer par spécialité</InputLabel>
          <Select
            value={filtreSpecialite}
            label="Filtrer par spécialité"
            onChange={(e) => setFiltreSpecialite(e.target.value)}
          >
            <MenuItem value="">Toutes les spécialités</MenuItem>
            {specialitesUniques.map(s => (
              <MenuItem key={s.id} value={s.id}>{s.nom}</MenuItem>
            ))}
          </Select>
        </FormControl>
      </Box>

      <Grid container spacing={3}>
        {concoursFiltered.map((concour) => {
          const isExpired = new Date() > new Date(concour.dateLimite);
          
          return (
            <Grid item xs={12} md={6} lg={4} key={concour.id}>
              <Card sx={{ 
                height: '100%', 
                display: 'flex', 
                flexDirection: 'column',
                opacity: isExpired ? 0.6 : 1,
                transition: 'all 0.3s ease',
                '&:hover': !isExpired ? {
                  transform: 'translateY(-4px)',
                  boxShadow: 4
                } : {}
              }}>
                <CardContent sx={{ flexGrow: 1 }}>
                  <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', mb: 2 }}>
                    <Typography variant="h5" component="h2" gutterBottom>
                      {concour.nom}
                    </Typography>
                    {!isExpired && (
                      <Chip label="Ouvert" color="success" size="small" />
                    )}
                    {isExpired && (
                      <Chip label="Fermé" color="error" size="small" />
                    )}
                  </Box>

                  <Typography variant="body2" color="text.secondary" paragraph>
                    {concour.description}
                  </Typography>
                  
                  <Box sx={{ display: 'flex', alignItems: 'center', mb: 1 }}>
                    <EventIcon sx={{ mr: 1, fontSize: 16, color: 'text.secondary' }} />
                    <Typography variant="body2">
                      <strong>Date limite:</strong> {new Date(concour.dateLimite).toLocaleDateString('fr-FR')}
                    </Typography>
                  </Box>
                  
                  <Box sx={{ display: 'flex', alignItems: 'center', mb: 2 }}>
                    <AssignmentIcon sx={{ mr: 1, fontSize: 16, color: 'text.secondary' }} />
                    <Typography variant="body2">
                      <strong>Date du concours:</strong> {new Date(concour.dateConcours).toLocaleDateString('fr-FR')}
                    </Typography>
                  </Box>

                  {concour.specialites && concour.specialites.length > 0 && (
                    <Box sx={{ mt: 2 }}>
                      <Box sx={{ display: 'flex', alignItems: 'center', mb: 1 }}>
                        <SchoolIcon sx={{ mr: 1, fontSize: 16, color: 'text.secondary' }} />
                        <Typography variant="body2">
                          <strong>Spécialités disponibles:</strong>
                        </Typography>
                      </Box>
                      <Box sx={{ display: 'flex', flexWrap: 'wrap', gap: 0.5 }}>
                        {concour.specialites.slice(0, 3).map(specialite => (
                          <Chip
                            key={specialite.id}
                            label={specialite.nom}
                            size="small"
                            variant="outlined"
                            color="primary"
                          />
                        ))}
                        {concour.specialites.length > 3 && (
                          <Chip
                            label={`+${concour.specialites.length - 3} autres`}
                            size="small"
                            variant="outlined"
                            color="secondary"
                          />
                        )}
                      </Box>
                    </Box>
                  )}

                  {/* Indicateur de places */}
                  <Box sx={{ mt: 2, display: 'flex', alignItems: 'center' }}>
                    <PeopleIcon sx={{ mr: 1, fontSize: 16, color: 'text.secondary' }} />
                    <Typography variant="body2" color="success.main">
                      Places disponibles dans plusieurs centres
                    </Typography>
                  </Box>
                </CardContent>
                
                <CardActions sx={{ p: 2 }}>
                  <Button
                    fullWidth
                    variant="contained"
                    onClick={() => handleCandidater(concour)}
                    disabled={isExpired}
                    size="large"
                    sx={{
                      backgroundColor: isExpired ? 'grey.400' : 'primary.main',
                      '&:hover': {
                        backgroundColor: isExpired ? 'grey.400' : 'primary.dark',
                      }
                    }}
                  >
                    {isExpired ? 'Date limite dépassée' : 'Candidater Maintenant'}
                  </Button>
                </CardActions>
              </Card>
            </Grid>
          );
        })}
      </Grid>

      {concoursFiltered.length === 0 && !loading && (
        <Paper sx={{ p: 4, textAlign: 'center', mt: 4 }}>
          <Typography variant="h6" color="text.secondary" gutterBottom>
            Aucun concours disponible
          </Typography>
          <Typography variant="body2" color="text.secondary">
            {filtreSpecialite 
              ? 'Aucun concours ne correspond au filtre sélectionné'
              : 'Aucun concours n\'est disponible pour le moment'
            }
          </Typography>
        </Paper>
      )}

      {/* Dialog de sélection */}
      {renderSelectionDialog()}
    </Container>
  );
};

export default PostesPageComplete;
