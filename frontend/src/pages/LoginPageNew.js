import React, { useState } from 'react';
import {
  Container,
  Paper,
  TextField,
  Button,
  Typography,
  Box,
  Alert,
  AppBar,
  Toolbar,
  CircularProgress
} from '@mui/material';
import { useNavigate } from 'react-router-dom';
import { useFormik } from 'formik';
import * as Yup from 'yup';
import axios from 'axios';

const LoginPage = () => {
  const navigate = useNavigate();
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);

  const validationSchema = Yup.object({
    email: Yup.string()
      .email('Email invalide')
      .required('Email requis'),
    password: Yup.string()
      .required('Mot de passe requis')
  });

  const formik = useFormik({
    initialValues: {
      email: '',
      password: ''
    },
    validationSchema,
    onSubmit: async (values) => {
      setLoading(true);
      setError('');
      
      try {
        const response = await axios.post('http://localhost:8080/api/auth/login', {
          email: values.email,
          password: values.password
        });

        if (response.data.success) {
          // Stocker les informations utilisateur
          localStorage.setItem('userRole', response.data.role);
          localStorage.setItem('userEmail', response.data.email);
          localStorage.setItem('userId', response.data.userId);
          localStorage.setItem('userName', `${response.data.prenom} ${response.data.nom}`);
          
          if (response.data.centreId) {
            localStorage.setItem('centreId', response.data.centreId);
            localStorage.setItem('centreNom', response.data.centreNom);
          }
          
          navigate('/dashboard');
        } else {
          setError(response.data.message || 'Erreur de connexion');
        }
      } catch (err) {
        console.error('Erreur de connexion:', err);
        if (err.response?.data?.message) {
          setError(err.response.data.message);
        } else {
          setError('Erreur de connexion. Vérifiez que le backend est démarré.');
        }
      } finally {
        setLoading(false);
      }
    }
  });

  return (
    <>
      <AppBar position="static">
        <Toolbar>
          <Typography variant="h6" component="div" sx={{ flexGrow: 1 }}>
            CandidaturePlus
          </Typography>
          <Button color="inherit" onClick={() => navigate('/')}>
            Retour Accueil
          </Button>
        </Toolbar>
      </AppBar>

      <Container maxWidth="sm" sx={{ mt: 8 }}>
        <Paper elevation={3} sx={{ p: 4 }}>
          <Typography variant="h4" component="h1" textAlign="center" gutterBottom>
            Connexion Gestionnaire
          </Typography>
          <Typography variant="body2" textAlign="center" color="text.secondary" sx={{ mb: 4 }}>
            Accédez à votre espace de gestion des candidatures
          </Typography>

          {error && (
            <Alert severity="error" sx={{ mb: 3 }}>
              {error}
            </Alert>
          )}

          <Box component="form" onSubmit={formik.handleSubmit}>
            <TextField
              fullWidth
              id="email"
              name="email"
              label="Email"
              type="email"
              value={formik.values.email}
              onChange={formik.handleChange}
              error={formik.touched.email && Boolean(formik.errors.email)}
              helperText={formik.touched.email && formik.errors.email}
              margin="normal"
            />

            <TextField
              fullWidth
              id="password"
              name="password"
              label="Mot de passe"
              type="password"
              value={formik.values.password}
              onChange={formik.handleChange}
              error={formik.touched.password && Boolean(formik.errors.password)}
              helperText={formik.touched.password && formik.errors.password}
              margin="normal"
            />

            <Button
              type="submit"
              fullWidth
              variant="contained"
              size="large"
              disabled={loading}
              sx={{ mt: 3, mb: 2 }}
            >
              {loading ? <CircularProgress size={24} /> : 'Se connecter'}
            </Button>
          </Box>

          <Box sx={{ mt: 3, p: 2, backgroundColor: 'grey.100', borderRadius: 1 }}>
            <Typography variant="subtitle2" gutterBottom>
              Comptes de test :
            </Typography>
            <Typography variant="body2" color="text.secondary">
              • h.alami@mf.gov.ma (Gestionnaire Local Casablanca)
            </Typography>
            <Typography variant="body2" color="text.secondary">
              • f.bennani@mf.gov.ma (Gestionnaire Local Rabat)
            </Typography>
            <Typography variant="body2" color="text.secondary">
              • m.chraibi@mf.gov.ma (Gestionnaire Global)
            </Typography>
            <Typography variant="body2" color="text.secondary">
              • a.talbi@mf.gov.ma (Administrateur)
            </Typography>
            <Typography variant="caption" color="text.secondary" sx={{ mt: 1, display: 'block' }}>
              Mot de passe : 1234 (pour tous les comptes de test)
            </Typography>
          </Box>
        </Paper>
      </Container>
    </>
  );
};

export default LoginPage;
