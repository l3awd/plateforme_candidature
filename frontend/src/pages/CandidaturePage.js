import React, { useState, useEffect } from 'react';
import {
  Container,
  Typography,
  Button,
  Box,
  Grid,
  Paper,
  TextField,
  MenuItem,
  AppBar,
  Toolbar,
  Stepper,
  Step,
  StepLabel,
  Alert,
  CircularProgress,
  Divider,
  FormControlLabel,
  Checkbox,
  Autocomplete,
  FormControl,
  InputLabel,
  Select
} from '@mui/material';
import { useNavigate } from 'react-router-dom';
import { useFormik } from 'formik';
import * as Yup from 'yup';
import axios from 'axios';
import {
  PersonAdd as PersonAddIcon,
  Home as HomeIcon,
  School as SchoolIcon,
  Work as WorkIcon,
  Send as SendIcon
} from '@mui/icons-material';
import { VILLES_MAROC } from '../utils/villesMaroc';

const CandidaturePage = () => {
  const navigate = useNavigate();
  const [activeStep, setActiveStep] = useState(0);
  const [concours, setConcours] = useState([]);
  const [specialites, setSpecialites] = useState([]);
  const [centres, setCentres] = useState([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  const [success, setSuccess] = useState('');

  const steps = [
    'Informations Personnelles',
    'Formation et Diplômes',
    'Choix du Concours',
    'Confirmation'
  ];

  // Chargement des données
  useEffect(() => {
    const loadData = async () => {
      try {
        const [concoursRes, specialitesRes, centresRes] = await Promise.all([
          axios.get('http://localhost:8080/api/concours'),
          axios.get('http://localhost:8080/api/specialites'),
          axios.get('http://localhost:8080/api/centres')
        ]);
        
        // Validation des données reçues
        const concoursData = Array.isArray(concoursRes.data) ? concoursRes.data : [];
        const specialitesData = Array.isArray(specialitesRes.data) ? specialitesRes.data : [];
        const centresData = Array.isArray(centresRes.data) ? centresRes.data : [];
        
        setConcours(concoursData);
        setSpecialites(specialitesData);
        setCentres(centresData);
        
      } catch (err) {
        console.error('Erreur lors du chargement:', err);
        setError('Erreur lors du chargement des données. Vérifiez que le backend est démarré.');
        // Initialiser avec des tableaux vides en cas d'erreur
        setConcours([]);
        setSpecialites([]);
        setCentres([]);
      }
    };
    loadData();
  }, []);

  // Validation des étapes
  const getValidationSchema = (step) => {
    switch (step) {
      case 0:
        return Yup.object({
          nom: Yup.string().required('Nom requis'),
          prenom: Yup.string().required('Prénom requis'),
          genre: Yup.string().required('Civilité requise'),
          cin: Yup.string().required('CIN requis'),
          dateNaissance: Yup.date().required('Date de naissance requise'),
          lieuNaissance: Yup.string().required('Lieu de naissance requis'),
          ville: Yup.string().required('Ville requise'),
          email: Yup.string().email('Email invalide').required('Email requis'),
          telephone: Yup.string().required('Téléphone requis')
        });
      case 1:
        return Yup.object({
          niveauEtudes: Yup.string().required('Niveau d\'études requis'),
          diplomePrincipal: Yup.string().required('Diplôme principal requis'),
          specialiteDiplome: Yup.string().required('Spécialité du diplôme requise'),
          etablissement: Yup.string().required('Établissement requis'),
          anneeObtention: Yup.number().required('Année d\'obtention requise')
        });
      case 2:
        return Yup.object({
          concoursId: Yup.string().required('Concours requis'),
          specialiteId: Yup.string().required('Spécialité requise'),
          centreId: Yup.string().required('Centre requis'),
          conditionsAcceptees: Yup.boolean().oneOf([true], 'Vous devez accepter les conditions')
        });
      default:
        return Yup.object({});
    }
  };

  const formik = useFormik({
    initialValues: {
      // Informations personnelles
      nom: '',
      prenom: '',
      genre: '',
      cin: '',
      dateNaissance: '',
      lieuNaissance: '',
      ville: '',
      email: '',
      telephone: '',
      telephoneUrgence: '',
      
      // Formation
      niveauEtudes: '',
      diplomePrincipal: '',
      specialiteDiplome: '',
      etablissement: '',
      anneeObtention: '',
      experienceProfessionnelle: '',
      
      // Candidature
      concoursId: '',
      specialiteId: '',
      centreId: '',
      conditionsAcceptees: false
    },
    validationSchema: getValidationSchema(activeStep),
    onSubmit: async (values) => {
      if (activeStep < steps.length - 1) {
        setActiveStep(activeStep + 1);
      } else {
        await handleSubmitCandidature(values);
      }
    },
  });

  const handleSubmitCandidature = async (values) => {
    setLoading(true);
    setError('');
    
    try {
      const response = await axios.post('http://localhost:8080/api/candidatures/soumettre', {
        candidat: {
          nom: values.nom,
          prenom: values.prenom,
          genre: values.genre,
          cin: values.cin,
          dateNaissance: values.dateNaissance,
          lieuNaissance: values.lieuNaissance,
          ville: values.ville,
          email: values.email,
          telephone: values.telephone,
          telephoneUrgence: values.telephoneUrgence,
          niveauEtudes: values.niveauEtudes,
          diplomePrincipal: values.diplomePrincipal,
          specialiteDiplome: values.specialiteDiplome,
          etablissement: values.etablissement,
          anneeObtention: values.anneeObtention,
          experienceProfessionnelle: values.experienceProfessionnelle,
          conditionsAcceptees: values.conditionsAcceptees
        },
        concoursId: values.concoursId,
        specialiteId: values.specialiteId,
        centreId: values.centreId
      });

      setSuccess(`Candidature soumise avec succès ! Votre numéro unique est : ${response.data.numeroUnique}`);
      
      // Redirection après 3 secondes
      setTimeout(() => {
        navigate('/suivi', { 
          state: { numeroUnique: response.data.numeroUnique }
        });
      }, 3000);
      
    } catch (err) {
      setError(err.response?.data?.message || 'Erreur lors de la soumission');
    } finally {
      setLoading(false);
    }
  };

  const handleNext = () => {
    formik.handleSubmit();
  };

  const handleBack = () => {
    setActiveStep(activeStep - 1);
  };

  const renderStepContent = (step) => {
    switch (step) {
      case 0:
        return (
          <Grid container spacing={3}>
            <Grid item xs={12} md={6}>
              <TextField
                fullWidth
                name="nom"
                label="Nom *"
                value={formik.values.nom}
                onChange={formik.handleChange}
                error={formik.touched.nom && Boolean(formik.errors.nom)}
                helperText={formik.touched.nom && formik.errors.nom}
              />
            </Grid>
            <Grid item xs={12} md={6}>
              <TextField
                fullWidth
                name="prenom"
                label="Prénom *"
                value={formik.values.prenom}
                onChange={formik.handleChange}
                error={formik.touched.prenom && Boolean(formik.errors.prenom)}
                helperText={formik.touched.prenom && formik.errors.prenom}
              />
            </Grid>
            <Grid item xs={12} md={6}>
              <FormControl fullWidth error={formik.touched.genre && Boolean(formik.errors.genre)}>
                <InputLabel>Civilité *</InputLabel>
                <Select
                  name="genre"
                  value={formik.values.genre}
                  onChange={formik.handleChange}
                  label="Civilité *"
                >
                  <MenuItem value="Masculin">Monsieur</MenuItem>
                  <MenuItem value="Feminin">Madame</MenuItem>
                </Select>
                {formik.touched.genre && formik.errors.genre && (
                  <Typography variant="caption" color="error" sx={{ mt: 0.5, ml: 2 }}>
                    {formik.errors.genre}
                  </Typography>
                )}
              </FormControl>
            </Grid>
            <Grid item xs={12} md={6}>
              <TextField
                fullWidth
                name="cin"
                label="Numéro CIN *"
                value={formik.values.cin}
                onChange={formik.handleChange}
                error={formik.touched.cin && Boolean(formik.errors.cin)}
                helperText={formik.touched.cin && formik.errors.cin}
                placeholder="Ex: AB123456"
              />
            </Grid>
            <Grid item xs={12} md={6}>
              <TextField
                fullWidth
                name="dateNaissance"
                label="Date de naissance *"
                type="date"
                InputLabelProps={{ shrink: true }}
                value={formik.values.dateNaissance}
                onChange={formik.handleChange}
                error={formik.touched.dateNaissance && Boolean(formik.errors.dateNaissance)}
                helperText={formik.touched.dateNaissance && formik.errors.dateNaissance}
              />
            </Grid>
            <Grid item xs={12} md={6}>
              <TextField
                fullWidth
                name="lieuNaissance"
                label="Lieu de naissance *"
                value={formik.values.lieuNaissance}
                onChange={formik.handleChange}
                error={formik.touched.lieuNaissance && Boolean(formik.errors.lieuNaissance)}
                helperText={formik.touched.lieuNaissance && formik.errors.lieuNaissance}
              />
            </Grid>
            <Grid item xs={12} md={6}>
              <Autocomplete
                fullWidth
                options={VILLES_MAROC}
                value={formik.values.ville}
                onChange={(event, newValue) => {
                  formik.setFieldValue('ville', newValue || '');
                }}
                renderInput={(params) => (
                  <TextField
                    {...params}
                    name="ville"
                    label="Ville de résidence *"
                    error={formik.touched.ville && Boolean(formik.errors.ville)}
                    helperText={formik.touched.ville && formik.errors.ville}
                    placeholder="Sélectionnez votre ville"
                  />
                )}
              />
            </Grid>
            <Grid item xs={12} md={6}>
              <TextField
                fullWidth
                name="email"
                label="Adresse e-mail *"
                type="email"
                value={formik.values.email}
                onChange={formik.handleChange}
                error={formik.touched.email && Boolean(formik.errors.email)}
                helperText={formik.touched.email && formik.errors.email}
                placeholder="votre.email@example.com"
              />
            </Grid>
            <Grid item xs={12} md={6}>
              <TextField
                fullWidth
                name="telephone"
                label="Numéro de téléphone *"
                value={formik.values.telephone}
                onChange={formik.handleChange}
                error={formik.touched.telephone && Boolean(formik.errors.telephone)}
                helperText={formik.touched.telephone && formik.errors.telephone}
                placeholder="06XXXXXXXX"
              />
            </Grid>
            <Grid item xs={12} md={6}>
              <TextField
                fullWidth
                name="telephoneUrgence"
                label="Téléphone d'urgence (optionnel)"
                value={formik.values.telephoneUrgence}
                onChange={formik.handleChange}
                placeholder="Contact en cas d'urgence"
              />
            </Grid>
          </Grid>
        );

      case 1:
        return (
          <Grid container spacing={3}>
            <Grid item xs={12} md={6}>
              <TextField
                fullWidth
                select
                name="niveauEtudes"
                label="Niveau d'études *"
                value={formik.values.niveauEtudes}
                onChange={formik.handleChange}
                error={formik.touched.niveauEtudes && Boolean(formik.errors.niveauEtudes)}
                helperText={formik.touched.niveauEtudes && formik.errors.niveauEtudes}
              >
                <MenuItem value="Bac+2">Bac+2 (DUT/BTS)</MenuItem>
                <MenuItem value="Bac+3">Bac+3 (Licence/LP)</MenuItem>
                <MenuItem value="Bac+5">Bac+5 (Master/Ingénieur)</MenuItem>
                <MenuItem value="Bac+8">Bac+8 (Doctorat)</MenuItem>
              </TextField>
            </Grid>
            <Grid item xs={12} md={6}>
              <TextField
                fullWidth
                name="anneeObtention"
                label="Année d'obtention *"
                type="number"
                value={formik.values.anneeObtention}
                onChange={formik.handleChange}
                error={formik.touched.anneeObtention && Boolean(formik.errors.anneeObtention)}
                helperText={formik.touched.anneeObtention && formik.errors.anneeObtention}
                inputProps={{ min: 1980, max: new Date().getFullYear() }}
                placeholder="Ex: 2023"
              />
            </Grid>
            <Grid item xs={12}>
              <TextField
                fullWidth
                name="diplomePrincipal"
                label="Intitulé du diplôme *"
                value={formik.values.diplomePrincipal}
                onChange={formik.handleChange}
                error={formik.touched.diplomePrincipal && Boolean(formik.errors.diplomePrincipal)}
                helperText={formik.touched.diplomePrincipal && formik.errors.diplomePrincipal}
                placeholder="Ex: Master en Sciences Économiques"
              />
            </Grid>
            <Grid item xs={12} md={6}>
              <TextField
                fullWidth
                name="specialiteDiplome"
                label="Spécialité du diplôme *"
                value={formik.values.specialiteDiplome}
                onChange={formik.handleChange}
                error={formik.touched.specialiteDiplome && Boolean(formik.errors.specialiteDiplome)}
                helperText={formik.touched.specialiteDiplome && formik.errors.specialiteDiplome}
                placeholder="Ex: Finance et Comptabilité"
              />
            </Grid>
            <Grid item xs={12} md={6}>
              <TextField
                fullWidth
                name="etablissement"
                label="Établissement d'obtention *"
                value={formik.values.etablissement}
                onChange={formik.handleChange}
                error={formik.touched.etablissement && Boolean(formik.errors.etablissement)}
                helperText={formik.touched.etablissement && formik.errors.etablissement}
                placeholder="Ex: Université Mohammed V"
              />
            </Grid>
            <Grid item xs={12}>
              <TextField
                fullWidth
                name="experienceProfessionnelle"
                label="Expérience professionnelle (optionnel)"
                multiline
                rows={3}
                placeholder="Décrivez brièvement votre expérience professionnelle pertinente"
                value={formik.values.experienceProfessionnelle}
                onChange={formik.handleChange}
              />
            </Grid>
          </Grid>
        );

      case 2:
        return (
          <Grid container spacing={3}>
            <Grid item xs={12}>
              <TextField
                fullWidth
                select
                name="concoursId"
                label="Concours *"
                value={formik.values.concoursId}
                onChange={formik.handleChange}
                error={formik.touched.concoursId && Boolean(formik.errors.concoursId)}
                helperText={formik.touched.concoursId && formik.errors.concoursId}
              >
                {concours.map((c) => (
                  <MenuItem key={c.id} value={c.id}>
                    {c.nom} - {c.description}
                  </MenuItem>
                ))}
              </TextField>
            </Grid>
            <Grid item xs={12} md={6}>
              <TextField
                fullWidth
                select
                name="specialiteId"
                label="Spécialité *"
                value={formik.values.specialiteId}
                onChange={formik.handleChange}
                error={formik.touched.specialiteId && Boolean(formik.errors.specialiteId)}
                helperText={formik.touched.specialiteId && formik.errors.specialiteId}
              >
                {specialites.map((s) => (
                  <MenuItem key={s.id} value={s.id}>
                    {s.nom} ({s.code})
                  </MenuItem>
                ))}
              </TextField>
            </Grid>
            <Grid item xs={12} md={6}>
              <TextField
                fullWidth
                select
                name="centreId"
                label="Centre d'examen *"
                value={formik.values.centreId}
                onChange={formik.handleChange}
                error={formik.touched.centreId && Boolean(formik.errors.centreId)}
                helperText={formik.touched.centreId && formik.errors.centreId}
              >
                {centres.map((c) => (
                  <MenuItem key={c.id} value={c.id}>
                    {c.nom} - {c.ville}
                  </MenuItem>
                ))}
              </TextField>
            </Grid>
            <Grid item xs={12}>
              <FormControlLabel
                control={
                  <Checkbox
                    name="conditionsAcceptees"
                    checked={formik.values.conditionsAcceptees}
                    onChange={formik.handleChange}
                  />
                }
                label="J'accepte les conditions de participation au concours *"
              />
              {formik.touched.conditionsAcceptees && formik.errors.conditionsAcceptees && (
                <Typography color="error" variant="body2">
                  {formik.errors.conditionsAcceptees}
                </Typography>
              )}
            </Grid>
          </Grid>
        );

      case 3:
        return (
          <Box>
            <Typography variant="h6" gutterBottom>
              Récapitulatif de votre candidature
            </Typography>
            <Divider sx={{ my: 2 }} />
            
            <Typography variant="subtitle1" gutterBottom>
              <strong>Informations personnelles :</strong>
            </Typography>
            <Typography>
              {formik.values.prenom} {formik.values.nom} - {formik.values.genre === 'Masculin' ? 'Monsieur' : 'Madame'} - CIN: {formik.values.cin}
            </Typography>
            <Typography>
              Email: {formik.values.email} - Tél: {formik.values.telephone}
            </Typography>
            <Typography sx={{ mb: 2 }}>
              Ville: {formik.values.ville}
            </Typography>
            
            <Typography variant="subtitle1" gutterBottom>
              <strong>Formation :</strong>
            </Typography>
            <Typography>
              {formik.values.niveauEtudes} - {formik.values.diplomePrincipal}
            </Typography>
            <Typography sx={{ mb: 2 }}>
              Spécialité: {formik.values.specialiteDiplome} - {formik.values.etablissement} ({formik.values.anneeObtention})
            </Typography>
            
            <Typography variant="subtitle1" gutterBottom>
              <strong>Candidature :</strong>
            </Typography>
            <Typography>
              Concours: {concours.find(c => c.id == formik.values.concoursId)?.nom}
            </Typography>
            <Typography>
              Spécialité: {specialites.find(s => s.id == formik.values.specialiteId)?.nom}
            </Typography>
            <Typography>
              Centre: {centres.find(c => c.id == formik.values.centreId)?.nom}
            </Typography>
          </Box>
        );

      default:
        return 'Étape inconnue';
    }
  };

  return (
    <>
      <AppBar position="static">
        <Toolbar>
          <PersonAddIcon sx={{ mr: 2 }} />
          <Typography variant="h6" component="div" sx={{ flexGrow: 1 }}>
            Nouvelle Candidature
          </Typography>
          <Button color="inherit" onClick={() => navigate('/')} startIcon={<HomeIcon />}>
            Accueil
          </Button>
        </Toolbar>
      </AppBar>

      <Container maxWidth="lg" sx={{ mt: 4, mb: 4 }}>
        {success && (
          <Alert severity="success" sx={{ mb: 3 }}>
            {success}
          </Alert>
        )}

        {error && (
          <Alert severity="error" sx={{ mb: 3 }}>
            {error}
          </Alert>
        )}

        <Paper sx={{ p: 4 }}>
          <Typography variant="h4" component="h1" gutterBottom>
            Formulaire de Candidature
          </Typography>
          
          <Stepper activeStep={activeStep} sx={{ mb: 4 }}>
            {steps.map((label) => (
              <Step key={label}>
                <StepLabel>{label}</StepLabel>
              </Step>
            ))}
          </Stepper>

          <Box component="form" onSubmit={formik.handleSubmit}>
            {renderStepContent(activeStep)}

            <Box sx={{ display: 'flex', justifyContent: 'space-between', mt: 4 }}>
              <Button
                disabled={activeStep === 0}
                onClick={handleBack}
                variant="outlined"
              >
                Précédent
              </Button>
              
              <Button
                onClick={handleNext}
                variant="contained"
                disabled={loading}
                startIcon={loading ? <CircularProgress size={20} /> : (activeStep === steps.length - 1 ? <SendIcon /> : null)}
              >
                {activeStep === steps.length - 1 ? 'Soumettre' : 'Suivant'}
              </Button>
            </Box>
          </Box>
        </Paper>
      </Container>
    </>
  );
};

export default CandidaturePage;
