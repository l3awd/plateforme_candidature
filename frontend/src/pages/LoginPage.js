import React, { useState } from 'react';
import axios from 'axios';

// Configuration axios pour inclure les cookies de session
axios.defaults.withCredentials = true;
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
  MenuItem
} from '@mui/material';
import { useNavigate } from 'react-router-dom';
import { useFormik } from 'formik';
import * as Yup from 'yup';

const LoginPage = () => {
  const navigate = useNavigate();
  const [error, setError] = useState('');

  const validationSchema = Yup.object({
    email: Yup.string()
      .email('Email invalide')
      .required('Email requis'),
    password: Yup.string()
      .min(4, 'Le mot de passe doit contenir au moins 4 caractères')
      .required('Mot de passe requis')
  });

  const formik = useFormik({
    initialValues: {
      email: '',
      password: ''
    },
    validationSchema,
    onSubmit: async (values) => {
      try {
        // Appel à l'API d'authentification Spring Boot
        console.log('Tentative de connexion:', values);
        
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
          
          // Stocker le centreId si l'utilisateur en a un
          if (response.data.centreId) {
            localStorage.setItem('centreId', response.data.centreId);
            localStorage.setItem('centreNom', response.data.centreNom);
          }
          
          navigate('/dashboard');
        } else {
          setError(response.data.message || 'Identifiants incorrects');
        }
      } catch (err) {
        setError('Erreur de connexion. Veuillez réessayer.');
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
              sx={{ mt: 3, mb: 2 }}
              disabled={formik.isSubmitting}
            >
              Se connecter
            </Button>
          </Box>
        </Paper>
      </Container>
    </>
  );
};

export default LoginPage;
