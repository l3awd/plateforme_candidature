import React, { useState, useEffect } from 'react';
import {
  Box, Container, Typography, Paper, Grid, Card, CardContent,
  Table, TableBody, TableCell, TableContainer, TableHead, TableRow,
  Button, Chip, Dialog, DialogTitle, DialogContent, DialogActions,
  TextField, FormControl, InputLabel, Select, MenuItem,
  Alert, CircularProgress, Pagination, IconButton, Tooltip,
  Avatar, Divider, List, ListItem, ListItemText, ListItemIcon,
  TablePagination, InputAdornment, Fab, Badge
} from '@mui/material';
import {
  Visibility as ViewIcon,
  GetApp as DownloadIcon,
  Filter as FilterIcon,
  Refresh as RefreshIcon,
  Assessment as StatsIcon,
  People as PeopleIcon,
  Assignment as AssignmentIcon,
  TrendingUp as TrendingUpIcon,
  Search as SearchIcon,
  Clear as ClearIcon,
  Email as EmailIcon,
  Phone as PhoneIcon,
  LocationOn as LocationIcon,
  School as SchoolIcon,
  Work as WorkIcon,
  Check as CheckIcon,
  Close as CloseIcon,
  HourglassBottom as HourglassIcon
} from '@mui/icons-material';
import { PieChart, Pie, Cell, BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip as RechartsTooltip, Legend, ResponsiveContainer } from 'recharts';
import axios from 'axios';

