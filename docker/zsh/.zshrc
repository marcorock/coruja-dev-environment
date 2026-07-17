# Coruja Dev Environment - Zsh

export LANG=pt_BR.UTF-8
export LC_ALL=pt_BR.UTF-8
export EDITOR=code
export VISUAL=code

HISTFILE="$HOME/.zsh_history"
HISTSIZE=10000
SAVEHIST=10000

setopt APPEND_HISTORY
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_REDUCE_BLANKS
setopt HIST_VERIFY
setopt INC_APPEND_HISTORY

setopt AUTO_CD
setopt AUTO_PUSHD
setopt PUSHD_IGNORE_DUPS
setopt CORRECT
setopt PROMPT_SUBST

autoload -Uz compinit
compinit

zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

if [ -f /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]; then
    source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
fi

if [ -f /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]; then
    source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi

if [ -f /usr/share/doc/fzf/examples/key-bindings.zsh ]; then
    source /usr/share/doc/fzf/examples/key-bindings.zsh
fi

if [ -f /usr/share/doc/fzf/examples/completion.zsh ]; then
    source /usr/share/doc/fzf/examples/completion.zsh
fi

export FZF_DEFAULT_COMMAND='find . -type f -not -path "*/vendor/*" -not -path "*/.git/*"'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

git_branch() {
    local branch
    branch=$(git symbolic-ref --short HEAD 2>/dev/null)

    if [[ -n "$branch" ]]; then
        echo " %F{magenta}git:(%F{yellow}${branch}%F{magenta})%f"
    fi
}

PROMPT='%F{cyan}%n%f %F{blue}%~%f$(git_branch)
%F{green}❯%f '

alias cls='clear'
alias c='clear'
alias ll='ls -lah'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias grep='grep --color=auto'

if command -v batcat >/dev/null 2>&1; then
    alias bat='batcat'
    alias cat='batcat --paging=never'
fi

if command -v fdfind >/dev/null 2>&1; then
    alias fd='fdfind'
fi

alias g='git'
alias gs='git status'
alias ga='git add'
alias gaa='git add .'
alias gc='git commit'
alias gcm='git commit -m'
alias gp='git push'
alias gl='git pull'
alias gb='git branch'
alias gco='git checkout'
alias gsw='git switch'
alias gd='git diff'
alias glog='git log --oneline --graph --decorate --all'

alias composer-install='composer install'
alias composer-update='composer update'
alias composer-dump='composer dump-autoload'
alias composer-check='composer validate'
alias ci='composer install'
alias cu='composer update'
alias cda='composer dump-autoload'

alias php-version='php -v'
alias php-modules='php -m'
alias php-server='php -S 0.0.0.0:8000 -t public'

alias d='docker'
alias dc='docker compose'
alias dcu='docker compose up -d'
alias dcd='docker compose down'
alias dcb='docker compose up -d --build'
alias dcp='docker compose ps'
alias dcl='docker compose logs -f'

alias projects='cd /var/www/projects'
alias envinfo='echo "PHP: $(php -r "echo PHP_VERSION;")" && composer --version && zsh --version'
