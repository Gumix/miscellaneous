#export TERM=xterm-256color
#export TERM=screen-256color

export LC_ALL=en_US.utf-8
export LANG="$LC_ALL"

# Prompt
rst='\e[0m'
red='\e[31m'
green='\e[32m'
purple='\e[35m'
cyan='\e[36m'
PS1="\[${green}\]\u\[${red}\]@\[${green}\]\h\[${red}\]:\[${rst}\]\w\[${red}\]\$\[${rst}\] "
PS2="\[${cyan}\]>\[${rst}\] "
PS4="\[${purple}\]+\[${rst}\] "

# Aliases
alias h='history'		# History
#alias ls='ls -AG'		# List all entries + enable colorized output
alias ls='gls --almost-all --color'	# GNU ls: list all entries + enable colorized output
alias l='ls -l'			# List in long format
alias rm='rm -i'		# Request confirmation before attempting to remove each file
alias tree="ls -R | grep \":$\" | sed -e 's/:$//' -e 's/[^-][^\/]*\//--/g' -e 's/^/   /' -e 's/-/|/'"
alias grep='grep --color=auto'

# Git aliases
alias gbr='git branch'
alias gst='git status'
alias gco='git checkout'
alias glog='git log --graph --decorate'
alias ggrep='git grep'

gshow()
{
	git show $1 | bat --language diff --style=plain
}

gdiff()
{
	git diff $1 | bat --language diff --style=plain
}

# Editors
export EDITOR=vim
export VISUAL=vim

#export GREP_OPTIONS='--color=auto'
#export GREP_COLOR='1;33'
export GREP_COLORS="ms=38;5;226:mc=01;31:sl=:cx=:fn=35:ln=32:bn=32:se=36"

# Man highlighting
# export LESS_TERMCAP_md=$'\E[01;37m'
# export LESS_TERMCAP_me=$'\E[0m'
export MANPAGER="sh -c 'col -bx | bat -l man -p'"

# ls colors
eval `gdircolors ~/.dir_colors`

# Mcfly
export MCFLY_FUZZY=true
export MCFLY_RESULTS=20
export MCFLY_KEY_SCHEME=vim
if [[ -r "/opt/local/share/mcfly/mcfly.bash" ]]; then
	source "/opt/local/share/mcfly/mcfly.bash"
fi
