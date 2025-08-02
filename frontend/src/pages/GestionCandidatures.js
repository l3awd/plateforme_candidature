import React, { useState, useEffect } from 'react';
import {
  Container,
  Typography,
  Paper,
  Box,
  AppBar,
  Toolbar,
  Button,
  Table,
  TableBody,
  TableCell,
  TableContainer,
  TableHead,
  TableRow,
  Chip,
  Alert,
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  TextField,
  FormControl,
  InputLabel,
  Select,
  MenuItem,
  CircularProgress,
  Grid,
  Card,
  CardContent
} from '@mui/material';
import {
  ExitToApp as LogoutIcon,
  CheckCircle as ValidateIcon,
  Cancel as RejectIcon,
  FilterList as FilterIcon,
  Refresh as RefreshIcon
} from '@mui/icons-material';
import { useNavigate } from 'react-router-dom';
import axios from 'axios';

const GestionCandidatures = () => {
  const navigate = useNavigate();
  const [candidatures, setCandidatures] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [success, setSuccess] = useState('');
  
  // Filtres
  const [filtreEtat, setFiltreEtat] = useState('Soumise');
  const [filtreConcours, setFiltreConcours] = useState('');
  const [concours, setConcours] = useState([]);
  
  // Dialog de rejet
  const [openRejetDialog, setOpenRejetDialog] = useState(false);
  const [candidatureSelectionnee, setCandidatureSelectionnee] = useState(null);
  const [motifRejet, setMotifRejet] = useState('');
  
  // Informations utilisateur
  const userRole = localStorage.getItem('userRole');
  const userName = localStorage.getItem('userName');
  const userId = localStorage.getItem('userId');
  const centreId = localStorage.getItem('centreId');
  const centreNom = localStorage.getItem('centreNom');

  useEffect(() => {
    if (!userId) {
      navigate('/login');
      return;
    }
    chargerDonnees();
  }, [filtreEtat, filtreConcours]);

  const chargerDonnees = async () => {
    setLoading(true);
    setError('');
    
    try {
      // Charger les concours
      const concoursRes = await axios.get('http://localhost:8080/api/concours');
      setConcours(concoursRes.data || []);
      
      // Charger les candidatures selon le rôle
      let candidaturesRes;
      if (userRole === 'GestionnaireLocal' && centreId) {
        if (filtreEtat) {
          candidaturesRes = await axios.get(`http://localhost:8080/api/candidatures/centre/${centreId}/etat/${filtreEtat}`);
        } else {
          candidaturesRes = await axios.get(`http://localhost:8080/api/candidatures/centre/${centreId}`);
        }
      } else {
        // Pour gestionnaires globaux et administrateurs
        candidaturesRes = await axios.get('http://localhost:8080/api/candidatures');
      }
      
      let candidaturesData = candidaturesRes.data || [];
      
      // Filtrer par concours si nécessaire
      if (filtreConcours) {
        candidaturesData = candidaturesData.filter(c => c.concours.id === parseInt(filtreConcours));
      }
      
      setCandidatures(candidaturesData);
    } catch (err) {
      console.error('Erreur chargement:', err);
      setError('Erreur lors du chargement des données');
    } finally {
      setLoading(false);
    }
  };

  const handleValider = async (candidatureId) => {
    try {
      setError('');
      setSuccess('');
      
      await axios.post(`http://localhost:8080/api/candidatures/${candidatureId}/valider`, null, {
        params: { gestionnaireId: userId }
      });
      
      setSuccess('Candidature validée avec succès');
      chargerDonnees();
    } catch (err) {
      console.error('Erreur validation:', err);
      setError(err.response?.data?.message || 'Erreur lors de la validation');
    }
  };

  const handleRejeter = async () => {
    if (!motifRejet.trim()) {
      setError('Le motif de rejet est obligatoire');
      return;
    }
    
    try {
      setError('');
      setSuccess('');
      
      await axios.post(`http://localhost:8080/api/candidatures/${candidatureSelectionnee.id}/rejeter`, null, {
        params: { 
          motif: motifRejet,
          gestionnaireId: userId 
        }
      });
      
      setSuccess('Candidature rejetée avec succès');
      setOpenRejetDialog(false);
      setMotifRejet('');
      setCandidatureSelectionnee(null);
      chargerDonnees();
    } catch (err) {
      console.error('Erreur rejet:', err);
      setError(err.response?.data?.message || 'Erreur lors du rejet');
    }
  };

  const ouvrirRejetDialog = (candidature) => {
    setCandidatureSelectionnee(candidature);
    setOpenRejetDialog(true);
  };

  const fermerRejetDialog = () => {
    setOpenRejetDialog(false);
    setMotifRejet('');
    setCandidatureSelectionnee(null);
  };

  const handleLogout = () => {
    localStorage.clear();
    navigate('/');
  };

  const getEtatColor = (etat) => {
    switch (etat) {
      case 'Soumise': return 'info';
      case 'En_Cours_Validation': return 'warning';
      case 'Validee': return 'success';
      case 'Rejetee': return 'error';
      case 'Confirmee': return 'primary';
      default: return 'default';
    }
  };

  const formatEtat = (etat) => {
    switch (etat) {
      case 'Soumise': return 'Soumise';
      case 'En_Cours_Validation': return 'En cours';
      case 'Validee': return 'Validée';
      case 'Rejetee': return 'Rejetée';
      case 'Confirmee': return 'Confirmée';
      default: return etat;
    }
  };

  if (loading) {
    return (
      <Box display="flex" justifyContent="center" alignItems="center" minHeight="100vh">
        <CircularProgress />
      </Box>
    );
  }

  return (
    <>
      <AppBar position="static">
        <Toolbar>
          <Typography variant="h6" component="div" sx={{ flexGrow: 1 }}>
            Gestion des Candidatures - {userRole}
          </Typography>
          <Typography variant="body2" sx={{ mr: 2 }}>
            {userName} {centreNom && `(${centreNom})`}
          </Typography>
          <Button color="inherit" onClick={handleLogout} startIcon={<LogoutIcon />}>
            Déconnexion
          </Button>
        </Toolbar>
      </AppBar>

      <Container maxWidth="xl" sx={{ mt: 4, mb: 4 }}>
        {/* Statistiques rapides */}
        <Grid container spacing={3} sx={{ mb: 4 }}>
          <Grid item xs={12} sm={6} md={3}>
            <Card>
              <CardContent>
                <Typography color="textSecondary" gutterBottom>
                  Total Candidatures
                </Typography>
                <Typography variant="h4">
                  {candidatures.length}
                </Typography>
              </CardContent>
            </Card>
          </Grid>
          <Grid item xs={12} sm={6} md={3}>
            <Card>
              <CardContent>
                <Typography color="textSecondary" gutterBottom>
                  En Attente
                </Typography>
                <Typography variant="h4">
                  {candidatures.filter(c => c.etat === 'Soumise').length}
                </Typography>
              </CardContent>
            </Card>
          </Grid>
          <Grid item xs={12} sm={6} md={3}>
            <Card>
              <CardContent>
                <Typography color="textSecondary" gutterBottom>
                  Validées
                </Typography>
                <Typography variant="h4">
                  {candidatures.filter(c => c.etat === 'Validee').length}
                </Typography>
              </CardContent>
            </Card>
          </Grid>
          <Grid item xs={12} sm={6} md={3}>
            <Card>
              <CardContent>
                <Typography color="textSecondary" gutterBottom>
                  Rejetées
                </Typography>
                <Typography variant="h4">
                  {candidatures.filter(c => c.etat === 'Rejetee').length}
                </Typography>
              </CardContent>
            </Card>
          </Grid>
        </Grid>

        {error && (
          <Alert severity="error" sx={{ mb: 3 }}>
            {error}
          </Alert>
        )}

        {success && (
          <Alert severity="success" sx={{ mb: 3 }}>
            {success}
          </Alert>
        )}

        {/* Filtres */}
        <Paper sx={{ p: 3, mb: 3 }}>
          <Typography variant="h6" gutterBottom>
            <FilterIcon sx={{ mr: 1, verticalAlign: 'middle' }} />
            Filtres
          </Typography>
          <Grid container spacing={2} alignItems="center">
            <Grid item xs={12} sm={6} md={3}>
              <FormControl fullWidth>
                <InputLabel>État</InputLabel>
                <Select
                  value={filtreEtat}
                  label="État"
                  onChange={(e) => setFiltreEtat(e.target.value)}
                >
                  <MenuItem value="">Tous</MenuItem>
                  <MenuItem value="Soumise">Soumise</MenuItem>
                  <MenuItem value="En_Cours_Validation">En cours</MenuItem>
                  <MenuItem value="Validee">Validée</MenuItem>
                  <MenuItem value="Rejetee">Rejetée</MenuItem>
                </Select>
              </FormControl>
            </Grid>
            <Grid item xs={12} sm={6} md={3}>
              <FormControl fullWidth>
                <InputLabel>Concours</InputLabel>
                <Select
                  value={filtreConcours}
                  label="Concours"
                  onChange={(e) => setFiltreConcours(e.target.value)}
                >
                  <MenuItem value="">Tous</MenuItem>
                  {concours.map((c) => (
                    <MenuItem key={c.id} value={c.id}>{c.nom}</MenuItem>
                  ))}
                </Select>
              </FormControl>
            </Grid>
            <Grid item xs={12} sm={6} md={3}>
              <Button
                variant="outlined"
                startIcon={<RefreshIcon />}
                onClick={chargerDonnees}
                fullWidth
              >
                Actualiser
              </Button>
            </Grid>
          </Grid>
        </Paper>

        {/* Table des candidatures */}
        <Paper>
          <TableContainer>
            <Table>
              <TableHead>
                <TableRow>
                  <TableCell>Candidat</TableCell>
                  <TableCell>CIN</TableCell>
                  <TableCell>Concours</TableCell>
                  <TableCell>Spécialité</TableCell>
                  <TableCell>Centre</TableCell>
                  <TableCell>État</TableCell>
                  <TableCell>Date Soumission</TableCell>
                  <TableCell>Actions</TableCell>
                </TableRow>
              </TableHead>
              <TableBody>
                {candidatures.map((candidature) => (
                  <TableRow key={candidature.id}>
                    <TableCell>
                      <Typography variant="body2" fontWeight="bold">
                        {candidature.candidat.prenom} {candidature.candidat.nom}
                      </Typography>
                      <Typography variant="caption" color="text.secondary">
                        {candidature.candidat.email}
                      </Typography>
                    </TableCell>
                    <TableCell>{candidature.candidat.cin}</TableCell>
                    <TableCell>{candidature.concours.nom}</TableCell>
                    <TableCell>{candidature.specialite.nom}</TableCell>
                    <TableCell>{candidature.centre.nom}</TableCell>
                    <TableCell>
                      <Chip 
                        label={formatEtat(candidature.etat)}
                        color={getEtatColor(candidature.etat)}
                        size="small"
                      />
                    </TableCell>
                    <TableCell>
                      {new Date(candidature.dateSoumission).toLocaleDateString('fr-FR')}
                    </TableCell>
                    <TableCell>
                      {candidature.etat === 'Soumise' && (
                        <>
                          <Button
                            size="small"
                            variant="contained"
                            color="success"
                            startIcon={<ValidateIcon />}
                            onClick={() => handleValider(candidature.id)}
                            sx={{ mr: 1, mb: 1 }}
                          >
                            Valider
                          </Button>
                          <Button
                            size="small"
                            variant="contained"
                            color="error"
                            startIcon={<RejectIcon />}
                            onClick={() => ouvrirRejetDialog(candidature)}
                          >
                            Rejeter
                          </Button>
                        </>
                      )}
                      {candidature.etat === 'Rejetee' && candidature.motifRejet && (
                        <Typography variant="caption" color="error">
                          Motif: {candidature.motifRejet}
                        </Typography>
                      )}
                    </TableCell>
                  </TableRow>
                ))}
              </TableBody>
            </Table>
          </TableContainer>
          
          {candidatures.length === 0 && (
            <Box p={4} textAlign="center">
              <Typography color="text.secondary">
                Aucune candidature trouvée avec les filtres sélectionnés
              </Typography>
            </Box>
          )}
        </Paper>
      </Container>

      {/* Dialog de rejet */}
      <Dialog open={openRejetDialog} onClose={fermerRejetDialog} maxWidth="sm" fullWidth>
        <DialogTitle>Rejeter la candidature</DialogTitle>
        <DialogContent>
          <Typography variant="body2" sx={{ mb: 2 }}>
            Candidat: {candidatureSelectionnee?.candidat?.prenom} {candidatureSelectionnee?.candidat?.nom}
          </Typography>
          <TextField
            fullWidth
            multiline
            rows={4}
            label="Motif du rejet *"
            value={motifRejet}
            onChange={(e) => setMotifRejet(e.target.value)}
            placeholder="Veuillez préciser le motif du rejet..."
          />
        </DialogContent>
        <DialogActions>
          <Button onClick={fermerRejetDialog}>Annuler</Button>
          <Button 
            onClick={handleRejeter}
            variant="contained"
            color="error"
            disabled={!motifRejet.trim()}
          >
            Confirmer le rejet
          </Button>
        </DialogActions>
      </Dialog>
    </>
  );
};

export default GestionCandidatures;
