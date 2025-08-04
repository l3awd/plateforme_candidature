// Utilitaires de validation pour CandidaturePlus
export const validateCIN = (cin) => {
  if (!cin || cin.trim() === '') {
    return 'Le CIN est obligatoire';
  }
  
  // Format: 1-2 lettres + 5-6 chiffres (ex: A123456, AB123456, BE123456)
  const cinRegex = /^[A-Za-z]{1,2}\d{5,6}$/;
  if (!cinRegex.test(cin.trim())) {
    return 'Format CIN invalide. Exemple: A123456 ou AB123456';
  }
  
  return null;
};

export const validateTelephone = (telephone) => {
  if (!telephone || telephone.trim() === '') {
    return 'Le numéro de téléphone est obligatoire';
  }
  
  // Format: 06 ou 07 + 8 chiffres
  const phoneRegex = /^(06|07)\d{8}$/;
  if (!phoneRegex.test(telephone.replace(/\s/g, ''))) {
    return 'Format téléphone invalide. Doit commencer par 06 ou 07 suivi de 8 chiffres';
  }
  
  return null;
};

export const validateTelephoneUrgence = (telephone) => {
  if (!telephone || telephone.trim() === '') {
    return null; // Optionnel
  }
  
  // Format: 05, 06, 07 + 8 chiffres
  const phoneRegex = /^(05|06|07)\d{8}$/;
  if (!phoneRegex.test(telephone.replace(/\s/g, ''))) {
    return 'Format téléphone invalide. Doit commencer par 05, 06 ou 07 suivi de 8 chiffres';
  }
  
  return null;
};

export const validateEmail = (email) => {
  if (!email || email.trim() === '') {
    return 'L\'adresse email est obligatoire';
  }
  
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  if (!emailRegex.test(email)) {
    return 'Format email invalide';
  }
  
  return null;
};

export const validateNomPrenom = (value, fieldName) => {
  if (!value || value.trim() === '') {
    return `${fieldName} est obligatoire`;
  }
  
  // Minimum 2 caractères, que des lettres, espaces, tirets et apostrophes
  const nameRegex = /^[a-zA-ZÀ-ÿ\s'-]{2,}$/;
  if (!nameRegex.test(value.trim())) {
    return `${fieldName} doit contenir au moins 2 caractères et uniquement des lettres`;
  }
  
  return null;
};

export const validateDateNaissance = (date) => {
  if (!date) {
    return 'La date de naissance est obligatoire';
  }
  
  const today = new Date();
  const birthDate = new Date(date);
  const age = today.getFullYear() - birthDate.getFullYear();
  const monthDiff = today.getMonth() - birthDate.getMonth();
  
  if (monthDiff < 0 || (monthDiff === 0 && today.getDate() < birthDate.getDate())) {
    age--;
  }
  
  if (age < 18) {
    return 'Vous devez avoir au moins 18 ans';
  }
  
  if (age > 65) {
    return 'L\'âge maximum autorisé est 65 ans';
  }
  
  return null;
};

export const validateAnneeObtention = (annee) => {
  if (!annee) {
    return 'L\'année d\'obtention est obligatoire';
  }
  
  const currentYear = new Date().getFullYear();
  const year = parseInt(annee);
  
  if (year < 1990) {
    return 'L\'année doit être supérieure à 1990';
  }
  
  if (year > currentYear) {
    return 'L\'année ne peut pas être dans le futur';
  }
  
  return null;
};

export const validateCV = (file) => {
  if (!file) {
    return 'Le CV est obligatoire';
  }
  
  // Taille max: 5MB
  const maxSize = 5 * 1024 * 1024;
  if (file.size > maxSize) {
    return 'Le fichier CV ne doit pas dépasser 5MB';
  }
  
  // Types autorisés
  const allowedTypes = [
    'application/pdf',
    'application/msword',
    'application/vnd.openxmlformats-officedocument.wordprocessingml.document'
  ];
  
  if (!allowedTypes.includes(file.type)) {
    return 'Format de fichier non autorisé. Utilisez PDF, DOC ou DOCX';
  }
  
  return null;
};

export const validateRequiredField = (value, fieldName) => {
  if (!value || (typeof value === 'string' && value.trim() === '')) {
    return `${fieldName} est obligatoire`;
  }
  return null;
};

// Fonction de validation globale pour un formulaire
export const validateForm = (formData, step = 'all') => {
  const errors = {};
  
  if (step === 'all' || step === 0) {
    // Étape 1: Informations personnelles
    errors.nom = validateNomPrenom(formData.nom, 'Nom');
    errors.prenom = validateNomPrenom(formData.prenom, 'Prénom');
    errors.cin = validateCIN(formData.cin);
    errors.email = validateEmail(formData.email);
    errors.telephone = validateTelephone(formData.telephone);
    errors.telephoneUrgence = validateTelephoneUrgence(formData.telephoneUrgence);
    errors.dateNaissance = validateDateNaissance(formData.dateNaissance);
    errors.lieuNaissance = validateRequiredField(formData.lieuNaissance, 'Lieu de naissance');
    errors.ville = validateRequiredField(formData.ville, 'Ville de résidence');
    errors.genre = validateRequiredField(formData.genre, 'Civilité');
  }
  
  if (step === 'all' || step === 1) {
    // Étape 2: Formation
    errors.diplomePrincipal = validateRequiredField(formData.diplomePrincipal, 'Diplôme principal');
    errors.specialiteDiplome = validateRequiredField(formData.specialiteDiplome, 'Spécialité du diplôme');
    errors.etablissement = validateRequiredField(formData.etablissement, 'Établissement');
    errors.anneeObtention = validateAnneeObtention(formData.anneeObtention);
  }
  
  if (step === 'all' || step === 2) {
    // Étape 3: Choix concours
    errors.concoursId = validateRequiredField(formData.concoursId, 'Concours');
    errors.specialiteId = validateRequiredField(formData.specialiteId, 'Spécialité');
    errors.centreId = validateRequiredField(formData.centreId, 'Centre d\'examen');
  }
  
  // Filtrer les erreurs null/undefined
  Object.keys(errors).forEach(key => {
    if (!errors[key]) {
      delete errors[key];
    }
  });
  
  return errors;
};

export const formatTelephone = (value) => {
  // Supprimer tous les caractères non-numériques
  const numbers = value.replace(/\D/g, '');
  
  // Formater avec espaces (ex: 06 12 34 56 78)
  if (numbers.length >= 2) {
    return numbers.replace(/(\d{2})(\d{2})(\d{2})(\d{2})(\d{2})/, '$1 $2 $3 $4 $5');
  }
  
  return numbers;
};

export const formatCIN = (value) => {
  // Convertir en majuscules et supprimer les espaces
  return value.toUpperCase().replace(/\s/g, '');
};
