reset="\[\033[00m\]"
red="\[\033[00;31m\]"
green="\[\033[00;32m\]"
yellow="\[\033[00;33m\]"
blue="\[\033[00;34m\]"
magenta="\[\033[00;35m\]"
cyan="\[\033[00;36m\]"

parse_git_branch() {
  git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
}

export PS1="${green}\u${reset}@${green}\h${reset} ${cyan}\w${reset}\$(parse_git_branch)${reset} \$ "