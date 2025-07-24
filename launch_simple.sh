#!/bin/bash

echo "==============================================="
echo "   CANDIDATURE PLUS - LANCEMENT SIMPLIFIE"
echo "==============================================="

# Aller dans le bon repertoire (ici, le dossier courant)
# cd "$(dirname "$0")"

echo "[1] Vérification du backend..."
if [ ! -f backend/target/candidatureplus-0.0.1-SNAPSHOT.jar ]; then
    echo "Backend non compilé. Compilation en cours..."
    cd backend
    mvn clean package -DskipTests
    if [ $? -ne 0 ]; then
        echo "ERREUR: Compilation échouée"
        exit 1
    fi
    cd ..
else
    echo "Backend déjà compilé."
fi

echo
echo "[2] Vérification du frontend..."
cd frontend
if [ ! -d node_modules ]; then
    echo "Installation des dépendances npm..."
    npm install
    if [ $? -ne 0 ]; then
        echo "ERREUR: Installation npm échouée"
        exit 1
    fi
else
    echo "Dépendances npm déjà installées."
fi
cd ..

echo
echo "[3] Démarrage des applications..."
echo
echo "BACKEND: http://localhost:8080"
echo "FRONTEND: http://localhost:3000"
echo "CREDENTIALS: admin / 1234"
echo

# Démarrer le backend
cd backend
echo "Démarrage du backend Spring Boot..."
nohup java -jar target/candidatureplus-0.0.1-SNAPSHOT.jar > backend.log 2>&1 &
BACKEND_PID=$!
cd ..

# Attente du backend (10 secondes)
echo "Attente du backend (10 secondes)..."
sleep 1

# Démarrer le frontend
cd frontend
echo "Démarrage du frontend React..."
nohup npm start > frontend.log 2>&1 &
FRONTEND_PID=$!
cd ..

echo
echo "==============================================="
echo "  APPLICATIONS LANCÉES AVEC SUCCÈS!"
echo "==============================================="
echo
echo "Ouverture du navigateur dans 10 secondes..."
sleep 1
open http://localhost:3000

echo
echo "Les applications sont maintenant actives:"
echo "- Backend: http://localhost:8080"
echo "- Frontend: http://localhost:3000"
echo
echo "Pour arrêter, utilisez 'kill $BACKEND_PID $FRONTEND_PID' ou fermez les terminaux correspondants."
echo
echo "Vérification de l'état des services:"
lsof -i :8080 | grep LISTEN && echo "✓ Backend actif sur port 8080" || echo "✗ Backend inactif"
lsof -i :3000 | grep LISTEN && echo "✓ Frontend actif sur port 3000" || echo "✗ Frontend en cours de démarrage..."
echo
