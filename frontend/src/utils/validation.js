// Utilitaires de validation pour les champs du formulaire

export const REGEX_PATTERNS = {
  // CIN : 1-2 lettres suivies de 5-6 chiffres (ex: BE123456, A12345)
  CIN: /^[A-Za-z]{1,2}\d{5,6}$/,
  
  // Téléphone : commence par 06 ou 07 suivi de 8 chiffres
  TELEPHONE: /^(06|07)\d{8}$/,
  
  // Email : format email standard
  EMAIL: /^[^\s@]+@[^\s@]+\.[^\s@]+$/,
  
  // Nom/Prénom : lettres, espaces, tirets, apostrophes uniquement
  NOM_PRENOM: /^[a-zA-ZàáâäèéêëìíîïòóôöùúûüñçÀÁÂÄÈÉÊËÌÍÎÏÒÓÔÖÙÚÛÜÑÇ\s\-']+$/,
  
  // Numéro de place : format PLACE-YYYYMMDD-XXX
  NUMERO_PLACE: /^PLACE-\d{8}-\d{3}$/,
  
  // Numéro unique candidature : CAND-YYYY-XXXXXX
  NUMERO_UNIQUE: /^CAND-\d{4}-\d{6}$/
};

export const MESSAGES_VALIDATION = {
  CIN: 'Le CIN doit contenir 1 à 2 lettres suivies de 5 à 6 chiffres (ex: BE123456)',
  TELEPHONE: 'Le numéro de téléphone doit commencer par 06 ou 07 suivi de 8 chiffres',
  EMAIL: 'Format d\'email invalide',
  NOM_PRENOM: 'Seules les lettres, espaces, tirets et apostrophes sont autorisés',
  ANNEE_OBTENTION: 'L\'année doit être comprise entre 1980 et l\'année actuelle',
  DATE_NAISSANCE: 'Vous devez avoir au moins 18 ans',
  TELEPHONE_URGENCE: 'Format invalide (optionnel mais doit être valide si renseigné)'
};

export const validateCIN = (cin) => {
  if (!cin) return 'CIN requis';
  if (!REGEX_PATTERNS.CIN.test(cin)) {
    return MESSAGES_VALIDATION.CIN;
  }
  return '';
};

export const validateTelephone = (telephone) => {
  if (!telephone) return 'Téléphone requis';
  if (!REGEX_PATTERNS.TELEPHONE.test(telephone)) {
    return MESSAGES_VALIDATION.TELEPHONE;
  }
  return '';
};

export const validateTelephoneUrgence = (telephone) => {
  if (!telephone) return ''; // Optionnel
  if (!REGEX_PATTERNS.TELEPHONE.test(telephone)) {
    return MESSAGES_VALIDATION.TELEPHONE_URGENCE;
  }
  return '';
};

export const validateEmail = (email) => {
  if (!email) return 'Email requis';
  if (!REGEX_PATTERNS.EMAIL.test(email)) {
    return MESSAGES_VALIDATION.EMAIL;
  }
  return '';
};

export const validateNomPrenom = (value, field) => {
  if (!value) return `${field} requis`;
  if (!REGEX_PATTERNS.NOM_PRENOM.test(value)) {
    return MESSAGES_VALIDATION.NOM_PRENOM;
  }
  return '';
};

export const validateDateNaissance = (date) => {
  if (!date) return 'Date de naissance requise';
  
  const naissance = new Date(date);
  const aujourdhui = new Date();
  const age = aujourdhui.getFullYear() - naissance.getFullYear();
  const moisDiff = aujourdhui.getMonth() - naissance.getMonth();
  
  if (moisDiff < 0 || (moisDiff === 0 && aujourdhui.getDate() < naissance.getDate())) {
    age--;
  }
  
  if (age < 18) {
    return MESSAGES_VALIDATION.DATE_NAISSANCE;
  }
  
  return '';
};

export const validateAnneeObtention = (annee) => {
  if (!annee) return 'Année d\'obtention requise';
  
  const currentYear = new Date().getFullYear();
  const anneeNum = parseInt(annee);
  
  if (anneeNum < 1980 || anneeNum > currentYear) {
    return MESSAGES_VALIDATION.ANNEE_OBTENTION;
  }
  
  return '';
};
