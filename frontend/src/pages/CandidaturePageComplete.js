import React, { useState, useEffect } from 'react';
import { useNavigate, useLocation } from 'react-router-dom';
import {
  Stepper, Step, StepLabel, Button, Typography, Box, Container,
  Grid, TextField, FormControl, InputLabel, Select, MenuItem,
  Paper, Alert, CircularProgress, FormControlLabel, Checkbox,
  Autocomplete, Chip, FormHelperText, Input, IconButton, InputAdornment
} from '@mui/material';
import { DatePicker } from '@mui/x-date-pickers/DatePicker';
import { LocalizationProvider } from '@mui/x-date-pickers/LocalizationProvider';
import { AdapterDateFns } from '@mui/x-date-pickers/AdapterDateFns';
import { fr } from 'date-fns/locale';
import { CloudUpload as UploadIcon, Delete as DeleteIcon } from '@mui/icons-material';
import axios from 'axios';

// Import des utilitaires
import { VILLES_MAROC } from '../utils/villesMaroc';
import { getVilleNaissanceOptions } from '../utils/villesNaissance';
import { 
  validateForm, 
  validateCV, 
  formatTelephone, 
  formatCIN 
} from '../utils/validationComplete';

const CandidaturePageComplete = () => {
  const navigate = useNavigate();
  const location = useLocation();
  const [activeStep, setActiveStep] = useState(0);
  
  // Données pré-sélectionnées depuis PostesPage
  const preSelectedConcours = location.state?.concoursId;
  const preSelectedSpecialite = location.state?.specialiteId;
  const preSelectedCentre = location.state?.centreId;
  const fromPostes = !!preSelectedConcours;

  // États
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  const [success, setSuccess] = useState('');
  const [validationErrors, setValidationErrors] = useState({});
  
  // Données des listes
  const [concours, setConcours] = useState([]);
  const [specialites, setSpecialites] = useState([]);
  const [centres, setCentres] = useState([]);
  const [specialitesDisponibles, setSpecialitesDisponibles] = useState([]);
  const [centresDisponibles, setCentresDisponibles] = useState([]);
  
  // Upload CV
  const [cvFile, setCvFile] = useState(null);
  const [cvError, setCvError] = useState('');
  
  // Formulaire
  const [formData, setFormData] = useState({
    // Informations personnelles
    genre: '',
    nom: '',
    prenom: '',
    cin: '',
    dateNaissance: null,
    lieuNaissance: '',
    ville: '',
    email: '',
    telephone: '',
    telephoneUrgence: '',
    
    // Formation
    diplomePrincipal: '',
    specialiteDiplome: '',
    etablissement: '',
    anneeObtention: '',
    
    // Choix concours
    concoursId: preSelectedConcours || '',
    specialiteId: preSelectedSpecialite || '',
    centreId: preSelectedCentre || '',
    
    // Acceptation conditions
    accepteConditions: false
  });

  const steps = [
    'Informations Personnelles',
    'Formation et Diplômes', 
    'Choix du Concours',
    'Confirmation'
  ];

  // Chargement initial des données
  useEffect(() => {
    loadInitialData();
  }, []);

  // Mise à jour des spécialités quand le concours change
  useEffect(() => {
    if (formData.concoursId && !fromPostes) {
      loadSpecialitesByConcours(formData.concoursId);
      setFormData(prev => ({ ...prev, specialiteId: '', centreId: '' }));
    }
  }, [formData.concoursId, fromPostes]);

  // Mise à jour des centres quand le concours change
  useEffect(() => {
    if (formData.concoursId && !fromPostes) {
      loadCentresByConcours(formData.concoursId);
      if (!formData.specialiteId) {
        setFormData(prev => ({ ...prev, centreId: '' }));
      }
    }
  }, [formData.concoursId, fromPostes]);

  const loadInitialData = async () => {
    try {
      setLoading(true);
      const [concoursRes, specialitesRes, centresRes] = await Promise.all([
        axios.get('http://localhost:8080/api/concours'),
        axios.get('http://localhost:8080/api/specialites'),
        axios.get('http://localhost:8080/api/centres')
      ]);
      
      setConcours(concoursRes.data || []);
      setSpecialites(specialitesRes.data || []);
      setCentres(centresRes.data || []);
      
      // Si vient de PostesPage, charger les options spécifiques
      if (fromPostes && preSelectedConcours) {
        await loadSpecialitesByConcours(preSelectedConcours);
        await loadCentresByConcours(preSelectedConcours);
      }
      
    } catch (err) {
      console.error('Erreur chargement:', err);
      setError('Erreur lors du chargement des données');
    } finally {
      setLoading(false);
    }
  };

  const loadSpecialitesByConcours = async (concoursId) => {
    try {
      const response = await axios.get(`http://localhost:8080/api/concours/${concoursId}/specialites`);
      setSpecialitesDisponibles(response.data || []);
    } catch (err) {
      console.error('Erreur spécialités:', err);
      setSpecialitesDisponibles([]);
    }
  };

  const loadCentresByConcours = async (concoursId) => {
    try {
      const response = await axios.get(`http://localhost:8080/api/concours/${concoursId}/centres`);
      setCentresDisponibles(response.data || []);
    } catch (err) {
      console.error('Erreur centres:', err);
      setCentresDisponibles([]);
    }
  };

  const handleInputChange = (field, value) => {
    // Formatage spécial pour certains champs
    if (field === 'telephone' || field === 'telephoneUrgence') {
      value = formatTelephone(value);
    } else if (field === 'cin') {
      value = formatCIN(value);
    }
    
    setFormData(prev => ({ ...prev, [field]: value }));
    
    // Supprimer l'erreur de validation quand l'utilisateur tape
    if (validationErrors[field]) {
      setValidationErrors(prev => {
        const newErrors = { ...prev };
        delete newErrors[field];
        return newErrors;
      });
    }
  };

  const handleCVUpload = (event) => {
    const file = event.target.files[0];
    setCvError('');
    
    if (file) {
      const error = validateCV(file);
      if (error) {
        setCvError(error);
        setCvFile(null);
      } else {
        setCvFile(file);
      }
    }
  };

  const removeCVFile = () => {
    setCvFile(null);
    setCvError('');
    // Réinitialiser l'input file
    const fileInput = document.getElementById('cv-upload');
    if (fileInput) fileInput.value = '';
  };

  const validateCurrentStep = () => {
    const errors = validateForm(formData, activeStep);
    
    // Validation spéciale pour le CV à l'étape 1
    if (activeStep === 1 && !cvFile) {
      errors.cv = 'Le CV est obligatoire';
    }
    
    setValidationErrors(errors);
    return Object.keys(errors).length === 0;
  };

  const handleNext = () => {
    if (validateCurrentStep()) {
      setActiveStep(prev => prev + 1);
    } else {
      setError('Veuillez corriger les erreurs avant de continuer');
    }
  };

  const handleBack = () => {
    setActiveStep(prev => prev - 1);
    setError('');
  };

  const handleSubmit = async () => {
    if (!validateCurrentStep()) {
      setError('Veuillez corriger les erreurs avant de soumettre');
      return;
    }
    
    if (!formData.accepteConditions) {
      setError('Vous devez accepter les conditions d\'utilisation');
      return;
    }

    try {
      setLoading(true);
      setError('');
      
      // Préparer FormData pour l'upload
      const submitData = new FormData();
      
      // Ajouter les données du formulaire
      Object.keys(formData).forEach(key => {
        if (formData[key] !== null && formData[key] !== '') {
          if (key === 'dateNaissance') {
            submitData.append(key, formData[key].toISOString().split('T')[0]);
          } else {
            submitData.append(key, formData[key]);
          }
        }
      });
      
      // Ajouter le CV
      if (cvFile) {
        submitData.append('cv', cvFile);
      }
      
      const response = await axios.post(
        'http://localhost:8080/api/candidatures/soumettre-avec-cv', 
        submitData,
        {
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        }
      );
      
      if (response.data.success) {
        setSuccess(`Candidature soumise avec succès ! Numéro: ${response.data.numeroUnique}`);
        setTimeout(() => {
          navigate('/suivi', { 
            state: { numeroUnique: response.data.numeroUnique } 
          });
        }, 3000);
      } else {
        setError(response.data.message || 'Erreur lors de la soumission');
      }
      
    } catch (err) {
      console.error('Erreur soumission:', err);
      setError(err.response?.data?.message || 'Erreur lors de la soumission de la candidature');
    } finally {
      setLoading(false);
    }
  };

  const renderStepContent = (step) => {
    switch (step) {
      case 0:
        return renderPersonalInfoStep();
      case 1:
        return renderEducationStep();
      case 2:
        return renderConcoursStep();
      case 3:
        return renderConfirmationStep();
      default:
        return null;
    }
  };

  const renderPersonalInfoStep = () => (
    <Grid container spacing={3}>
      {/* Civilité */}
      <Grid item xs={12} sm={6}>
        <FormControl fullWidth error={!!validationErrors.genre}>
          <InputLabel>Civilité *</InputLabel>
          <Select
            value={formData.genre}
            label="Civilité *"
            onChange={(e) => handleInputChange('genre', e.target.value)}
          >
            <MenuItem value="Monsieur">Monsieur</MenuItem>
            <MenuItem value="Madame">Madame</MenuItem>
          </Select>
          {validationErrors.genre && (
            <FormHelperText>{validationErrors.genre}</FormHelperText>
          )}
        </FormControl>
      </Grid>

      {/* Nom */}
      <Grid item xs={12} sm={6}>
        <TextField
          fullWidth
          label="Nom *"
          value={formData.nom}
          onChange={(e) => handleInputChange('nom', e.target.value)}
          error={!!validationErrors.nom}
          helperText={validationErrors.nom}
          placeholder="Votre nom de famille"
        />
      </Grid>

      {/* Prénom */}
      <Grid item xs={12} sm={6}>
        <TextField
          fullWidth
          label="Prénom *"
          value={formData.prenom}
          onChange={(e) => handleInputChange('prenom', e.target.value)}
          error={!!validationErrors.prenom}
          helperText={validationErrors.prenom}
          placeholder="Votre prénom"
        />
      </Grid>

      {/* CIN */}
      <Grid item xs={12} sm={6}>
        <TextField
          fullWidth
          label="CIN *"
          value={formData.cin}
          onChange={(e) => handleInputChange('cin', e.target.value)}
          error={!!validationErrors.cin}
          helperText={validationErrors.cin || "Format: A123456 ou AB123456"}
          placeholder="Ex: A123456"
        />
      </Grid>

      {/* Date de naissance */}
      <Grid item xs={12} sm={6}>
        <LocalizationProvider dateAdapter={AdapterDateFns} adapterLocale={fr}>
          <DatePicker
            label="Date de naissance *"
            value={formData.dateNaissance}
            onChange={(date) => handleInputChange('dateNaissance', date)}
            renderInput={(params) => (
              <TextField
                {...params}
                fullWidth
                error={!!validationErrors.dateNaissance}
                helperText={validationErrors.dateNaissance}
              />
            )}
            maxDate={new Date()}
          />
        </LocalizationProvider>
      </Grid>

      {/* Lieu de naissance */}
      <Grid item xs={12} sm={6}>
        <Autocomplete
          options={getVilleNaissanceOptions(formData.lieuNaissance)}
          value={formData.lieuNaissance}
          onChange={(event, newValue) => handleInputChange('lieuNaissance', newValue || '')}
          onInputChange={(event, newInputValue) => handleInputChange('lieuNaissance', newInputValue)}
          freeSolo
          renderInput={(params) => (
            <TextField
              {...params}
              label="Lieu de naissance *"
              error={!!validationErrors.lieuNaissance}
              helperText={validationErrors.lieuNaissance || "Tapez pour rechercher une ville"}
              placeholder="Ex: Casablanca"
            />
          )}
        />
      </Grid>

      {/* Ville de résidence */}
      <Grid item xs={12} sm={6}>
        <Autocomplete
          options={VILLES_MAROC}
          value={formData.ville}
          onChange={(event, newValue) => handleInputChange('ville', newValue || '')}
          renderInput={(params) => (
            <TextField
              {...params}
              label="Ville de résidence *"
              error={!!validationErrors.ville}
              helperText={validationErrors.ville || "Tapez pour rechercher votre ville"}
              placeholder="Ex: Rabat"
            />
          )}
        />
      </Grid>

      {/* Email */}
      <Grid item xs={12} sm={6}>
        <TextField
          fullWidth
          label="Email *"
          type="email"
          value={formData.email}
          onChange={(e) => handleInputChange('email', e.target.value)}
          error={!!validationErrors.email}
          helperText={validationErrors.email}
          placeholder="votre.email@exemple.com"
        />
      </Grid>

      {/* Téléphone */}
      <Grid item xs={12} sm={6}>
        <TextField
          fullWidth
          label="Téléphone *"
          value={formData.telephone}
          onChange={(e) => handleInputChange('telephone', e.target.value)}
          error={!!validationErrors.telephone}
          helperText={validationErrors.telephone || "Format: 06 12 34 56 78"}
          placeholder="06 12 34 56 78"
          inputProps={{ maxLength: 12 }}
        />
      </Grid>

      {/* Téléphone urgence */}
      <Grid item xs={12} sm={6}>
        <TextField
          fullWidth
          label="Téléphone d'urgence"
          value={formData.telephoneUrgence}
          onChange={(e) => handleInputChange('telephoneUrgence', e.target.value)}
          error={!!validationErrors.telephoneUrgence}
          helperText={validationErrors.telephoneUrgence || "Optionnel - Contact d'urgence"}
          placeholder="05 12 34 56 78"
          inputProps={{ maxLength: 12 }}
        />
      </Grid>
    </Grid>
  );

  const renderEducationStep = () => (
    <Grid container spacing={3}>
      {/* Diplôme principal */}
      <Grid item xs={12} sm={6}>
        <FormControl fullWidth error={!!validationErrors.diplomePrincipal}>
          <InputLabel>Diplôme principal *</InputLabel>
          <Select
            value={formData.diplomePrincipal}
            label="Diplôme principal *"
            onChange={(e) => handleInputChange('diplomePrincipal', e.target.value)}
          >
            <MenuItem value="Baccalauréat">Baccalauréat</MenuItem>
            <MenuItem value="DUT">DUT</MenuItem>
            <MenuItem value="BTS">BTS</MenuItem>
            <MenuItem value="Licence">Licence</MenuItem>
            <MenuItem value="Master">Master</MenuItem>
            <MenuItem value="Diplôme d'ingénieur">Diplôme d'ingénieur</MenuItem>
            <MenuItem value="Autre">Autre</MenuItem>
          </Select>
          {validationErrors.diplomePrincipal && (
            <FormHelperText>{validationErrors.diplomePrincipal}</FormHelperText>
          )}
        </FormControl>
      </Grid>

      {/* Spécialité du diplôme */}
      <Grid item xs={12} sm={6}>
        <TextField
          fullWidth
          label="Spécialité du diplôme *"
          value={formData.specialiteDiplome}
          onChange={(e) => handleInputChange('specialiteDiplome', e.target.value)}
          error={!!validationErrors.specialiteDiplome}
          helperText={validationErrors.specialiteDiplome}
          placeholder="Ex: Informatique, Droit, Économie..."
        />
      </Grid>

      {/* Établissement */}
      <Grid item xs={12} sm={6}>
        <TextField
          fullWidth
          label="Établissement *"
          value={formData.etablissement}
          onChange={(e) => handleInputChange('etablissement', e.target.value)}
          error={!!validationErrors.etablissement}
          helperText={validationErrors.etablissement}
          placeholder="Nom de votre établissement"
        />
      </Grid>

      {/* Année d'obtention */}
      <Grid item xs={12} sm={6}>
        <TextField
          fullWidth
          label="Année d'obtention *"
          type="number"
          value={formData.anneeObtention}
          onChange={(e) => handleInputChange('anneeObtention', e.target.value)}
          error={!!validationErrors.anneeObtention}
          helperText={validationErrors.anneeObtention}
          placeholder="Ex: 2023"
          inputProps={{ min: 1990, max: new Date().getFullYear() }}
        />
      </Grid>

      {/* Upload CV */}
      <Grid item xs={12}>
        <Box sx={{ p: 3, border: '2px dashed #ddd', borderRadius: 2, textAlign: 'center' }}>
          <Typography variant="h6" gutterBottom>
            Télécharger votre CV *
          </Typography>
          
          {!cvFile ? (
            <>
              <input
                accept=".pdf,.doc,.docx"
                style={{ display: 'none' }}
                id="cv-upload"
                type="file"
                onChange={handleCVUpload}
              />
              <label htmlFor="cv-upload">
                <Button
                  variant="outlined"
                  component="span"
                  startIcon={<UploadIcon />}
                  size="large"
                  color={cvError ? 'error' : 'primary'}
                >
                  Choisir le fichier CV
                </Button>
              </label>
              <Typography variant="body2" color="text.secondary" sx={{ mt: 1 }}>
                Formats acceptés : PDF, DOC, DOCX (max 5MB)
              </Typography>
              {cvError && (
                <Typography color="error" variant="body2" sx={{ mt: 1 }}>
                  {cvError}
                </Typography>
              )}
              {validationErrors.cv && (
                <Typography color="error" variant="body2" sx={{ mt: 1 }}>
                  {validationErrors.cv}
                </Typography>
              )}
            </>
          ) : (
            <Box sx={{ display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 2 }}>
              <Chip
                label={`${cvFile.name} (${(cvFile.size / 1024 / 1024).toFixed(2)} MB)`}
                color="success"
                onDelete={removeCVFile}
                deleteIcon={<DeleteIcon />}
              />
            </Box>
          )}
        </Box>
      </Grid>
    </Grid>
  );

  const renderConcoursStep = () => (
    <Grid container spacing={3}>
      {fromPostes && (
        <Grid item xs={12}>
          <Alert severity="info" sx={{ mb: 2 }}>
            Vous avez été redirigé depuis la page des postes. Le concours est pré-sélectionné.
          </Alert>
        </Grid>
      )}

      {/* Concours */}
      <Grid item xs={12}>
        <FormControl fullWidth error={!!validationErrors.concoursId}>
          <InputLabel>Concours *</InputLabel>
          <Select
            value={formData.concoursId}
            label="Concours *"
            onChange={(e) => handleInputChange('concoursId', e.target.value)}
            disabled={fromPostes}
          >
            {concours.map(c => (
              <MenuItem key={c.id} value={c.id}>
                <Box>
                  <Typography variant="body1">{c.nom}</Typography>
                  <Typography variant="caption" color="text.secondary">
                    {c.description}
                  </Typography>
                </Box>
              </MenuItem>
            ))}
          </Select>
          {validationErrors.concoursId && (
            <FormHelperText>{validationErrors.concoursId}</FormHelperText>
          )}
        </FormControl>
      </Grid>

      {/* Spécialité */}
      <Grid item xs={12} sm={6}>
        <FormControl 
          fullWidth 
          error={!!validationErrors.specialiteId}
          disabled={!formData.concoursId || (fromPostes && preSelectedSpecialite)}
        >
          <InputLabel>Spécialité *</InputLabel>
          <Select
            value={formData.specialiteId}
            label="Spécialité *"
            onChange={(e) => handleInputChange('specialiteId', e.target.value)}
          >
            {(fromPostes ? specialites : specialitesDisponibles).map(s => (
              <MenuItem key={s.id} value={s.id}>
                {s.nom}
              </MenuItem>
            ))}
          </Select>
          {validationErrors.specialiteId && (
            <FormHelperText>{validationErrors.specialiteId}</FormHelperText>
          )}
          {!formData.concoursId && (
            <FormHelperText>Sélectionnez d'abord un concours</FormHelperText>
          )}
        </FormControl>
      </Grid>

      {/* Centre d'examen */}
      <Grid item xs={12} sm={6}>
        <FormControl 
          fullWidth 
          error={!!validationErrors.centreId}
          disabled={!formData.concoursId || (fromPostes && preSelectedCentre)}
        >
          <InputLabel>Centre d'examen *</InputLabel>
          <Select
            value={formData.centreId}
            label="Centre d'examen *"
            onChange={(e) => handleInputChange('centreId', e.target.value)}
          >
            {(fromPostes ? centres : centresDisponibles).map(c => (
              <MenuItem key={c.id} value={c.id}>
                <Box>
                  <Typography variant="body2">{c.nom}</Typography>
                  <Typography variant="caption" color="text.secondary">
                    {c.ville} - {c.adresse}
                  </Typography>
                </Box>
              </MenuItem>
            ))}
          </Select>
          {validationErrors.centreId && (
            <FormHelperText>{validationErrors.centreId}</FormHelperText>
          )}
          {!formData.concoursId && (
            <FormHelperText>Sélectionnez d'abord un concours</FormHelperText>
          )}
        </FormControl>
      </Grid>

      {/* Informations sur les places disponibles */}
      {formData.concoursId && formData.specialiteId && formData.centreId && (
        <Grid item xs={12}>
          <Alert severity="info">
            <Typography variant="body2">
              <strong>Informations importantes :</strong><br />
              • Vérifiez que votre spécialité de diplôme correspond à la spécialité du concours<br />
              • Les places sont limitées par centre et spécialité<br />
              • Une fois validée, votre candidature ne pourra plus être modifiée
            </Typography>
          </Alert>
        </Grid>
      )}
    </Grid>
  );

  const renderConfirmationStep = () => {
    const selectedConcours = concours.find(c => c.id === formData.concoursId);
    const selectedSpecialite = (fromPostes ? specialites : specialitesDisponibles)
      .find(s => s.id === formData.specialiteId);
    const selectedCentre = (fromPostes ? centres : centresDisponibles)
      .find(c => c.id === formData.centreId);

    return (
      <Grid container spacing={3}>
        <Grid item xs={12}>
          <Typography variant="h6" gutterBottom>
            Récapitulatif de votre candidature
          </Typography>
        </Grid>

        {/* Informations personnelles */}
        <Grid item xs={12} md={6}>
          <Paper sx={{ p: 2 }}>
            <Typography variant="subtitle1" color="primary" gutterBottom>
              Informations personnelles
            </Typography>
            <Typography variant="body2">
              <strong>Nom :</strong> {formData.genre} {formData.prenom} {formData.nom}<br />
              <strong>CIN :</strong> {formData.cin}<br />
              <strong>Date de naissance :</strong> {formData.dateNaissance?.toLocaleDateString('fr-FR')}<br />
              <strong>Lieu de naissance :</strong> {formData.lieuNaissance}<br />
              <strong>Ville :</strong> {formData.ville}<br />
              <strong>Email :</strong> {formData.email}<br />
              <strong>Téléphone :</strong> {formData.telephone}
            </Typography>
          </Paper>
        </Grid>

        {/* Formation */}
        <Grid item xs={12} md={6}>
          <Paper sx={{ p: 2 }}>
            <Typography variant="subtitle1" color="primary" gutterBottom>
              Formation
            </Typography>
            <Typography variant="body2">
              <strong>Diplôme :</strong> {formData.diplomePrincipal}<br />
              <strong>Spécialité :</strong> {formData.specialiteDiplome}<br />
              <strong>Établissement :</strong> {formData.etablissement}<br />
              <strong>Année :</strong> {formData.anneeObtention}<br />
              <strong>CV :</strong> {cvFile ? cvFile.name : 'Non fourni'}
            </Typography>
          </Paper>
        </Grid>

        {/* Choix concours */}
        <Grid item xs={12}>
          <Paper sx={{ p: 2 }}>
            <Typography variant="subtitle1" color="primary" gutterBottom>
              Choix du concours
            </Typography>
            <Typography variant="body2">
              <strong>Concours :</strong> {selectedConcours?.nom}<br />
              <strong>Spécialité :</strong> {selectedSpecialite?.nom}<br />
              <strong>Centre d'examen :</strong> {selectedCentre?.nom} - {selectedCentre?.ville}
            </Typography>
          </Paper>
        </Grid>

        {/* Conditions d'utilisation */}
        <Grid item xs={12}>
          <FormControlLabel
            control={
              <Checkbox
                checked={formData.accepteConditions}
                onChange={(e) => handleInputChange('accepteConditions', e.target.checked)}
                color="primary"
              />
            }
            label={
              <Typography variant="body2">
                J'accepte les conditions d'utilisation et je certifie que les informations fournies sont exactes *
              </Typography>
            }
          />
          {!formData.accepteConditions && error && (
            <Typography color="error" variant="body2">
              Vous devez accepter les conditions pour continuer
            </Typography>
          )}
        </Grid>
      </Grid>
    );
  };

  if (loading && activeStep === 0) {
    return (
      <Box display="flex" justifyContent="center" alignItems="center" minHeight="50vh">
        <CircularProgress />
      </Box>
    );
  }

  return (
    <Container maxWidth="lg" sx={{ py: 4 }}>
      <Paper sx={{ p: 4 }}>
        <Typography variant="h4" gutterBottom align="center">
          Nouvelle Candidature
        </Typography>

        {/* Stepper */}
        <Stepper activeStep={activeStep} sx={{ mb: 4 }}>
          {steps.map((label) => (
            <Step key={label}>
              <StepLabel>{label}</StepLabel>
            </Step>
          ))}
        </Stepper>

        {/* Messages */}
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

        {/* Contenu de l'étape */}
        <Box sx={{ mb: 4 }}>
          {renderStepContent(activeStep)}
        </Box>

        {/* Boutons de navigation */}
        <Box sx={{ display: 'flex', justifyContent: 'space-between' }}>
          <Button
            disabled={activeStep === 0}
            onClick={handleBack}
            variant="outlined"
          >
            Précédent
          </Button>

          {activeStep === steps.length - 1 ? (
            <Button
              variant="contained"
              onClick={handleSubmit}
              disabled={loading || !formData.accepteConditions}
              startIcon={loading ? <CircularProgress size={20} /> : null}
            >
              {loading ? 'Soumission...' : 'Soumettre la candidature'}
            </Button>
          ) : (
            <Button
              variant="contained"
              onClick={handleNext}
              disabled={loading}
            >
              Suivant
            </Button>
          )}
        </Box>
      </Paper>
    </Container>
  );
};

export default CandidaturePageComplete;
