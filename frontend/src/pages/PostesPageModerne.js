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
  ListItemIcon,
  Badge,
  Paper,
  Avatar,
  CardMedia,
  FormControl,
  InputLabel,
  Select,
  OutlinedInput,
  InputAdornment
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
  Download as DownloadIcon,
  FilterList as FilterIcon,
  Clear as ClearIcon,
  Timer as TimerIcon,
  Assignment as AssignmentIcon,
  AccessTime as AccessTimeIcon,
  DateRange as DateRangeIcon
} from '@mui/icons-material';

const PostesPageModerne = () => {
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
  const [searchTerm, setSearchTerm] = useState('');

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
        
        setConcours(concoursRes.data || []);
        setCentres(centresRes.data || []);
        setSpecialites(specialitesRes.data || []);
        
      } catch (err) {
        console.error('Erreur chargement:', err);
        setError('Erreur lors du chargement des données. Vérifiez que le backend est démarré.');
      } finally {
        setLoading(false);
      }
    };

    loadData();
  }, []);

  // Utilitaires
  const isConcoursOpen = (concours) => {
    const now = new Date();
    const dateFin = new Date(concours.dateFinCandidature);
    return dateFin > now && concours.actif;
  };

  const getDaysRemaining = (dateFin) => {
    const now = new Date();
    const fin = new Date(dateFin);
    const diff = Math.ceil((fin - now) / (1000 * 60 * 60 * 24));
    return diff > 0 ? diff : 0;
  };

  const formatDate = (dateString) => {
    return new Date(dateString).toLocaleDateString('fr-FR', {
      day: '2-digit',
      month: '2-digit',
      year: 'numeric'
    });
  };

  const handleCandidater = (concours) => {
    navigate('/candidature', {
      state: {
        concoursId: concours.id,
        fromPostes: true
      }
    });
  };

  const handleVoirDetails = (concours) => {
    setDetailDialog(concours);
  };

  const handleTelechargerFiche = (ficheUrl) => {
    if (ficheUrl) {
      window.open(ficheUrl, '_blank');
    } else {
      alert('Fiche de concours non disponible');
    }
  };

  const clearFilters = () => {
    setSelectedConcours('');
    setSelectedCentre('');
    setSelectedSpecialite('');
    setSearchTerm('');
  };

  // Filtrage des données
  const getFilteredConcours = () => {
    return concours.filter(c => {
      const matchSearch = !searchTerm || 
        c.nom.toLowerCase().includes(searchTerm.toLowerCase()) ||
        c.description?.toLowerCase().includes(searchTerm.toLowerCase());
      
      const matchConcours = !selectedConcours || c.id == selectedConcours;
      
      // Pour les centres et spécialités, on vérifie les associations
      const matchCentre = !selectedCentre || 
        (c.centres && c.centres.some(centre => centre.id == selectedCentre));
      
      const matchSpecialite = !selectedSpecialite || 
        (c.specialites && c.specialites.some(spec => spec.id == selectedSpecialite));
      
      return matchSearch && matchConcours && matchCentre && matchSpecialite;
    });
  };

  const getFilteredSpecialites = () => {
    return [...new Set(concours.flatMap(c => c.specialites || []))];
  };

  const getFilteredCentres = () => {
    return [...new Set(concours.flatMap(c => c.centres || []))];
  };

  if (loading) {
    return (
      <Box display="flex" justifyContent="center" alignItems="center" minHeight="50vh">
        <CircularProgress size={60} />
      </Box>
    );
  }

  return (
    <>
      <AppBar position="static" sx={{ background: 'linear-gradient(45deg, #1976d2 30%, #42a5f5 90%)' }}>
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

      <Container maxWidth="xl" sx={{ py: 4 }}>
        
        {/* En-tête moderne */}
        <Paper 
          sx={{ 
            p: 4, 
            mb: 4, 
            background: 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)',
            color: 'white',
            borderRadius: 3
          }}
        >
          <Grid container alignItems="center" spacing={3}>
            <Grid item xs={12} md={8}>
              <Typography variant="h3" gutterBottom fontWeight="bold">
                Découvrez Nos Concours
              </Typography>
              <Typography variant="h6" sx={{ opacity: 0.9 }}>
                {concours.length} concours disponibles • {concours.filter(isConcoursOpen).length} actuellement ouverts
              </Typography>
            </Grid>
            <Grid item xs={12} md={4} textAlign="center">
              <Avatar 
                sx={{ 
                  width: 80, 
                  height: 80, 
                  bgcolor: 'rgba(255,255,255,0.2)',
                  mx: 'auto' 
                }}
              >
                <WorkIcon sx={{ fontSize: 40 }} />
              </Avatar>
            </Grid>
          </Grid>
        </Paper>

        {/* Filtres avancés */}
        <Paper sx={{ p: 3, mb: 4, borderRadius: 2 }}>
          <Typography variant="h6" gutterBottom sx={{ display: 'flex', alignItems: 'center' }}>
            <FilterIcon sx={{ mr: 1 }} />
            Filtres de Recherche
          </Typography>
          
          <Grid container spacing={3}>
            <Grid item xs={12} md={3}>
              <TextField
                fullWidth
                label="Rechercher"
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
                placeholder="Nom du concours..."
                InputProps={{
                  startAdornment: (
                    <InputAdornment position="start">
                      <SearchIcon />
                    </InputAdornment>
                  ),
                }}
              />
            </Grid>
            <Grid item xs={12} md={2}>
              <FormControl fullWidth>
                <InputLabel>Concours</InputLabel>
                <Select
                  value={selectedConcours}
                  label="Concours"
                  onChange={(e) => setSelectedConcours(e.target.value)}
                >
                  <MenuItem value="">Tous</MenuItem>
                  {concours.map((c) => (
                    <MenuItem key={c.id} value={c.id}>
                      {c.nom}
                    </MenuItem>
                  ))}
                </Select>
              </FormControl>
            </Grid>
            <Grid item xs={12} md={2}>
              <FormControl fullWidth>
                <InputLabel>Centre</InputLabel>
                <Select
                  value={selectedCentre}
                  label="Centre"
                  onChange={(e) => setSelectedCentre(e.target.value)}
                >
                  <MenuItem value="">Tous</MenuItem>
                  {centres.map((c) => (
                    <MenuItem key={c.id} value={c.id}>
                      {c.nom} - {c.ville}
                    </MenuItem>
                  ))}
                </Select>
              </FormControl>
            </Grid>
            <Grid item xs={12} md={2}>
              <FormControl fullWidth>
                <InputLabel>Spécialité</InputLabel>
                <Select
                  value={selectedSpecialite}
                  label="Spécialité"
                  onChange={(e) => setSelectedSpecialite(e.target.value)}
                >
                  <MenuItem value="">Toutes</MenuItem>
                  {specialites.map((s) => (
                    <MenuItem key={s.id} value={s.id}>
                      {s.nom}
                    </MenuItem>
                  ))}
                </Select>
              </FormControl>
            </Grid>
            <Grid item xs={12} md={3}>
              <Button
                variant="outlined"
                startIcon={<ClearIcon />}
                onClick={clearFilters}
                fullWidth
                sx={{ height: '56px' }}
              >
                Effacer les filtres
              </Button>
            </Grid>
          </Grid>
        </Paper>

        {error && (
          <Alert severity="error" sx={{ mb: 3 }}>
            {error}
          </Alert>
        )}

        {/* Liste des concours avec design moderne */}
        <Typography variant="h5" gutterBottom sx={{ mb: 3, fontWeight: 'bold' }}>
          <AssignmentIcon sx={{ mr: 1, verticalAlign: 'middle' }} />
          Concours Disponibles ({getFilteredConcours().length})
        </Typography>

        {getFilteredConcours().length === 0 ? (
          <Paper sx={{ p: 4, textAlign: 'center' }}>
            <Typography variant="h6" color="text.secondary" gutterBottom>
              Aucun concours trouvé
            </Typography>
            <Typography variant="body2" color="text.secondary">
              Modifiez vos critères de recherche ou revenez plus tard
            </Typography>
          </Paper>
        ) : (
          <Grid container spacing={3}>
            {getFilteredConcours().map((concour) => {
              const isOpen = isConcoursOpen(concour);
              const daysRemaining = getDaysRemaining(concour.dateFinCandidature);
              
              return (
                <Grid item xs={12} md={6} lg={4} key={concour.id}>
                  <Card 
                    sx={{ 
                      height: '100%', 
                      display: 'flex', 
                      flexDirection: 'column',
                      opacity: isOpen ? 1 : 0.7,
                      borderRadius: 2,
                      boxShadow: isOpen ? 3 : 1,
                      transition: 'all 0.3s ease',
                      border: isOpen ? '2px solid #4caf50' : '1px solid #e0e0e0',
                      '&:hover': isOpen ? {
                        transform: 'translateY(-4px)',
                        boxShadow: 6
                      } : {}
                    }}
                  >
                    {/* Header coloré */}
                    <Box
                      sx={{
                        background: isOpen 
                          ? 'linear-gradient(45deg, #4caf50 30%, #81c784 90%)'
                          : 'linear-gradient(45deg, #9e9e9e 30%, #bdbdbd 90%)',
                        color: 'white',
                        p: 2
                      }}
                    >
                      <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                        <Typography variant="h6" fontWeight="bold">
                          {concour.nom}
                        </Typography>
                        <Chip
                          label={isOpen ? 'Ouvert' : 'Fermé'}
                          size="small"
                          sx={{
                            bgcolor: 'rgba(255,255,255,0.2)',
                            color: 'white',
                            fontWeight: 'bold'
                          }}
                        />
                      </Box>
                      
                      {isOpen && daysRemaining <= 7 && (
                        <Chip
                          icon={<TimerIcon />}
                          label={`${daysRemaining} jour${daysRemaining > 1 ? 's' : ''} restant${daysRemaining > 1 ? 's' : ''}`}
                          size="small"
                          color="warning"
                          sx={{ mt: 1 }}
                        />
                      )}
                    </Box>

                    <CardContent sx={{ flexGrow: 1, p: 3 }}>
                      <Typography variant="body2" color="text.secondary" paragraph>
                        {concour.description}
                      </Typography>

                      {/* Informations importantes */}
                      <Box sx={{ mb: 2 }}>
                        <Box sx={{ display: 'flex', alignItems: 'center', mb: 1 }}>
                          <DateRangeIcon sx={{ mr: 1, fontSize: 18, color: 'text.secondary' }} />
                          <Typography variant="body2">
                            <strong>Date limite:</strong> {formatDate(concour.dateFinCandidature)}
                          </Typography>
                        </Box>
                        
                        {concour.dateExamen && (
                          <Box sx={{ display: 'flex', alignItems: 'center', mb: 1 }}>
                            <AccessTimeIcon sx={{ mr: 1, fontSize: 18, color: 'text.secondary' }} />
                            <Typography variant="body2">
                              <strong>Examen:</strong> {formatDate(concour.dateExamen)}
                            </Typography>
                          </Box>
                        )}

                        <Box sx={{ display: 'flex', alignItems: 'center', mb: 2 }}>
                          <PeopleIcon sx={{ mr: 1, fontSize: 18, color: 'text.secondary' }} />
                          <Typography variant="body2" color="success.main">
                            <strong>Places disponibles</strong>
                          </Typography>
                        </Box>
                      </Box>

                      {/* Spécialités */}
                      {concour.specialites && concour.specialites.length > 0 && (
                        <Box sx={{ mb: 2 }}>
                          <Typography variant="body2" color="text.secondary" gutterBottom>
                            <SchoolIcon sx={{ mr: 0.5, fontSize: 16, verticalAlign: 'middle' }} />
                            Spécialités:
                          </Typography>
                          <Box sx={{ display: 'flex', flexWrap: 'wrap', gap: 0.5 }}>
                            {concour.specialites.slice(0, 3).map((specialite) => (
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
                                label={`+${concour.specialites.length - 3}`}
                                size="small"
                                variant="outlined"
                                color="secondary"
                              />
                            )}
                          </Box>
                        </Box>
                      )}

                      {/* Centres */}
                      {concour.centres && concour.centres.length > 0 && (
                        <Box>
                          <Typography variant="body2" color="text.secondary" gutterBottom>
                            <LocationOnIcon sx={{ mr: 0.5, fontSize: 16, verticalAlign: 'middle' }} />
                            Centres:
                          </Typography>
                          <Box sx={{ display: 'flex', flexWrap: 'wrap', gap: 0.5 }}>
                            {concour.centres.slice(0, 2).map((centre) => (
                              <Chip
                                key={centre.id}
                                label={centre.ville}
                                size="small"
                                variant="outlined"
                              />
                            ))}
                            {concour.centres.length > 2 && (
                              <Chip
                                label={`+${concour.centres.length - 2}`}
                                size="small"
                                variant="outlined"
                              />
                            )}
                          </Box>
                        </Box>
                      )}
                    </CardContent>

                    <CardActions sx={{ p: 2, pt: 0, flexDirection: 'column', gap: 1 }}>
                      <Box sx={{ display: 'flex', width: '100%', gap: 1 }}>
                        <Button
                          variant="outlined"
                          size="small"
                          onClick={() => handleVoirDetails(concour)}
                          startIcon={<InfoIcon />}
                          sx={{ flex: 1 }}
                        >
                          Détails
                        </Button>
                        {concour.ficheConcoursUrl && (
                          <Button
                            variant="outlined"
                            size="small"
                            color="secondary"
                            onClick={() => handleTelechargerFiche(concour.ficheConcoursUrl)}
                            startIcon={<DownloadIcon />}
                            sx={{ flex: 1 }}
                          >
                            Fiche
                          </Button>
                        )}
                      </Box>
                      
                      <Button
                        variant="contained"
                        fullWidth
                        size="large"
                        onClick={() => handleCandidater(concour)}
                        disabled={!isOpen}
                        startIcon={<PersonAddIcon />}
                        sx={{
                          bgcolor: isOpen ? 'primary.main' : 'grey.400',
                          fontWeight: 'bold',
                          py: 1.5
                        }}
                      >
                        {isOpen ? 'Candidater Maintenant' : 'Candidatures Fermées'}
                      </Button>
                    </CardActions>
                  </Card>
                </Grid>
              );
            })}
          </Grid>
        )}

        {/* Dialog de détails */}
        <Dialog
          open={!!detailDialog}
          onClose={() => setDetailDialog(null)}
          maxWidth="md"
          fullWidth
        >
          {detailDialog && (
            <>
              <DialogTitle sx={{ 
                background: 'linear-gradient(45deg, #1976d2 30%, #42a5f5 90%)',
                color: 'white',
                fontSize: '1.5rem'
              }}>
                {detailDialog.nom}
              </DialogTitle>
              <DialogContent sx={{ p: 3 }}>
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
                  {centres.map((centre) => (
                    <Grid item xs={12} md={6} key={centre.id}>
                      <Card variant="outlined" sx={{ p: 2 }}>
                        <Typography variant="subtitle2">{centre.nom}</Typography>
                        <Typography variant="body2" color="text.secondary">
                          {centre.ville} - {centre.adresse}
                        </Typography>
                      </Card>
                    </Grid>
                  ))}
                </Grid>
              </DialogContent>
              <DialogActions sx={{ p: 3 }}>
                <Button onClick={() => setDetailDialog(null)}>
                  Fermer
                </Button>
                {detailDialog.ficheConcoursUrl && (
                  <Button
                    variant="outlined"
                    onClick={() => handleTelechargerFiche(detailDialog.ficheConcoursUrl)}
                    startIcon={<DownloadIcon />}
                  >
                    Télécharger la fiche
                  </Button>
                )}
                <Button
                  variant="contained"
                  onClick={() => {
                    setDetailDialog(null);
                    handleCandidater(detailDialog);
                  }}
                  disabled={!isConcoursOpen(detailDialog)}
                  startIcon={<PersonAddIcon />}
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

export default PostesPageModerne;
