parse_git_branch() {
  git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
}

setopt PROMPT_SUBST
PROMPT='%F{green}%n%F{none}@%F{green}%m %F{cyan}%9c%{%F{none}%}$(parse_git_branch)%{%F{none}%} \$ '