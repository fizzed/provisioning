set red="%{\033[0;31m%}"
set green="%{\033[0;32m%}"
set cyan="%{\033[0;36m%}"
set yellow="%{\033[0;33m%}"
set purple="%{\033[0;35m%}"
set reset="%{\033[0m%}"

alias __git_current_branch 'git rev-parse --abbrev-ref HEAD >& /dev/null && echo " (`git rev-parse --abbrev-ref HEAD`)"'
alias precmd 'set prompt="${green}%n${reset}@${green}%m${reset} ${cyan}%~${reset}`__git_current_branch` %# "'