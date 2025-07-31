import React, { useState, useEffect } from 'react';
import {
  Container,
  Typography,
  Button,
  Box,
  Grid,
  Card,
  CardContent,
  CardActions,
  AppBar,
  Toolbar,
  TextField,
  MenuItem,
  Chip,
  Alert,
  CircularProgress,
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  Divider,
  List,
  ListItem,
  ListItemText,
  ListItemIcon
} from '@mui/material';
import { useNavigate } from 'react-router-dom';
import axios from 'axios';
import {
  Search as SearchIcon,
  Home as HomeIcon,
  Work as WorkIcon,
  LocationOn as LocationOnIcon,
  School as SchoolIcon,
  Event as EventIcon,
  People as PeopleIcon,
  Info as InfoIcon,
  PersonAdd as PersonAddIcon,
  CheckCircle as CheckCircleIcon,
  Cancel as CancelIcon,
  Download as DownloadIcon
} from '@mui/icons-material';

const PostesPage = () => {
  const navigate = useNavigate();
  const [concours, setConcours] = useState([]);
  const [centres, setCentres] = useState([]);
  const [specialites, setSpecialites] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [selectedConcours, setSelectedConcours] = useState('');
  const [selectedCentre, setSelectedCentre] = useState('');
  const [selectedSpecialite, setSelectedSpecialite] = useState('');
  const [detailDialog, setDetailDialog] = useState(null);

  // Chargement des données
  useEffect(() => {
    const loadData = async () => {
      try {
        setLoading(true);
        setError('');
        
        const [concoursRes, centresRes, specialitesRes] = await Promise.all([
          axios.get('http://localhost:8080/api/concours'),
          axios.get('http://localhost:8080/api/centres'),
          axios.get('http://localhost:8080/api/specialites')
        ]);
        
        // Validation des données reçues
        const concoursData = Array.isArray(concoursRes.data) ? concoursRes.data : [];
        const centresData = Array.isArray(centresRes.data) ? centresRes.data : [];
        const specialitesData = Array.isArray(specialitesRes.data) ? specialitesRes.data : [];
        
        setConcours(concoursData);
        setCentres(centresData);
        setSpecialites(specialitesData);
        
        console.log('Données chargées:', {
          concours: concoursData.length,
          centres: centresData.length,
          specialites: specialitesData.length
        });
        
      } catch (err) {
        console.error('Erreur lors du chargement:', err);
        setError('Erreur lors du chargement des données. Vérifiez que le backend est démarré.');
        // Initialiser avec des tableaux vides en cas d'erreur
        setConcours([]);
        setCentres([]);
        setSpecialites([]);
      } finally {
        setLoading(false);
      }
    };
    loadData();
  }, []);

  // Filtrage des données
  const getFilteredConcours = () => {
    if (!Array.isArray(concours)) return [];
    return concours.filter(c => {
      const now = new Date();
      const debut = new Date(c.dateDebutCandidature);
      const fin = new Date(c.dateFinCandidature);
      return c.actif && now >= debut && now <= fin;
    });
  };

  const getFilteredCentres = () => {
    if (!Array.isArray(centres)) return [];
    if (!selectedConcours) return centres.filter(c => c.actif);
    
    // Logique pour filtrer les centres selon le concours sélectionné
    // Pour l'instant, on retourne tous les centres actifs
    return centres.filter(c => c.actif);
  };

  const getFilteredSpecialites = () => {
    if (!Array.isArray(specialites)) return [];
    if (!selectedConcours) return specialites.filter(s => s.actif);
    
    // Logique pour filtrer les spécialités selon le concours sélectionné
    // Pour l'instant, on retourne toutes les spécialités actives
    return specialites.filter(s => s.actif);
  };

  const isConcoursOpen = (concours) => {
    const now = new Date();
    const debut = new Date(concours.dateDebutCandidature);
    const fin = new Date(concours.dateFinCandidature);
    return now >= debut && now <= fin;
  };

  const getDaysRemaining = (dateFinCandidature) => {
    const now = new Date();
    const fin = new Date(dateFinCandidature);
    const diffTime = fin - now;
    const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));
    return diffDays;
  };

  const formatDate = (dateString) => {
    return new Date(dateString).toLocaleDateString('fr-FR', {
      year: 'numeric',
      month: 'long',
      day: 'numeric'
    });
  };

  const handleVoirDetails = (concours) => {
    setDetailDialog(concours);
  };

  const handleCandidater = (concours) => {
    navigate('/candidature', { 
      state: { 
        preSelectedConcours: concours.id,
        preSelectedCentre: selectedCentre,
        preSelectedSpecialite: selectedSpecialite
      }
    });
  };

  if (loading) {
    return (
      <Box display="flex" justifyContent="center" alignItems="center" minHeight="100vh">
        <CircularProgress size={60} />
      </Box>
    );
  }

  return (
    <>
      <AppBar position="static">
        <Toolbar>
          <WorkIcon sx={{ mr: 2 }} />
          <Typography variant="h6" component="div" sx={{ flexGrow: 1 }}>
            Postes Disponibles
          </Typography>
          <Button color="inherit" onClick={() => navigate('/')} startIcon={<HomeIcon />}>
            Accueil
          </Button>
        </Toolbar>
      </AppBar>

      <Container maxWidth="lg" sx={{ mt: 4, mb: 4 }}>
        {/* Filtres */}
        <Card sx={{ p: 3, mb: 4 }}>
          <Typography variant="h5" gutterBottom>
            Rechercher des postes
          </Typography>
          <Typography variant="body2" color="text.secondary" sx={{ mb: 3 }}>
            Utilisez les filtres ci-dessous pour trouver les concours qui correspondent à votre profil
          </Typography>

          <Grid container spacing={3}>
            <Grid item xs={12} md={4}>
              <TextField
                fullWidth
                select
                label="Concours"
                value={selectedConcours}
                onChange={(e) => setSelectedConcours(e.target.value)}
              >
                <MenuItem value="">Tous les concours</MenuItem>
                {getFilteredConcours().map((c) => (
                  <MenuItem key={c.id} value={c.id}>
                    {c.nom}
                  </MenuItem>
                ))}
              </TextField>
            </Grid>
            <Grid item xs={12} md={4}>
              <TextField
                fullWidth
                select
                label="Centre"
                value={selectedCentre}
                onChange={(e) => setSelectedCentre(e.target.value)}
              >
                <MenuItem value="">Tous les centres</MenuItem>
                {getFilteredCentres().map((c) => (
                  <MenuItem key={c.id} value={c.id}>
                    {c.nom} - {c.ville}
                  </MenuItem>
                ))}
              </TextField>
            </Grid>
            <Grid item xs={12} md={4}>
              <TextField
                fullWidth
                select
                label="Spécialité"
                value={selectedSpecialite}
                onChange={(e) => setSelectedSpecialite(e.target.value)}
              >
                <MenuItem value="">Toutes les spécialités</MenuItem>
                {getFilteredSpecialites().map((s) => (
                  <MenuItem key={s.id} value={s.id}>
                    {s.nom} ({s.code})
                  </MenuItem>
                ))}
              </TextField>
            </Grid>
          </Grid>
        </Card>

        {error && (
          <Alert severity="error" sx={{ mb: 3 }}>
            {error}
          </Alert>
        )}

        {/* Liste des concours */}
        <Typography variant="h5" gutterBottom>
          Concours disponibles ({getFilteredConcours().length})
        </Typography>

        {getFilteredConcours().length === 0 ? (
          <Alert severity="info" sx={{ mt: 2 }}>
            Aucun concours ouvert actuellement. Veuillez revenir plus tard.
          </Alert>
        ) : (
          <Grid container spacing={3}>
            {getFilteredConcours()
              .filter(c => !selectedConcours || c.id == selectedConcours)
              .map((concours) => {
                const isOpen = isConcoursOpen(concours);
                const daysRemaining = getDaysRemaining(concours.dateFinCandidature);
                
                return (
                  <Grid item xs={12} md={6} lg={4} key={concours.id}>
                    <Card 
                      sx={{ 
                        height: '100%', 
                        display: 'flex', 
                        flexDirection: 'column',
                        opacity: isOpen ? 1 : 0.7,
                        border: isOpen ? '2px solid #4caf50' : '1px solid #e0e0e0'
                      }}
                    >
                      <CardContent sx={{ flexGrow: 1 }}>
                        <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', mb: 2 }}>
                          <Typography variant="h6" component="h3">
                            {concours.nom}
                          </Typography>
                          <Chip
                            icon={isOpen ? <CheckCircleIcon /> : <CancelIcon />}
                            label={isOpen ? 'Ouvert' : 'Fermé'}
                            color={isOpen ? 'success' : 'error'}
                            variant="outlined"
                            size="small"
                          />
                        </Box>

                        <Typography variant="body2" color="text.secondary" sx={{ mb: 2 }}>
                          {concours.description}
                        </Typography>

                        <Box sx={{ mb: 2 }}>
                          <Typography variant="body2" sx={{ display: 'flex', alignItems: 'center', mb: 1 }}>
                            <EventIcon sx={{ mr: 1, fontSize: 16, color: 'text.secondary' }} />
                            Candidatures : {formatDate(concours.dateDebutCandidature)} - {formatDate(concours.dateFinCandidature)}
                          </Typography>
                          
                          {concours.dateExamen && (
                            <Typography variant="body2" sx={{ display: 'flex', alignItems: 'center', mb: 1 }}>
                              <SchoolIcon sx={{ mr: 1, fontSize: 16, color: 'text.secondary' }} />
                              Examen : {formatDate(concours.dateExamen)}
                            </Typography>
                          )}

                          {isOpen && daysRemaining > 0 && (
                            <Alert severity={daysRemaining <= 7 ? 'warning' : 'info'} sx={{ mt: 1 }}>
                              {daysRemaining === 1 ? 
                                'Dernier jour pour candidater !' : 
                                `${daysRemaining} jours restants`
                              }
                            </Alert>
                          )}
                        </Box>

                        {/* Spécialités disponibles pour ce concours */}
                        <Typography variant="subtitle2" gutterBottom>
                          Spécialités disponibles :
                        </Typography>
                        <Box sx={{ display: 'flex', flexWrap: 'wrap', gap: 0.5, mb: 1 }}>
                          {getFilteredSpecialites().slice(0, 3).map((specialite) => (
                            <Chip
                              key={specialite.id}
                              label={specialite.code}
                              size="small"
                              variant="outlined"
                            />
                          ))}
                          {getFilteredSpecialites().length > 3 && (
                            <Chip
                              label={`+${getFilteredSpecialites().length - 3} autres`}
                              size="small"
                              variant="outlined"
                              color="primary"
                            />
                          )}
                        </Box>
                      </CardContent>

                      <CardActions sx={{ p: 2, pt: 0 }}>
                        <Button
                          size="small"
                          onClick={() => handleVoirDetails(concours)}
                          startIcon={<InfoIcon />}
                        >
                          Détails
                        </Button>
                        {concours.ficheConcours && (
                          <Button
                            size="small"
                            color="secondary"
                            onClick={() => {
                              const link = document.createElement('a');
                              link.href = concours.ficheConcours;
                              link.download = `fiche-${concours.nom.toLowerCase().replace(/\s+/g, '-')}.pdf`;
                              link.click();
                            }}
                            startIcon={<DownloadIcon />}
                          >
                            Télécharger Fiche
                          </Button>
                        )}
                        <Button
                          size="small"
                          variant="contained"
                          onClick={() => handleCandidater(concours)}
                          disabled={!isOpen}
                          startIcon={<PersonAddIcon />}
                        >
                          Candidater
                        </Button>
                      </CardActions>
                    </Card>
                  </Grid>
                );
              })}
          </Grid>
        )}

        {/* Informations générales */}
        <Card sx={{ mt: 4, p: 3 }}>
          <Typography variant="h6" gutterBottom>
            Informations importantes
          </Typography>
          <Grid container spacing={2}>
            <Grid item xs={12} md={6}>
              <Alert severity="info" sx={{ mb: 2 }}>
                <Typography variant="subtitle2" gutterBottom>
                  Avant de candidater :
                </Typography>
                <List dense>
                  <ListItem sx={{ pl: 0 }}>
                    <ListItemIcon sx={{ minWidth: 20 }}>•</ListItemIcon>
                    <ListItemText primary="Vérifiez que votre diplôme correspond à la spécialité" />
                  </ListItem>
                  <ListItem sx={{ pl: 0 }}>
                    <ListItemIcon sx={{ minWidth: 20 }}>•</ListItemIcon>
                    <ListItemText primary="Préparez tous les documents requis" />
                  </ListItem>
                  <ListItem sx={{ pl: 0 }}>
                    <ListItemIcon sx={{ minWidth: 20 }}>•</ListItemIcon>
                    <ListItemText primary="Respectez les dates limites de candidature" />
                  </ListItem>
                </List>
              </Alert>
            </Grid>
            <Grid item xs={12} md={6}>
              <Alert severity="warning">
                <Typography variant="subtitle2" gutterBottom>
                  Important :
                </Typography>
                <List dense>
                  <ListItem sx={{ pl: 0 }}>
                    <ListItemIcon sx={{ minWidth: 20 }}>•</ListItemIcon>
                    <ListItemText primary="Une seule candidature par concours" />
                  </ListItem>
                  <ListItem sx={{ pl: 0 }}>
                    <ListItemIcon sx={{ minWidth: 20 }}>•</ListItemIcon>
                    <ListItemText primary="Les candidatures sont définitives après soumission" />
                  </ListItem>
                  <ListItem sx={{ pl: 0 }}>
                    <ListItemIcon sx={{ minWidth: 20 }}>•</ListItemIcon>
                    <ListItemText primary="Conservez votre numéro de candidature" />
                  </ListItem>
                </List>
              </Alert>
            </Grid>
          </Grid>
        </Card>

        {/* Dialog de détails */}
        <Dialog
          open={!!detailDialog}
          onClose={() => setDetailDialog(null)}
          maxWidth="md"
          fullWidth
        >
          {detailDialog && (
            <>
              <DialogTitle>
                {detailDialog.nom}
              </DialogTitle>
              <DialogContent>
                <Typography variant="body1" paragraph>
                  {detailDialog.description}
                </Typography>

                <Divider sx={{ my: 2 }} />

                <Typography variant="h6" gutterBottom>
                  Calendrier
                </Typography>
                <Grid container spacing={2} sx={{ mb: 3 }}>
                  <Grid item xs={12} md={6}>
                    <Typography variant="subtitle2">Période de candidature :</Typography>
                    <Typography variant="body2">
                      Du {formatDate(detailDialog.dateDebutCandidature)} au {formatDate(detailDialog.dateFinCandidature)}
                    </Typography>
                  </Grid>
                  {detailDialog.dateExamen && (
                    <Grid item xs={12} md={6}>
                      <Typography variant="subtitle2">Date d'examen :</Typography>
                      <Typography variant="body2">
                        {formatDate(detailDialog.dateExamen)}
                      </Typography>
                    </Grid>
                  )}
                </Grid>

                {detailDialog.conditionsParticipation && (
                  <>
                    <Typography variant="h6" gutterBottom>
                      Conditions de participation
                    </Typography>
                    <Typography variant="body2" paragraph style={{ whiteSpace: 'pre-line' }}>
                      {detailDialog.conditionsParticipation}
                    </Typography>
                  </>
                )}

                {detailDialog.documentsRequis && (
                  <>
                    <Typography variant="h6" gutterBottom>
                      Documents requis
                    </Typography>
                    <Typography variant="body2" paragraph style={{ whiteSpace: 'pre-line' }}>
                      {detailDialog.documentsRequis}
                    </Typography>
                  </>
                )}

                <Typography variant="h6" gutterBottom>
                  Centres d'examen disponibles
                </Typography>
                <Grid container spacing={1}>
                  {getFilteredCentres().map((centre) => (
                    <Grid item xs={12} md={6} key={centre.id}>
                      <Card variant="outlined" sx={{ p: 2 }}>
                        <Typography variant="subtitle2">{centre.nom}</Typography>
                        <Typography variant="body2" color="text.secondary">
                          {centre.ville}
                        </Typography>
                        {centre.adresse && (
                          <Typography variant="body2" color="text.secondary">
                            {centre.adresse}
                          </Typography>
                        )}
                      </Card>
                    </Grid>
                  ))}
                </Grid>
              </DialogContent>
              <DialogActions>
                <Button onClick={() => setDetailDialog(null)}>
                  Fermer
                </Button>
                {detailDialog.ficheConcours && (
                  <Button
                    color="secondary"
                    onClick={() => {
                      const link = document.createElement('a');
                      link.href = detailDialog.ficheConcours;
                      link.download = `fiche-${detailDialog.nom.toLowerCase().replace(/\s+/g, '-')}.pdf`;
                      link.click();
                    }}
                    startIcon={<DownloadIcon />}
                  >
                    Télécharger Fiche
                  </Button>
                )}
                <Button
                  variant="contained"
                  onClick={() => {
                    setDetailDialog(null);
                    handleCandidater(detailDialog);
                  }}
                  disabled={!isConcoursOpen(detailDialog)}
                >
                  Candidater
                </Button>
              </DialogActions>
            </>
          )}
        </Dialog>
      </Container>
    </>
  );
};

export default PostesPage;
