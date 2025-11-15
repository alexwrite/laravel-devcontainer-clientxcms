#!/bin/bash
set -e

echo "ClientXCMS DevContainer - Script d'initialisation"
echo "=================================================="

# Vérifier que nous sommes dans le bon répertoire
cd /workspaces/laravel

# Copier le fichier .env s'il n'existe pas
if [ ! -f .env ]; then
    echo "Création du fichier .env..."
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

    echo "Fichier .env configuré pour le devcontainer"
else
    echo "Fichier .env existant - conservé"
fi

# Installation des dépendances PHP
if [ ! -d "vendor" ]; then
    echo "Installation des dépendances Composer..."
    composer install --no-interaction --prefer-dist --optimize-autoloader
    echo "Dépendances PHP installées"
else
    echo "Dépendances Composer déjà installées"
fi

# Installation des dépendances Node
if [ ! -d "node_modules" ]; then
    echo "Installation des dépendances NPM..."
    npm install
    echo "Dépendances Node installées"
else
    echo "Dépendances NPM déjà installées"
fi

# Build des assets
echo "Build des assets frontend..."

# Vérifier si un build précédent existe
if [ -d "public/build" ] || [ -d "public/hot" ]; then
    echo "   Suppression des anciens assets..."
    rm -rf public/build public/hot
    echo "   Anciens assets supprimés"
fi

# Vérifier que vite.config.js ou webpack.mix.js existe
if [ -f "vite.config.js" ] || [ -f "vite.config.ts" ] || [ -f "webpack.mix.js" ]; then
    echo "   Compilation des assets..."

    # Build avec gestion d'erreur
    if npm run build; then
        echo "   Assets compilés avec succès"

        # Vérifier que le build a généré des fichiers
        if [ -d "public/build" ] && [ "$(ls -A public/build)" ]; then
            echo "   Build vérifié: fichiers générés dans public/build"
        else
            echo "   WARNING: Build terminé mais aucun fichier dans public/build"
        fi
    else
        echo "   ERROR: Échec de la compilation des assets"
        echo "   L'application peut ne pas fonctionner correctement"
        # On ne fait pas exit 1 pour permettre de continuer le setup
    fi
else
    echo "   WARNING: Aucun fichier de configuration de build trouvé"
    echo "   Skip du build des assets"
fi

# Générer la clé d'application si nécessaire
if ! grep -q "^APP_KEY=base64:" .env; then
    echo "Génération de la clé d'application..."
    php artisan key:generate
    echo "Clé d'application générée"
fi

# Attendre que la base de données soit prête
echo "Attente de la base de données..."
max_attempts=30
attempt=0
until php artisan db:show > /dev/null 2>&1 || [ $attempt -eq $max_attempts ]; do
    attempt=$((attempt+1))
    echo "   Tentative $attempt/$max_attempts..."
    sleep 2
done

if [ $attempt -eq $max_attempts ]; then
    echo "Impossible de se connecter à la base de données"
    exit 1
fi
echo "Connexion à la base de données établie"

# Vérifier si la base est déjà initialisée
if php artisan db:table migrations > /dev/null 2>&1; then
    echo "Base de données déjà initialisée - migrations ignorées"
else
    echo "Installation de la base de données..."
    php artisan clientxcms:install-db --no-interaction
    echo "Base de données initialisée"

    # Vérifier si un admin existe déjà
    echo "Vérification des utilisateurs admin..."
    admin_count=$(php artisan tinker --execute="echo App\Models\Admin::count();" 2>/dev/null || echo "0")

    if [ "$admin_count" -eq 0 ]; then
        echo "   Aucun admin trouvé - création de l'utilisateur admin par défaut..."
        php artisan clientxcms:install-admin \
            --email=admin@clientxcms.local \
            --password=password \
            --firstname=Admin \
            --lastname=DevContainer

        echo "   Utilisateur admin créé:"
        echo "      Email: admin@clientxcms.local"
        echo "      Password: password"
    else
        echo "   Admin existant détecté ($admin_count utilisateur(s)) - création ignorée"
    fi
fi

# Importer les traductions
echo "Import des traductions..."
if php artisan translations:import --locale=fr_FR 2>/dev/null; then
    echo "   Traductions fr_FR importées avec succès"
else
    echo "   WARNING: Impossible d'importer les traductions (déjà présentes ou erreur réseau)"
fi

# Clear cache
echo "Nettoyage du cache..."
php artisan cache:clear
php artisan config:clear
php artisan route:clear
php artisan view:clear
echo "Cache nettoyé"

echo ""
echo "=================================================="
echo "Setup terminé avec succès!"
echo ""
echo "Accès à l'application:"
echo "   - Application: http://localhost"
echo "   - phpMyAdmin: http://localhost:8080"
echo "   - Mailpit (Emails): http://localhost:8025"
echo ""
echo "Identifiants admin par défaut:"
echo "   - Email: admin@clientxcms.local"
echo "   - Password: password"
echo ""
echo "Les emails sont capturés par Mailpit"
echo "Tu peux maintenant utiliser ton devcontainer!"
echo "=================================================="