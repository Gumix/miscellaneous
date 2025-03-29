# completion system
autoload -Uz compinit && compinit

# XDG Base Directory Specification
export PATH="$HOME/.local/bin:$PATH"

# 24-bit color
export COLORTERM=truecolor

# prompt
PROMPT='%F{034}%n%F{red}@%F{034}%m%F{red}:%f%~%F{red}$%f '

# history
export HISTFILE="$HOME/.zsh/history"
export SAVEHIST=1000000
export HISTSIZE=1000000

# aliases
alias h='history'			# History
alias ls='gls --almost-all --color'	# GNU ls: list all entries + enable colorized output
alias l='ls -l'				# List in long format
alias rm='rm -i'			# Request confirmation before attempting to remove each file
alias grep='/opt/local/bin/grep --color=auto' # GNU grep + enable colorized output
alias tmux='env TERM=screen-256color tmux' # Enable escape sequences for italic in tmux
alias vim='nvim'			# Neovim
alias vimdiff='nvim -d'			# Neovim diff

# git aliases
alias gs='git show'
alias gd='git diff'
alias gb='git branch'
alias gbr='git branch'
alias gst='git status'
alias gco='git checkout'
alias gl='git log --graph --decorate'
alias glog='git log --graph --decorate'
alias gg='git grep'
alias ggrep='git grep'
gshow() {
	git show $1 | bat --language diff --style=plain --tabs 8
}
gdiff() {
	git diff $1 | bat --language diff --style=plain --tabs 8
}

# editors
export EDITOR=vim
export VISUAL=vim

# locale
export LC_ALL=en_US.utf-8
export LANG="$LC_ALL"

# ls colors
eval `gdircolors ~/.dir_colors`

# grep colors
export GREP_COLORS="ms=38;5;226:mc=01;31:sl=:cx=:fn=35:ln=32:bn=32:se=36"

# man colors
export MANPAGER="sh -c 'col -bx | bat -l man -p'"

# Prevent terminal from getting closed on Ctrl-D
set -o ignoreeof

# core file size
ulimit -c unlimited

source $ZDOTDIR/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source $ZDOTDIR/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh

# Mcfly
export MCFLY_FUZZY=true
export MCFLY_RESULTS=20
export MCFLY_KEY_SCHEME=vim
eval "$(mcfly init zsh)"
