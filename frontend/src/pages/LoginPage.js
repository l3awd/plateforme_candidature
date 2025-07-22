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
      .min(6, 'Le mot de passe doit contenir au moins 6 caractères')
      .required('Mot de passe requis'),
    role: Yup.string()
      .required('Rôle requis')
  });

  const formik = useFormik({
    initialValues: {
      email: '',
      password: '',
      role: ''
    },
    validationSchema,
    onSubmit: async (values) => {
      try {
        // TODO: Implémenter l'authentification avec votre API Spring Boot
        console.log('Tentative de connexion:', values);
        
        // Simulation de l'authentification
        if (values.email && values.password) {
          localStorage.setItem('userRole', values.role);
          localStorage.setItem('userEmail', values.email);
          navigate('/dashboard');
        } else {
          setError('Identifiants incorrects');
        }
      } catch (err) {
        setError('Erreur de connexion. Veuillez réessayer.');
      }
    }
  });

  const roles = [
    { value: 'GestionnaireLocal', label: 'Gestionnaire Local' },
    { value: 'GestionnaireGlobal', label: 'Gestionnaire Global' },
    { value: 'Administrateur', label: 'Administrateur' }
  ];

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

            <TextField
              fullWidth
              select
              id="role"
              name="role"
              label="Rôle"
              value={formik.values.role}
              onChange={formik.handleChange}
              error={formik.touched.role && Boolean(formik.errors.role)}
              helperText={formik.touched.role && formik.errors.role}
              margin="normal"
            >
              {roles.map((option) => (
                <MenuItem key={option.value} value={option.value}>
                  {option.label}
                </MenuItem>
              ))}
            </TextField>

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
