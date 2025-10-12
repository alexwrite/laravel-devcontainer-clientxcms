# Path to oh-my-zsh installation
export ZSH="$HOME/.oh-my-zsh"

# Theme
ZSH_THEME="robbyrussell"

# Plugins
plugins=(
    git
    composer
    npm
    docker
    docker-compose
    laravel
    zsh-autosuggestions
    zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh

# User configuration

# Aliases Laravel
alias art="php artisan"
alias tinker="php artisan tinker"
alias migrate="php artisan migrate"
alias fresh="php artisan migrate:fresh --seed"
alias seed="php artisan db:seed"
alias test="php artisan test"
alias pint="./vendor/bin/pint"

# Aliases Composer
alias c="composer"
alias ci="composer install"
alias cu="composer update"
alias cda="composer dump-autoload"

# Aliases NPM
alias nrd="npm run dev"
alias nrb="npm run build"
alias nrw="npm run watch"

# Aliases Git
alias gs="git status"
alias ga="git add"
alias gc="git commit"
alias gp="git push"
alias gl="git pull"
alias gco="git checkout"
alias gb="git branch"
alias glog="git log --oneline --graph --decorate --all"

# Aliases Docker
alias dps="docker ps"
alias dpsa="docker ps -a"
alias dlogs="docker logs -f"
alias dexec="docker exec -it"

# Path
export PATH="$HOME/.composer/vendor/bin:$PATH"
export PATH="./vendor/bin:$PATH"
export PATH="./node_modules/.bin:$PATH"

# Laravel prompt helper
function laravel_version() {
    if [ -f artisan ]; then
        php artisan --version 2>/dev/null | cut -d ' ' -f 3
    fi
}

# Custom prompt with Laravel info
PROMPT='%{$fg[cyan]%}%n@%m%{$reset_color%}:%{$fg[green]%}%~%{$reset_color%}$(git_prompt_info) %{$fg[yellow]%}$(laravel_version)%{$reset_color%}
$ '

# Welcome message
echo "🚀 ClientXCMS DevContainer - Ready!"
echo "📁 Workspace: /workspaces/laravel"
echo ""
echo "💡 Aliases utiles:"
echo "   art         → php artisan"
echo "   migrate     → php artisan migrate"
echo "   test        → php artisan test"
echo "   pint        → ./vendor/bin/pint"
echo ""
