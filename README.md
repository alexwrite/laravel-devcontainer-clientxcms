# ClientXCMS DevContainer

Environnement de développement conteneurisé pour ClientXCMS basé sur Laravel 11.

## 🎯 Prérequis

- [Visual Studio Code](https://code.visualstudio.com/)
- [Extension Remote - Containers](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)
- [Docker Desktop](https://www.docker.com/products/docker-desktop)
- [Docker Compose](https://docs.docker.com/compose/install/)

## 🏗️ Architecture

Le devcontainer utilise une architecture microservices :

- **cli** : PHP 8.3-cli (workspace VSCode) - Composer, Node.js, npm
- **fpm** : PHP 8.3-FPM (exécution PHP)
- **nginx** : Serveur web Nginx 1.27
- **mariadb** : Base de données MariaDB 11.2
- **redis** : Cache et sessions Redis 7.2
- **scheduler** : Ofelia pour les tâches cron Laravel
- **phpmyadmin** : Interface de gestion de base de données
- **mailpit** : Serveur SMTP de test pour capturer les emails

### Bases de données créées

- `clientxcms` : Base de données principale
- `clientxcms_test` : Base de données pour les tests PHPUnit

## 🚀 Démarrage rapide

### 1. Ouvrir dans le devcontainer

```bash
# Depuis VSCode
# 1. Ouvrir le dossier du projet
# 2. Cmd/Ctrl + Shift + P
# 3. "Remote-Containers: Reopen in Container"
```

### 2. Premier démarrage

Lors du premier démarrage, le script `setup.sh` s'exécute automatiquement et :

✅ Copie et configure `.env` avec les bonnes variables
✅ Installe les dépendances Composer
✅ Installe les dépendances NPM
✅ Build les assets frontend
✅ Génère la clé d'application
✅ Attend la connexion à la base de données
✅ Exécute les migrations
✅ Crée un utilisateur admin par défaut
✅ Configure OAuth
✅ Importe les traductions (fr_FR)
✅ Nettoie le cache

**Identifiants admin par défaut :**
- Email : `admin@clientxcms.local`
- Password : `password`

### 3. Accès aux services

- **Application** : http://localhost
- **phpMyAdmin** : http://localhost:8080
  - Serveur : `mariadb`
  - Utilisateur : `root`
  - Mot de passe : `clientxcms`
- **Mailpit** (Emails) : http://localhost:8025
  - Interface web pour visualiser tous les emails envoyés par l'application

## 🛠️ Commandes utiles

### Laravel Artisan

```bash
# Migration et seed
php artisan migrate
php artisan db:seed

# Tests
php artisan test
php artisan test --filter=NomDuTest

# Cache
php artisan cache:clear
php artisan config:clear
php artisan route:clear
php artisan view:clear

# Scheduler (test manuel)
php artisan schedule:run

# Queue (mode database, pas besoin de worker)
php artisan queue:work --once
```

### Frontend

```bash
# Dev mode avec hot reload
npm run dev

# Build production
npm run build

# Watch mode
npm run watch
```

### Composer

```bash
# Installer une dépendance
composer require vendor/package

# Mise à jour
composer update

# Autoload
composer dump-autoload
```

### Base de données

```bash
# Afficher les tables
php artisan db:table migrations

# Voir le statut des migrations
php artisan migrate:status

# Rollback
php artisan migrate:rollback

# Fresh install (ATTENTION: supprime toutes les données!)
php artisan migrate:fresh --seed
```

## 📦 Extensions VSCode incluses

### PHP & Laravel
- **Intelephense** : Autocomplétion PHP avancée
- **Laravel Extra Intellisense** : Autocomplétion Laravel (routes, views, config)
- **Laravel Artisan** : Commandes Artisan depuis VSCode
- **Laravel Blade** : Coloration syntaxique Blade
- **Laravel Goto View** : Navigation rapide vers les vues
- **PHP Namespace Resolver** : Import automatique des classes
- **PHP DocBlocker** : Génération de PHPDoc
- **Better PHPUnit** : Exécution de tests depuis VSCode

### Frontend
- **Tailwind CSS IntelliSense** : Autocomplétion Tailwind

### Outils
- **GitLens** : Git amélioré
- **EditorConfig** : Configuration d'éditeur
- **DotENV** : Coloration syntaxique .env

## 🤖 Claude CLI

Claude CLI est préinstallé dans le devcontainer pour faciliter le développement avec l'IA d'Anthropic.

### Configuration automatique

Ton fichier d'authentification (`~/.claude/`) est automatiquement monté dans le container en lecture seule. Tu es donc **déjà authentifié** dès le lancement du devcontainer !

### Utilisation

```bash
# Lancer Claude CLI
claude

# Ou utiliser la commande complète
claude-code

# Obtenir de l'aide
claude --help
```

### Première utilisation (si pas encore authentifié sur ta machine)

Si tu n'as pas encore configuré Claude CLI sur ta machine hôte, lance-le d'abord en dehors du container :

```bash
# Sur ta machine hôte (pas dans le container)
claude-code login
```

Une fois authentifié, rebuild le devcontainer pour monter les credentials

### Exemples d'utilisation

```bash
# Demander à Claude d'analyser du code
claude "Explique-moi cette fonction"

# Générer du code
claude "Crée un contrôleur Laravel pour gérer les produits"

# Déboguer
claude "J'ai cette erreur dans mon code : [copier l'erreur]"

# Optimiser
claude "Comment puis-je optimiser cette requête SQL ?"
```

### Alias disponibles

Plusieurs alias sont configurés pour simplifier l'utilisation :

```bash
cc   # claude --dangerously-skip-permissions --resume
ccc  # claude --dangerously-skip-permissions
```

**Note sur `--dangerously-skip-permissions`** : Cet alias permet à Claude de travailler sans demander confirmation à chaque opération. C'est pratique dans un environnement de développement conteneurisé où tu as le contrôle total.

## ⚙️ Configuration

### Variables d'environnement

Le fichier `.env` est configuré automatiquement avec :

```env
DB_CONNECTION=mysql
DB_HOST=mariadb
DB_PORT=3306
DB_DATABASE=clientxcms
DB_USERNAME=clientxcms
DB_PASSWORD=clientxcms

REDIS_HOST=redis
REDIS_PASSWORD=null
REDIS_PORT=6379

QUEUE_CONNECTION=database
CACHE_DRIVER=redis
SESSION_DRIVER=redis

APP_URL=http://localhost
APP_ENV=local
APP_DEBUG=true

MAIL_MAILER=smtp
MAIL_HOST=mailpit
MAIL_PORT=1025
MAIL_USERNAME=null
MAIL_PASSWORD=null
MAIL_ENCRYPTION=null
```

### Modifier la configuration

Si tu souhaites modifier les identifiants de base de données ou autre :

1. Éditer `.devcontainer/docker-compose.yaml`
2. Éditer `.devcontainer/setup.sh` (section sed pour le .env)
3. Rebuild le container : `Cmd/Ctrl + Shift + P` → `Remote-Containers: Rebuild Container`

## 🔄 Tâches automatisées

Le scheduler Ofelia exécute `php artisan schedule:run` toutes les minutes.

Les tâches Laravel configurées :
- `invoices:delivery` : Traitement des factures en attente
- `services:expire` : Expiration des services
- `services:renewals` : Génération des factures de renouvellement
- `services:notify-expiration` : Notifications d'expiration
- `clientxcms:helpdesk-close` : Fermeture automatique des tickets
- `clientxcms:invoice-delete` : Purge des anciennes factures
- `clientxcms:purge-metadata` : Nettoyage des métadonnées
- `clientxcms:telemetry` : Envoi de télémétrie

## 🧪 Tests

### Exécuter les tests

```bash
# Tous les tests
php artisan test

# Test spécifique
php artisan test --filter=CustomerControllerTest

# Suite spécifique
php artisan test --testsuite=Feature

# Avec couverture
php artisan test --coverage
```

### Tests depuis VSCode

Avec l'extension Better PHPUnit :
- Clic droit sur un test → `Run Test`
- Clic droit sur une classe → `Run Test Suite`
- Voir les résultats dans le panneau OUTPUT

## 🐛 Debugging

### Logs

```bash
# Logs Laravel
tail -f storage/logs/laravel.log

# Logs Nginx (depuis l'host)
tail -f .github/logs/nginx/error.log
```

### Debug PHP

L'extension Xdebug est installée. Pour activer :

1. Ajouter dans `.env` : `XDEBUG_MODE=debug`
2. Rebuild le container
3. Configurer un breakpoint dans VSCode
4. F5 pour lancer le debugger

## 🔧 Maintenance

### Rebuild complet

```bash
# Depuis VSCode
Cmd/Ctrl + Shift + P → "Remote-Containers: Rebuild Container"

# Ou depuis le terminal
docker-compose -f .devcontainer/docker-compose.yaml down -v
docker-compose -f .devcontainer/docker-compose.yaml build --no-cache
docker-compose -f .devcontainer/docker-compose.yaml up -d
```

### Nettoyer les volumes

```bash
# Attention : supprime toutes les données de la base !
docker-compose -f .devcontainer/docker-compose.yaml down -v
```

### Réinitialiser le projet

```bash
# Supprimer les dépendances
rm -rf vendor node_modules

# Supprimer les fichiers générés
rm -rf bootstrap/cache/*.php
rm -rf storage/framework/cache/*
rm -rf storage/framework/sessions/*
rm -rf storage/framework/views/*

# Supprimer .env
rm .env

# Rebuild container → le setup.sh réinstallera tout
```

## 📚 Ressources

- [Documentation ClientXCMS](https://clientxcms.com/docs)
- [Laravel 11 Documentation](https://laravel.com/docs/11.x)
- [VSCode Remote Containers](https://code.visualstudio.com/docs/remote/containers)
- [Docker Documentation](https://docs.docker.com/)

## 🤝 Support

Pour toute question ou problème :
1. Vérifier les logs : `storage/logs/laravel.log`
2. Vérifier la connexion DB : `php artisan db:show`
3. Tester la config : `php artisan config:show`

## 🎓 Tips pour débutants

### Workflow recommandé

1. **Faire des modifications** dans le code PHP/Blade
2. **Voir le résultat** instantanément dans le navigateur (http://localhost)
3. **Tester** avec `php artisan test`
4. **Commit** régulièrement avec Git

### Commandes à connaître par cœur

```bash
# Voir les routes
php artisan route:list

# Créer un contrôleur
php artisan make:controller NomController

# Créer un modèle avec migration
php artisan make:model NomModel -m

# Créer une migration
php artisan make:migration create_table_name

# Lancer les migrations
php artisan migrate

# Créer un test
php artisan make:test NomTest
```

### Analogie SysAdmin → Dev

| Concept SysAdmin | Équivalent Laravel | Commande |
|---|---|---|
| Cron jobs | Scheduler | `php artisan schedule:run` |
| Service restart | Cache clear | `php artisan cache:clear` |
| Log rotation | Log channels | `storage/logs/` |
| Config reload | Config cache | `php artisan config:cache` |
| Service status | Health check | `php artisan db:show` |
| Backup | Database dump | `php artisan db:backup` |

Bon développement ! 🚀
