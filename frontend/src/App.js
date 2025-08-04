import React from 'react';
import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import { ThemeProvider, createTheme } from '@mui/material/styles';
import CssBaseline from '@mui/material/CssBaseline';
import HomePage from './pages/HomePage';
import LoginPage from './pages/LoginPageNew';
import CandidaturePage from './pages/CandidaturePage';
import CandidaturePageComplete from './pages/CandidaturePageComplete';
import SuiviCandidaturePage from './pages/SuiviCandidaturePage';
import PostesPage from './pages/PostesPage';
import PostesPageComplete from './pages/PostesPageComplete';
import PostesPageModerne from './pages/PostesPageModerne';
import Dashboard from './pages/Dashboard';
import GestionCandidatures from './pages/GestionCandidatures';
import GestionCandidaturesComplete from './pages/GestionCandidaturesComplete';

// Thème Material-UI personnalisé
const theme = createTheme({
  palette: {
    primary: {
      main: '#1976d2',
    },
    secondary: {
      main: '#dc004e',
    },
  },
});

function App() {
  return (
    <ThemeProvider theme={theme}>
      <CssBaseline />
      <Router>
        <div className="App">
          <Routes>
            <Route path="/" element={<HomePage />} />
            <Route path="/login" element={<LoginPage />} />
            <Route path="/candidature" element={<CandidaturePage />} />
            <Route path="/candidature-complete" element={<CandidaturePageComplete />} />
            <Route path="/suivi" element={<SuiviCandidaturePage />} />
            <Route path="/postes" element={<PostesPage />} />
            <Route path="/postes-complete" element={<PostesPageComplete />} />
            <Route path="/postes-moderne" element={<PostesPageModerne />} />
            <Route path="/dashboard" element={<Dashboard />} />
            <Route path="/gestion-candidatures" element={<GestionCandidaturesComplete />} />
            <Route path="/gestion-candidatures-old" element={<GestionCandidatures />} />
          </Routes>
        </div>
      </Router>
    </ThemeProvider>
  );
}

export default App;
