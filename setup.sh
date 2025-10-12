#!/bin/bash
set -e

echo "🚀 ClientXCMS DevContainer - Script d'initialisation"
echo "=================================================="

# Vérifier que nous sommes dans le bon répertoire
cd /workspaces/laravel

# Copier le fichier .env s'il n'existe pas
if [ ! -f .env ]; then
    echo "📝 Création du fichier .env..."
    cp .env.example .env

    # Configurer les variables spécifiques au devcontainer
    sed -i 's/DB_CONNECTION=.*/DB_CONNECTION=mysql/' .env
    sed -i 's/DB_HOST=.*/DB_HOST=mariadb/' .env
    sed -i 's/DB_PORT=.*/DB_PORT=3306/' .env
    sed -i 's/DB_DATABASE=.*/DB_DATABASE=clientxcms/' .env
    sed -i 's/DB_USERNAME=.*/DB_USERNAME=clientxcms/' .env
    sed -i 's/DB_PASSWORD=.*/DB_PASSWORD=clientxcms/' .env

    # Configuration Redis
    sed -i 's/REDIS_HOST=.*/REDIS_HOST=redis/' .env
    sed -i 's/REDIS_PASSWORD=.*/REDIS_PASSWORD=null/' .env
    sed -i 's/REDIS_PORT=.*/REDIS_PORT=6379/' .env

    # Configuration Queue en mode database
    sed -i 's/QUEUE_CONNECTION=.*/QUEUE_CONNECTION=database/' .env
    sed -i 's/CACHE_DRIVER=.*/CACHE_DRIVER=redis/' .env
    sed -i 's/SESSION_DRIVER=.*/SESSION_DRIVER=redis/' .env

    # Configuration APP
    sed -i 's/APP_URL=.*/APP_URL=http:\/\/localhost/' .env
    sed -i 's/APP_ENV=.*/APP_ENV=local/' .env
    sed -i 's/APP_DEBUG=.*/APP_DEBUG=true/' .env

    # Configuration Mail (Mailpit)
    sed -i 's/MAIL_MAILER=.*/MAIL_MAILER=smtp/' .env
    sed -i 's/MAIL_HOST=.*/MAIL_HOST=mailpit/' .env
    sed -i 's/MAIL_PORT=.*/MAIL_PORT=1025/' .env
    sed -i 's/MAIL_USERNAME=.*/MAIL_USERNAME=null/' .env
    sed -i 's/MAIL_PASSWORD=.*/MAIL_PASSWORD=null/' .env
    sed -i 's/MAIL_ENCRYPTION=.*/MAIL_ENCRYPTION=null/' .env

    echo "✅ Fichier .env configuré pour le devcontainer"
else
    echo "ℹ️  Fichier .env existant - conservé"
fi

# Installation des dépendances PHP
if [ ! -d "vendor" ]; then
    echo "📦 Installation des dépendances Composer..."
    composer install --no-interaction --prefer-dist --optimize-autoloader
    echo "✅ Dépendances PHP installées"
else
    echo "ℹ️  Dépendances Composer déjà installées"
fi

# Installation des dépendances Node
if [ ! -d "node_modules" ]; then
    echo "📦 Installation des dépendances NPM..."
    npm install
    echo "✅ Dépendances Node installées"
else
    echo "ℹ️  Dépendances NPM déjà installées"
fi

# Build des assets
echo "🏗️  Build des assets frontend..."
npm run build
echo "✅ Assets compilés"

# Générer la clé d'application si nécessaire
if ! grep -q "^APP_KEY=base64:" .env; then
    echo "🔑 Génération de la clé d'application..."
    php artisan key:generate
    echo "✅ Clé d'application générée"
fi

# Attendre que la base de données soit prête
echo "⏳ Attente de la base de données..."
max_attempts=30
attempt=0
until php artisan db:show > /dev/null 2>&1 || [ $attempt -eq $max_attempts ]; do
    attempt=$((attempt+1))
    echo "   Tentative $attempt/$max_attempts..."
    sleep 2
done

if [ $attempt -eq $max_attempts ]; then
    echo "❌ Impossible de se connecter à la base de données"
    exit 1
fi
echo "✅ Connexion à la base de données établie"

# Vérifier si la base est déjà initialisée
if php artisan db:table migrations > /dev/null 2>&1; then
    echo "ℹ️  Base de données déjà initialisée - migrations ignorées"
else
    echo "🗄️  Installation de la base de données..."
    php artisan clientxcms:install-db --no-interaction
    echo "✅ Base de données initialisée"

    # Créer un utilisateur admin par défaut
    echo "👤 Création de l'utilisateur admin..."
    php artisan clientxcms:create-admin \
        --email=admin@clientxcms.local \
        --password=password \
        --firstname=Admin \
        --lastname=DevContainer \
        --no-interaction || echo "⚠️  Admin déjà créé ou erreur"

    echo "✅ Utilisateur admin créé:"
    echo "   Email: admin@clientxcms.local"
    echo "   Password: password"
fi

# Installer OAuth si nécessaire
if ! grep -q "^OAUTH_CLIENT_ID=" .env || [ -z "$(grep '^OAUTH_CLIENT_ID=' .env | cut -d '=' -f2)" ]; then
    echo "🔐 Configuration OAuth..."
    php artisan clientxcms:install-oauth --no-interaction
    echo "✅ OAuth configuré"
else
    echo "ℹ️  OAuth déjà configuré"
fi

# Importer les traductions
echo "🌍 Import des traductions..."
php artisan translations:import --locale=fr_FR --no-interaction || echo "⚠️  Traductions déjà importées"
echo "✅ Traductions importées"

# Clear cache
echo "🧹 Nettoyage du cache..."
php artisan cache:clear
php artisan config:clear
php artisan route:clear
php artisan view:clear
echo "✅ Cache nettoyé"

# Permissions
echo "🔒 Configuration des permissions..."
chmod -R 775 storage bootstrap/cache
echo "✅ Permissions configurées"

echo ""
echo "=================================================="
echo "✅ Setup terminé avec succès!"
echo ""
echo "🌐 Accès à l'application:"
echo "   - Application: http://localhost"
echo "   - phpMyAdmin: http://localhost:8080"
echo "   - Mailpit (Emails): http://localhost:8025"
echo ""
echo "👤 Identifiants admin par défaut:"
echo "   - Email: admin@clientxcms.local"
echo "   - Password: password"
echo ""
echo "📧 Les emails sont capturés par Mailpit"
echo "🚀 Tu peux maintenant utiliser ton devcontainer!"
echo "=================================================="
