# share history across multiple zsh sessions
setopt SHARE_HISTORY
# append to history
setopt APPEND_HISTORY

# completion system
autoload -Uz compinit && compinit

# prompt
PROMPT='%F{034}%n%F{red}@%F{034}%m%F{red}:%f%~%F{red}$%f '

# aliases
alias h='history'		# History
alias ls='gls --almost-all --color'	# GNU ls: list all entries + enable colorized output
alias l='ls -l'			# List in long format
alias rm='rm -i'		# Request confirmation before attempting to remove each file
alias tree="ls -R | grep \":$\" | sed -e 's/:$//' -e 's/[^-][^\/]*\//--/g' -e 's/^/   /' -e 's/-/|/'"
alias grep='/opt/local/bin/ggrep --color=auto' # GNU grep + enable colorized output

# git aliases
alias gbr='git branch'
alias gst='git status'
alias gco='git checkout'
alias glog='git log --graph --decorate'
alias ggrep='git grep'
gshow() {
	git show $1 | bat --language diff --style=plain
}
gdiff() {
	git diff $1 | bat --language diff --style=plain
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

source $ZDOTDIR/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source $ZDOTDIR/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh

# Mcfly
export MCFLY_FUZZY=true
export MCFLY_RESULTS=20
export MCFLY_KEY_SCHEME=vim
eval "$(mcfly init zsh)"