const GestionCandidaturesComplete = () => {
  const [loading, setLoading] = useState(false);
  const [candidatures, setCandidatures] = useState([]);
  const [statistics, setStatistics] = useState({});
  const [filteredCandidatures, setFilteredCandidatures] = useState([]);
  const [selectedCandidature, setSelectedCandidature] = useState(null);
  const [openDetails, setOpenDetails] = useState(false);
  const [openStats, setOpenStats] = useState(false);
  const [rejetDialogOpen, setRejetDialogOpen] = useState(false);
  const [rejetMotif, setRejetMotif] = useState("");
  const [candidatureAction, setCandidatureAction] = useState(null); // candidature ciblée pour action
  
  // Filtres
  const [filters, setFilters] = useState({
    searchTerm: '',
    concours: '',
    specialite: '',
    centre: '',
    statut: ''
  });
  
  // Données de référence
  const [concours, setConcours] = useState([]);
  const [specialites, setSpecialites] = useState([]);
  const [centres, setCentres] = useState([]);
  
  // Pagination
  const [page, setPage] = useState(0);
  const [rowsPerPage, setRowsPerPage] = useState(10);
  
  // Couleurs pour les graphiques
  const COLORS = ['#0088FE', '#00C49F', '#FFBB28', '#FF8042', '#8884D8'];

  useEffect(() => {
    loadInitialData();
  }, []);

  useEffect(() => {
    applyFilters();
  }, [candidatures, filters]);

  // Définition des statuts (backend enums)
  const STATUTS = [
    { value: 'Soumise', label: 'Soumise (En attente)' },
    { value: 'En_Cours_Validation', label: 'En cours de validation' },
    { value: 'Validee', label: 'Validée' },
    { value: 'Rejetee', label: 'Rejetée' },
    { value: 'Confirmee', label: 'Confirmée' }
  ];

  // Helper pour extraire une liste d'un ApiResponse éventuel
  const unwrapList = (res) => {
    const d = res?.data;
    if (Array.isArray(d)) return d;
    if (Array.isArray(d?.data)) return d.data; // format {success, data:[...]}
    return [];
  };
  const unwrapObject = (res) => {
    const d = res?.data;
    if (d && d.data && typeof d.data === 'object' && !Array.isArray(d.data)) return d.data;
    return d || {};
  };

  const loadInitialData = async () => {
    try {
      setLoading(true);
      const [candidaturesRes, concoursRes, specialitesRes, centresRes, statsRes] = await Promise.all([
        axios.get('http://localhost:8080/api/gestionnaire/candidatures'),
        axios.get('http://localhost:8080/api/concours'),
        axios.get('http://localhost:8080/api/specialites'),
        axios.get('http://localhost:8080/api/centres'),
        axios.get('http://localhost:8080/api/gestionnaire/statistiques')
      ]);
      setCandidatures(unwrapList(candidaturesRes));
      setConcours(unwrapList(concoursRes));
      setSpecialites(unwrapList(specialitesRes));
      setCentres(unwrapList(centresRes));
      setStatistics(unwrapObject(statsRes));
    } catch (err) {
      console.error('Erreur chargement:', err);
      setConcours([]); setSpecialites([]); setCentres([]);
    } finally {
      setLoading(false);
    }
  };

  const applyFilters = () => {
    let filtered = [...candidatures];
    
    if (filters.searchTerm) {
      const search = filters.searchTerm.toLowerCase();
      filtered = filtered.filter(c => 
        c.nom?.toLowerCase().includes(search) ||
        c.prenom?.toLowerCase().includes(search) ||
        c.cin?.toLowerCase().includes(search) ||
        c.email?.toLowerCase().includes(search) ||
        c.numeroUnique?.toLowerCase().includes(search)
      );
    }
    
    if (filters.concours) {
      filtered = filtered.filter(c => c.concoursId === parseInt(filters.concours));
    }
    
    if (filters.specialite) {
      filtered = filtered.filter(c => c.specialiteId === parseInt(filters.specialite));
    }
    
    if (filters.centre) {
      filtered = filtered.filter(c => c.centreId === parseInt(filters.centre));
    }
    
    if (filters.statut) {
      filtered = filtered.filter(c => c.statut === filters.statut);
    }
    
    setFilteredCandidatures(filtered);
    setPage(0);
  };

  const clearFilters = () => {
    setFilters({
      searchTerm: '',
      concours: '',
      specialite: '',
      centre: '',
      statut: ''
    });
  };

  const handleFilterChange = (field, value) => {
    setFilters(prev => ({ ...prev, [field]: value }));
  };

  const viewCandidatureDetails = async (candidature) => {
    try {
      const response = await axios.get(`http://localhost:8080/api/gestionnaire/candidatures/${candidature.id}`);
      const data = unwrapObject(response); // utiliser helper
      setSelectedCandidature(data);
      setOpenDetails(true);
    } catch (err) {
      console.error('Erreur détails:', err);
    }
  };

  const downloadCV = async (candidatureId) => {
    try {
      const response = await axios.get(
        `http://localhost:8080/api/gestionnaire/candidatures/${candidatureId}/cv`,
        { responseType: 'blob' }
      );
      
      const url = window.URL.createObjectURL(new Blob([response.data]));
      const link = document.createElement('a');
      link.href = url;
      link.setAttribute('download', `CV_${candidatureId}.pdf`);
      document.body.appendChild(link);
      link.click();
      link.remove();
      window.URL.revokeObjectURL(url);
    } catch (err) {
      console.error('Erreur téléchargement:', err);
    }
  };

  const getStatutColor = (statut) => {
    switch (statut) {
      case 'Soumise': return 'warning';
      case 'En_Cours_Validation': return 'info';
      case 'Validee': return 'success';
      case 'Confirmee': return 'success';
      case 'Rejetee': return 'error';
      default: return 'default';
    }
  };

  const getStatutLabel = (statut) => {
    switch (statut) {
      case 'Soumise': return 'Soumise';
      case 'En_Cours_Validation': return 'En cours';
      case 'Validee': return 'Validée';
      case 'Confirmee': return 'Confirmée';
      case 'Rejetee': return 'Rejetée';
      default: return statut;
    }
  };

  const renderStatisticsDialog = () => (
    <Dialog open={openStats} onClose={() => setOpenStats(false)} maxWidth="lg" fullWidth>
      <DialogTitle>
        <Typography variant="h5" component="div" sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
          <StatsIcon color="primary" />
          Statistiques des Candidatures
        </Typography>
      </DialogTitle>
      <DialogContent>
        <Grid container spacing={3}>
          {/* Cartes de statistiques */}
          <Grid item xs={12} sm={6} md={3}>
            <Card sx={{ bgcolor: '#e3f2fd' }}>
              <CardContent sx={{ textAlign: 'center' }}>
                <Typography variant="h4" color="primary" gutterBottom>
                  {statistics.totalCandidatures || 0}
                </Typography>
                <Typography variant="body2" color="text.secondary">
                  Total Candidatures
                </Typography>
              </CardContent>
            </Card>
          </Grid>
          
          <Grid item xs={12} sm={6} md={3}>
            <Card sx={{ bgcolor: '#e8f5e8' }}>
              <CardContent sx={{ textAlign: 'center' }}>
                <Typography variant="h4" color="success.main" gutterBottom>
                  {statistics.acceptees || 0}
                </Typography>
                <Typography variant="body2" color="text.secondary">
                  Acceptées
                </Typography>
              </CardContent>
            </Card>
          </Grid>
          
          <Grid item xs={12} sm={6} md={3}>
            <Card sx={{ bgcolor: '#fff3e0' }}>
              <CardContent sx={{ textAlign: 'center' }}>
                <Typography variant="h4" color="warning.main" gutterBottom>
                  {statistics.enAttente || 0}
                </Typography>
                <Typography variant="body2" color="text.secondary">
                  En Attente
                </Typography>
              </CardContent>
            </Card>
          </Grid>
          
          <Grid item xs={12} sm={6} md={3}>
            <Card sx={{ bgcolor: '#ffebee' }}>
              <CardContent sx={{ textAlign: 'center' }}>
                <Typography variant="h4" color="error.main" gutterBottom>
                  {statistics.refusees || 0}
                </Typography>
                <Typography variant="body2" color="text.secondary">
                  Refusées
                </Typography>
              </CardContent>
            </Card>
          </Grid>

          {/* Graphique en secteurs - Répartition par statut */}
          <Grid item xs={12} md={6}>
            <Paper sx={{ p: 2 }}>
              <Typography variant="h6" gutterBottom align="center">
                Répartition par Statut
              </Typography>
              <ResponsiveContainer width="100%" height={300}>
                <PieChart>
                  <Pie
                    data={statistics.parStatut || []}
                    cx="50%"
                    cy="50%"
                    labelLine={false}
                    label={({ name, percent }) => `${name} ${(percent * 100).toFixed(0)}%`}
                    outerRadius={80}
                    fill="#8884d8"
                    dataKey="value"
                  >
                    {(statistics.parStatut || []).map((entry, index) => (
                      <Cell key={`cell-${index}`} fill={COLORS[index % COLORS.length]} />
                    ))}
                  </Pie>
                  <RechartsTooltip />
                </PieChart>
              </ResponsiveContainer>
            </Paper>
          </Grid>

          {/* Graphique en barres - Candidatures par concours */}
          <Grid item xs={12} md={6}>
            <Paper sx={{ p: 2 }}>
              <Typography variant="h6" gutterBottom align="center">
                Candidatures par Concours
              </Typography>
              <ResponsiveContainer width="100%" height={300}>
                <BarChart data={statistics.parConcours || []}>
                  <CartesianGrid strokeDasharray="3 3" />
                  <XAxis dataKey="nom" angle={-45} textAnchor="end" height={100} />
                  <YAxis />
                  <RechartsTooltip />
                  <Bar dataKey="candidatures" fill="#8884d8" />
                </BarChart>
              </ResponsiveContainer>
            </Paper>
          </Grid>

          {/* Tableau des centres les plus demandés */}
          <Grid item xs={12}>
            <Paper sx={{ p: 2 }}>
              <Typography variant="h6" gutterBottom>
                Centres les Plus Demandés
              </Typography>
              <Table size="small">
                <TableHead>
                  <TableRow>
                    <TableCell>Centre</TableCell>
                    <TableCell>Ville</TableCell>
                    <TableCell align="right">Candidatures</TableCell>
                    <TableCell align="right">Capacité</TableCell>
                    <TableCell align="right">Taux de Remplissage</TableCell>
                  </TableRow>
                </TableHead>
                <TableBody>
                  {(statistics.centresPopulaires || []).map((centre, index) => (
                    <TableRow key={index}>
                      <TableCell>{centre.nom}</TableCell>
                      <TableCell>{centre.ville}</TableCell>
                      <TableCell align="right">{centre.candidatures}</TableCell>
                      <TableCell align="right">{centre.capacite}</TableCell>
                      <TableCell align="right">
                        <Chip
                          label={`${((centre.candidatures / centre.capacite) * 100).toFixed(1)}%`}
                          color={centre.candidatures > centre.capacite ? 'error' : 'success'}
                          size="small"
                        />
                      </TableCell>
                    </TableRow>
                  ))}
                </TableBody>
              </Table>
            </Paper>
          </Grid>
        </Grid>
      </DialogContent>
      <DialogActions>
        <Button onClick={() => setOpenStats(false)}>Fermer</Button>
      </DialogActions>
    </Dialog>
  );

  const renderCandidatureDetails = () => (
    <Dialog open={openDetails} onClose={() => setOpenDetails(false)} maxWidth="md" fullWidth>
      <DialogTitle>
        <Typography variant="h6">
          Détails de la Candidature - {selectedCandidature?.numeroUnique}
        </Typography>
      </DialogTitle>
      <DialogContent>
        {selectedCandidature && (
          <Grid container spacing={3}>
            {/* Informations personnelles */}
            <Grid item xs={12} md={6}>
              <Paper sx={{ p: 2, height: '100%' }}>
                <Typography variant="subtitle1" color="primary" gutterBottom>
                  <PeopleIcon sx={{ mr: 1, verticalAlign: 'middle' }} />
                  Informations Personnelles
                </Typography>
                <Divider sx={{ mb: 2 }} />
                
                <Box sx={{ display: 'flex', alignItems: 'center', mb: 2 }}>
                  <Avatar sx={{ mr: 2, bgcolor: 'primary.main' }}>
                    {selectedCandidature.prenom?.charAt(0)}{selectedCandidature.nom?.charAt(0)}
                  </Avatar>
                  <Box>
                    <Typography variant="h6">
                      {selectedCandidature.prenom} {selectedCandidature.nom}
                    </Typography>
                    <Typography variant="body2" color="text.secondary">
                      {selectedCandidature.genre}
                    </Typography>
                  </Box>
                </Box>

                <List dense>
                  <ListItem>
                    <ListItemIcon><AssignmentIcon /></ListItemIcon>
                    <ListItemText 
                      primary="CIN" 
                      secondary={selectedCandidature.cin}
                    />
                  </ListItem>
                  <ListItem>
                    <ListItemIcon><EmailIcon /></ListItemIcon>
                    <ListItemText 
                      primary="Email" 
                      secondary={selectedCandidature.email}
                    />
                  </ListItem>
                  <ListItem>
                    <ListItemIcon><PhoneIcon /></ListItemIcon>
                    <ListItemText 
                      primary="Téléphone" 
                      secondary={selectedCandidature.telephone}
                    />
                  </ListItem>
                  <ListItem>
                    <ListItemIcon><LocationIcon /></ListItemIcon>
                    <ListItemText 
                      primary="Ville" 
                      secondary={selectedCandidature.ville}
                    />
                  </ListItem>
                </List>
              </Paper>
            </Grid>

            {/* Formation et concours */}
            <Grid item xs={12} md={6}>
              <Paper sx={{ p: 2, height: '100%' }}>
                <Typography variant="subtitle1" color="primary" gutterBottom>
                  <SchoolIcon sx={{ mr: 1, verticalAlign: 'middle' }} />
                  Formation & Concours
                </Typography>
                <Divider sx={{ mb: 2 }} />

                <List dense>
                  <ListItem>
                    <ListItemIcon><SchoolIcon /></ListItemIcon>
                    <ListItemText 
                      primary="Diplôme" 
                      secondary={`${selectedCandidature.diplomePrincipal} en ${selectedCandidature.specialiteDiplome}`}
                    />
                  </ListItem>
                  <ListItem>
                    <ListItemIcon><WorkIcon /></ListItemIcon>
                    <ListItemText 
                      primary="Établissement" 
                      secondary={`${selectedCandidature.etablissement} (${selectedCandidature.anneeObtention})`}
                    />
                  </ListItem>
                  <ListItem>
                    <ListItemText 
                      primary="Concours" 
                      secondary={selectedCandidature.concoursNom}
                    />
                  </ListItem>
                  <ListItem>
                    <ListItemText 
                      primary="Spécialité" 
                      secondary={selectedCandidature.specialiteNom}
                    />
                  </ListItem>
                  <ListItem>
                    <ListItemText 
                      primary="Centre d'examen" 
                      secondary={`${selectedCandidature.centreNom} - ${selectedCandidature.centreVille}`}
                    />
                  </ListItem>
                </List>

                <Box sx={{ mt: 2 }}>
                  <Chip
                    label={getStatutLabel(selectedCandidature.statut)}
                    color={getStatutColor(selectedCandidature.statut)}
                    size="small"
                  />
                </Box>
              </Paper>
            </Grid>

            {/* Actions */}
            <Grid item xs={12}>
              <Paper sx={{ p: 2 }}>
                <Typography variant="subtitle1" color="primary" gutterBottom>
                  Actions
                </Typography>
                <Divider sx={{ mb: 2 }} />
                
                <Box sx={{ display: 'flex', gap: 2, flexWrap: 'wrap' }}>
                  <Button
                    variant="outlined"
                    startIcon={<DownloadIcon />}
                    onClick={() => downloadCV(selectedCandidature.id)}
                    disabled={!selectedCandidature.cvFichier}
                  >
                    Télécharger CV
                  </Button>
                  
                  <Button
                    variant="outlined"
                    startIcon={<EmailIcon />}
                    href={`mailto:${selectedCandidature.email}`}
                  >
                    Envoyer Email
                  </Button>
                </Box>

                <Typography variant="body2" color="text.secondary" sx={{ mt: 2 }}>
                  Candidature soumise le {new Date(selectedCandidature.dateCreation).toLocaleDateString('fr-FR')}
                </Typography>
              </Paper>
            </Grid>
          </Grid>
        )}
      </DialogContent>
      <DialogActions>
        <Button onClick={() => setOpenDetails(false)}>Fermer</Button>
      </DialogActions>
    </Dialog>
  );

  const handleAction = async (candidature, action, motif) => {
    try {
      await axios.put(`http://localhost:8080/api/gestionnaire/candidatures/${candidature.id}/action`, { action, motif });
      await loadInitialData();
    } catch (e) {
      console.error('Action erreur', e);
    } finally {
      setRejetDialogOpen(false);
      setRejetMotif("");
      setCandidatureAction(null);
    }
  };

  const paginatedCandidatures = filteredCandidatures.slice(
    page * rowsPerPage,
    page * rowsPerPage + rowsPerPage
  );

  return (
    <Container maxWidth="xl" sx={{ py: 4 }}>
      <Typography variant="h4" gutterBottom>
        Gestion des Candidatures
      </Typography>

      {/* Boutons d'action principaux */}
      <Box sx={{ mb: 3, display: 'flex', gap: 2, flexWrap: 'wrap' }}>
        <Button
          variant="contained"
          startIcon={<StatsIcon />}
          onClick={() => setOpenStats(true)}
        >
          Statistiques
        </Button>
        
        <Button
          variant="outlined"
          startIcon={<RefreshIcon />}
          onClick={loadInitialData}
          disabled={loading}
        >
          Actualiser
        </Button>
        
        <Badge badgeContent={filteredCandidatures.length} color="primary">
          <Button variant="outlined" startIcon={<PeopleIcon />}>
            Candidatures
          </Button>
        </Badge>
      </Box>

      {/* Filtres */}
      <Paper sx={{ p: 3, mb: 3 }}>
        <Typography variant="h6" gutterBottom>
          <FilterIcon sx={{ mr: 1, verticalAlign: 'middle' }} />
          Filtres de Recherche
        </Typography>
        
        <Grid container spacing={2}>
          <Grid item xs={12} sm={6} md={3}>
            <TextField
              fullWidth
              label="Recherche"
              value={filters.searchTerm}
              onChange={(e) => handleFilterChange('searchTerm', e.target.value)}
              placeholder="Nom, CIN, Email..."
              InputProps={{
                startAdornment: (
                  <InputAdornment position="start">
                    <SearchIcon />
                  </InputAdornment>
                ),
              }}
            />
          </Grid>
          
          <Grid item xs={12} sm={6} md={2}>
            <FormControl fullWidth>
              <InputLabel>Concours</InputLabel>
              <Select
                value={filters.concours}
                label="Concours"
                onChange={(e) => handleFilterChange('concours', e.target.value)}
              >
                <MenuItem value="">Tous</MenuItem>
                {concours.map(c => (
                  <MenuItem key={c.id} value={c.id}>{c.nom}</MenuItem>
                ))}
              </Select>
            </FormControl>
          </Grid>
          
          <Grid item xs={12} sm={6} md={2}>
            <FormControl fullWidth>
              <InputLabel>Spécialité</InputLabel>
              <Select
                value={filters.specialite}
                label="Spécialité"
                onChange={(e) => handleFilterChange('specialite', e.target.value)}
              >
                <MenuItem value="">Toutes</MenuItem>
                {specialites.map(s => (
                  <MenuItem key={s.id} value={s.id}>{s.nom}</MenuItem>
                ))}
              </Select>
            </FormControl>
          </Grid>
          
          <Grid item xs={12} sm={6} md={2}>
            <FormControl fullWidth>
              <InputLabel>Centre</InputLabel>
              <Select
                value={filters.centre}
                label="Centre"
                onChange={(e) => handleFilterChange('centre', e.target.value)}
              >
                <MenuItem value="">Tous</MenuItem>
                {centres.map(c => (
                  <MenuItem key={c.id} value={c.id}>{c.nom}</MenuItem>
                ))}
              </Select>
            </FormControl>
          </Grid>
          
          <Grid item xs={12} sm={6} md={2}>
            <FormControl fullWidth>
              <InputLabel>Statut</InputLabel>
              <Select
                value={filters.statut}
                label="Statut"
                onChange={(e) => handleFilterChange('statut', e.target.value)}
              >
                <MenuItem value="">Tous</MenuItem>
                {STATUTS.map(s => <MenuItem key={s.value} value={s.value}>{s.label}</MenuItem>)}
              </Select>
            </FormControl>
          </Grid>
          
          <Grid item xs={12} sm={6} md={1}>
            <Button
              fullWidth
              variant="outlined"
              onClick={clearFilters}
              startIcon={<ClearIcon />}
              sx={{ height: '56px' }}
            >
              Effacer
            </Button>
          </Grid>
        </Grid>
      </Paper>

      {/* Tableau des candidatures */}
      <Paper sx={{ width: '100%', overflow: 'hidden' }}>
        {loading ? (
          <Box sx={{ display: 'flex', justifyContent: 'center', p: 4 }}>
            <CircularProgress />
          </Box>
        ) : (
          <>
            <TableContainer sx={{ maxHeight: 600 }}>
              <Table stickyHeader>
                <TableHead>
                  <TableRow>
                    <TableCell>N° Unique</TableCell>
                    <TableCell>Candidat</TableCell>
                    <TableCell>Concours</TableCell>
                    <TableCell>Spécialité</TableCell>
                    <TableCell>Centre</TableCell>
                    <TableCell>Statut</TableCell>
                    <TableCell>Date</TableCell>
                    <TableCell align="center">Actions</TableCell>
                  </TableRow>
                </TableHead>
                <TableBody>
                  {paginatedCandidatures.map((candidature) => (
                    <TableRow key={candidature.id} hover>
                      <TableCell>
                        <Typography variant="body2" fontWeight="bold">
                          {candidature.numeroUnique}
                        </Typography>
                      </TableCell>
                      <TableCell>
                        <Box sx={{ display: 'flex', alignItems: 'center' }}>
                          <Avatar sx={{ mr: 1, width: 32, height: 32 }}>
                            {candidature.prenom?.charAt(0)}
                          </Avatar>
                          <Box>
                            <Typography variant="body2">
                              {candidature.prenom} {candidature.nom}
                            </Typography>
                            <Typography variant="caption" color="text.secondary">
                              {candidature.cin}
                            </Typography>
                          </Box>
                        </Box>
                      </TableCell>
                      <TableCell>
                        <Typography variant="body2">
                          {candidature.concoursNom}
                        </Typography>
                      </TableCell>
                      <TableCell>
                        <Typography variant="body2">
                          {candidature.specialiteNom}
                        </Typography>
                      </TableCell>
                      <TableCell>
                        <Typography variant="body2">
                          {candidature.centreNom}
                        </Typography>
                        <Typography variant="caption" color="text.secondary">
                          {candidature.centreVille}
                        </Typography>
                      </TableCell>
                      <TableCell>
                        <Chip
                          label={getStatutLabel(candidature.statut)}
                          color={getStatutColor(candidature.statut)}
                          size="small"
                        />
                      </TableCell>
                      <TableCell>
                        <Typography variant="body2">
                          {new Date(candidature.dateCreation).toLocaleDateString('fr-FR')}
                        </Typography>
                      </TableCell>
                      <TableCell align="center">
                        <Box sx={{ display: 'flex', gap: 1 }}>
                          <Tooltip title="Voir détails">
                            <IconButton size="small" onClick={() => viewCandidatureDetails(candidature)}>
                              <ViewIcon />
                            </IconButton>
                          </Tooltip>
                          <Tooltip title="Télécharger CV">
                            <IconButton size="small" onClick={() => downloadCV(candidature.id)} disabled={!candidature.cvFichier}>
                              <DownloadIcon />
                            </IconButton>
                          </Tooltip>
                          {candidature.statut === 'Soumise' && (
                            <Tooltip title="Mettre en cours">
                              <IconButton size="small" color="info" onClick={() => handleAction(candidature,'en_cours')}>
                                <HourglassIcon fontSize="small" />
                              </IconButton>
                            </Tooltip>
                          )}
                          {(candidature.statut === 'Soumise' || candidature.statut === 'En_Cours_Validation') && (
                            <Tooltip title="Valider">
                              <IconButton size="small" color="success" onClick={() => handleAction(candidature,'valider')}>
                                <CheckIcon fontSize="small" />
                              </IconButton>
                            </Tooltip>
                          )}
                          {['Soumise','En_Cours_Validation','Validee'].includes(candidature.statut) && (
                            <Tooltip title="Rejeter">
                              <IconButton size="small" color="error" onClick={() => { setCandidatureAction(candidature); setRejetDialogOpen(true); }}>
                                <CloseIcon fontSize="small" />
                              </IconButton>
                            </Tooltip>
                          )}
                        </Box>
                      </TableCell>
                    </TableRow>
                  ))}
                </TableBody>
              </Table>
            </TableContainer>
            
            <TablePagination
              rowsPerPageOptions={[5, 10, 25, 50]}
              component="div"
              count={filteredCandidatures.length}
              rowsPerPage={rowsPerPage}
              page={page}
              onPageChange={(event, newPage) => setPage(newPage)}
              onRowsPerPageChange={(event) => {
                setRowsPerPage(parseInt(event.target.value, 10));
                setPage(0);
              }}
              labelRowsPerPage="Lignes par page:"
              labelDisplayedRows={({ from, to, count }) => 
                `${from}-${to} sur ${count !== -1 ? count : `plus de ${to}`}`
              }
            />
          </>
        )}
      </Paper>

      {/* Dialogs */}
      {renderCandidatureDetails()}
      {renderStatisticsDialog()}
      <Dialog open={rejetDialogOpen} onClose={() => setRejetDialogOpen(false)} maxWidth="xs" fullWidth>
        <DialogTitle>Motif de rejet</DialogTitle>
        <DialogContent>
          <TextField multiline minRows={3} fullWidth value={rejetMotif} onChange={e=>setRejetMotif(e.target.value)} placeholder="Indiquez le motif" />
        </DialogContent>
        <DialogActions>
          <Button onClick={()=>setRejetDialogOpen(false)}>Annuler</Button>
          <Button color="error" disabled={!rejetMotif.trim()} onClick={()=>handleAction(candidatureAction,'rejeter',rejetMotif)}>Rejeter</Button>
        </DialogActions>
      </Dialog>

      {/* Bouton flottant pour les statistiques */}
      <Fab
        color="primary"
        aria-label="statistiques"
        sx={{ position: 'fixed', bottom: 16, right: 16 }}
        onClick={() => setOpenStats(true)}
      >
        <StatsIcon />
      </Fab>
    </Container>
  );
};

export default GestionCandidaturesComplete;
