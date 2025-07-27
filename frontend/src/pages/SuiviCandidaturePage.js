import React, { useState, useEffect } from 'react';
import {
  Container,
  Typography,
  Button,
  Box,
  Paper,
  TextField,
  AppBar,
  Toolbar,
  Alert,
  CircularProgress,
  Chip,
  Grid,
  Card,
  CardContent,
  Divider
} from '@mui/material';
import { useNavigate, useLocation } from 'react-router-dom';
import axios from 'axios';
import {
  Search as SearchIcon,
  Home as HomeIcon,
  CheckCircle as CheckCircleIcon,
  Cancel as CancelIcon,
  HourglassEmpty as HourglassEmptyIcon,
  Assignment as AssignmentIcon,
  Email as EmailIcon,
  Phone as PhoneIcon,
  School as SchoolIcon,
  LocationOn as LocationOnIcon
} from '@mui/icons-material';

const SuiviCandidaturePage = () => {
  const navigate = useNavigate();
  const location = useLocation();
  const [numeroUnique, setNumeroUnique] = useState(location.state?.numeroUnique || '');
  const [candidature, setCandidature] = useState(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');

  const handleSearch = async () => {
    if (!numeroUnique.trim()) {
      setError('Veuillez saisir un numéro de candidature');
      return;
    }

    setLoading(true);
    setError('');
    setCandidature(null);

    try {
      const response = await axios.get(`http://localhost:8080/api/candidatures/suivi/${numeroUnique}`);
      setCandidature(response.data);
    } catch (err) {
      if (err.response?.status === 404) {
        setError('Aucune candidature trouvée avec ce numéro');
      } else {
        setError('Erreur lors de la recherche');
      }
    } finally {
      setLoading(false);
    }
  };

  // Auto-search si un numéro est fourni
  useEffect(() => {
    if (numeroUnique) {
      handleSearch();
    }
  }, []);

  const getStatusColor = (etat) => {
    switch (etat) {
      case 'Soumise':
        return 'info';
      case 'En_Cours_Validation':
        return 'warning';
      case 'Validee':
        return 'success';
      case 'Rejetee':
        return 'error';
      case 'Confirmee':
        return 'success';
      default:
        return 'default';
    }
  };

  const getStatusIcon = (etat) => {
    switch (etat) {
      case 'Soumise':
        return <AssignmentIcon />;
      case 'En_Cours_Validation':
        return <HourglassEmptyIcon />;
      case 'Validee':
      case 'Confirmee':
        return <CheckCircleIcon />;
      case 'Rejetee':
        return <CancelIcon />;
      default:
        return <AssignmentIcon />;
    }
  };

  const formatEtat = (etat) => {
    const etats = {
      'Soumise': 'Soumise',
      'En_Cours_Validation': 'En cours de validation',
      'Validee': 'Validée',
      'Rejetee': 'Rejetée',
      'Confirmee': 'Confirmée'
    };
    return etats[etat] || etat;
  };

  const formatDate = (dateString) => {
    return new Date(dateString).toLocaleDateString('fr-FR', {
      year: 'numeric',
      month: 'long',
      day: 'numeric',
      hour: '2-digit',
      minute: '2-digit'
    });
  };

  return (
    <>
      <AppBar position="static">
        <Toolbar>
          <SearchIcon sx={{ mr: 2 }} />
          <Typography variant="h6" component="div" sx={{ flexGrow: 1 }}>
            Suivi de Candidature
          </Typography>
          <Button color="inherit" onClick={() => navigate('/')} startIcon={<HomeIcon />}>
            Accueil
          </Button>
        </Toolbar>
      </AppBar>

      <Container maxWidth="lg" sx={{ mt: 4, mb: 4 }}>
        <Paper sx={{ p: 4, mb: 4 }}>
          <Typography variant="h4" component="h1" gutterBottom>
            Rechercher votre candidature
          </Typography>
          <Typography variant="body1" color="text.secondary" sx={{ mb: 3 }}>
            Saisissez votre numéro unique de candidature pour consulter son état
          </Typography>

          <Box sx={{ display: 'flex', gap: 2, mb: 3 }}>
            <TextField
              fullWidth
              label="Numéro unique de candidature"
              variant="outlined"
              value={numeroUnique}
              onChange={(e) => setNumeroUnique(e.target.value)}
              placeholder="Ex: CAND-2025-001234"
              onKeyPress={(e) => {
                if (e.key === 'Enter') {
                  handleSearch();
                }
              }}
            />
            <Button
              variant="contained"
              onClick={handleSearch}
              disabled={loading}
              startIcon={loading ? <CircularProgress size={20} /> : <SearchIcon />}
              sx={{ minWidth: 120 }}
            >
              Rechercher
            </Button>
          </Box>

          {error && (
            <Alert severity="error" sx={{ mb: 3 }}>
              {error}
            </Alert>
          )}
        </Paper>

        {candidature && (
          <Grid container spacing={3}>
            {/* Informations principales */}
            <Grid item xs={12} md={8}>
              <Paper sx={{ p: 3, mb: 3 }}>
                <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 3 }}>
                  <Typography variant="h5" component="h2">
                    Candidature #{candidature.candidat.numeroUnique}
                  </Typography>
                  <Chip
                    icon={getStatusIcon(candidature.etat)}
                    label={formatEtat(candidature.etat)}
                    color={getStatusColor(candidature.etat)}
                    variant="outlined"
                    size="large"
                  />
                </Box>

                <Grid container spacing={2}>
                  <Grid item xs={12} md={6}>
                    <Typography variant="subtitle1" gutterBottom>
                      <strong>Candidat :</strong>
                    </Typography>
                    <Typography>
                      {candidature.candidat.prenom} {candidature.candidat.nom}
                    </Typography>
                    <Typography color="text.secondary" sx={{ display: 'flex', alignItems: 'center', mt: 1 }}>
                      <EmailIcon sx={{ mr: 1, fontSize: 16 }} />
                      {candidature.candidat.email}
                    </Typography>
                    <Typography color="text.secondary" sx={{ display: 'flex', alignItems: 'center' }}>
                      <PhoneIcon sx={{ mr: 1, fontSize: 16 }} />
                      {candidature.candidat.telephone}
                    </Typography>
                  </Grid>

                  <Grid item xs={12} md={6}>
                    <Typography variant="subtitle1" gutterBottom>
                      <strong>Concours :</strong>
                    </Typography>
                    <Typography>{candidature.concours.nom}</Typography>
                    <Typography color="text.secondary" sx={{ display: 'flex', alignItems: 'center', mt: 1 }}>
                      <SchoolIcon sx={{ mr: 1, fontSize: 16 }} />
                      {candidature.specialite.nom}
                    </Typography>
                    <Typography color="text.secondary" sx={{ display: 'flex', alignItems: 'center' }}>
                      <LocationOnIcon sx={{ mr: 1, fontSize: 16 }} />
                      {candidature.centre.nom} - {candidature.centre.ville}
                    </Typography>
                  </Grid>
                </Grid>

                <Divider sx={{ my: 3 }} />

                <Typography variant="subtitle1" gutterBottom>
                  <strong>Formation :</strong>
                </Typography>
                <Typography>
                  {candidature.candidat.diplomePrincipal} - {candidature.candidat.specialiteDiplome}
                </Typography>
                <Typography color="text.secondary">
                  {candidature.candidat.etablissement} ({candidature.candidat.anneeObtention})
                </Typography>

                {candidature.motifRejet && (
                  <>
                    <Divider sx={{ my: 3 }} />
                    <Alert severity="error">
                      <Typography variant="subtitle2" gutterBottom>
                        Motif du rejet :
                      </Typography>
                      <Typography>{candidature.motifRejet}</Typography>
                    </Alert>
                  </>
                )}

                {candidature.commentaireGestionnaire && (
                  <>
                    <Divider sx={{ my: 3 }} />
                    <Alert severity="info">
                      <Typography variant="subtitle2" gutterBottom>
                        Commentaire du gestionnaire :
                      </Typography>
                      <Typography>{candidature.commentaireGestionnaire}</Typography>
                    </Alert>
                  </>
                )}
              </Paper>
            </Grid>

            {/* Timeline des événements */}
            <Grid item xs={12} md={4}>
              <Paper sx={{ p: 3 }}>
                <Typography variant="h6" gutterBottom>
                  Historique
                </Typography>
                
                <Box>
                  <Box sx={{ display: 'flex', alignItems: 'center', mb: 2 }}>
                    <AssignmentIcon color="primary" sx={{ mr: 2 }} />
                    <Box>
                      <Typography variant="body2">
                        Candidature soumise
                      </Typography>
                      <Typography variant="caption" color="text.secondary">
                        {formatDate(candidature.dateSoumission)}
                      </Typography>
                    </Box>
                  </Box>

                  {candidature.dateTraitement && (
                    <Box sx={{ display: 'flex', alignItems: 'center', mb: 2 }}>
                      {getStatusIcon(candidature.etat)}
                      <Box sx={{ ml: 2 }}>
                        <Typography variant="body2">
                          {formatEtat(candidature.etat)}
                          {candidature.gestionnaire && (
                            <Typography variant="caption" color="text.secondary" display="block">
                              par {candidature.gestionnaire.prenom} {candidature.gestionnaire.nom}
                            </Typography>
                          )}
                        </Typography>
                        <Typography variant="caption" color="text.secondary">
                          {formatDate(candidature.dateTraitement)}
                        </Typography>
                      </Box>
                    </Box>
                  )}

                  {candidature.etat === 'Validee' && (
                    <Box sx={{ display: 'flex', alignItems: 'center', mb: 2 }}>
                      <SchoolIcon color="action" sx={{ mr: 2 }} />
                      <Box>
                        <Typography variant="body2">
                          Convocation à l'examen
                          {candidature.concours.dateExamen && (
                            <Typography variant="caption" color="text.secondary" display="block">
                              Prévue le {new Date(candidature.concours.dateExamen).toLocaleDateString('fr-FR')}
                            </Typography>
                          )}
                        </Typography>
                        <Typography variant="caption" color="text.secondary">
                          À venir
                        </Typography>
                      </Box>
                    </Box>
                  )}
                </Box>
              </Paper>

              {/* Informations supplémentaires */}
              <Card sx={{ mt: 2 }}>
                <CardContent>
                  <Typography variant="h6" gutterBottom>
                    Informations utiles
                  </Typography>
                  
                  {candidature.numeroPlace && (
                    <Typography variant="body2" sx={{ mb: 1 }}>
                      <strong>Numéro de place :</strong> {candidature.numeroPlace}
                    </Typography>
                  )}
                  
                  <Typography variant="body2" sx={{ mb: 1 }}>
                    <strong>Centre d'examen :</strong><br />
                    {candidature.centre.nom}<br />
                    {candidature.centre.adresse}<br />
                    {candidature.centre.ville}
                  </Typography>
                  
                  {candidature.centre.telephone && (
                    <Typography variant="body2" sx={{ mb: 1 }}>
                      <strong>Contact centre :</strong><br />
                      {candidature.centre.telephone}
                    </Typography>
                  )}
                  
                  {candidature.concours.dateExamen && (
                    <Typography variant="body2">
                      <strong>Date d'examen :</strong><br />
                      {new Date(candidature.concours.dateExamen).toLocaleDateString('fr-FR')}
                    </Typography>
                  )}
                </CardContent>
              </Card>
            </Grid>
          </Grid>
        )}

        {/* Actions rapides */}
        <Box sx={{ mt: 4, textAlign: 'center' }}>
          <Button
            variant="outlined"
            onClick={() => navigate('/candidature')}
            sx={{ mr: 2 }}
          >
            Nouvelle candidature
          </Button>
          <Button
            variant="outlined"
            onClick={() => navigate('/postes')}
          >
            Voir les postes disponibles
          </Button>
        </Box>
      </Container>
    </>
  );
};

export default SuiviCandidaturePage;
