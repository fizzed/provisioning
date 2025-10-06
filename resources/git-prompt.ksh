export KSH_RED='\033[31m'
export KSH_GREEN='\033[32m'
export KSH_CYAN='\033[36m'
export KSH_WHITE='\033[37m'
export KSH_BOLD='\033[1m'
export KSH_RESET='\033[0m'

function get_git_branch {
    # Get the branch name (suppressing errors)
    # Using 'git rev-parse --abbrev-ref HEAD' is the best way to get just the branch name.
    BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)

    # Check if a branch name was returned (i.e., we are in a repo)
    if [ -n "$BRANCH" ]; then
        # Return the colored branch name in parentheses, followed by the RESET code
        # Note: We include the KSH_RESET here to ensure it's evaluated with the branch.
        print " (${BRANCH})"
    fi
}

function build_prompt {
    local HOST_SHORT=$(hostname -s)
    local PROMPT_SYMBOL='$ '
    local CURRENT_PATH=$PWD
    local HOME_PATH=$HOME

    # Path Shortening: Use an 'if' statement, which is reliably supported
    if [[ "$CURRENT_PATH" = "$HOME_PATH"* ]]; then
        # Replace the beginning of the path with '~'
        CURRENT_PATH="~${CURRENT_PATH#$HOME_PATH}"
    fi

    # Assemble the final prompt string with colors and the dynamic git branch
    # The output is sent via 'print -n' so it becomes the value of PS1
    print -n "${KSH_GREEN}${USER}${KSH_RESET}@${KSH_GREEN}${HOST_SHORT}${KSH_RESET} "
    print -n "${KSH_CYAN}${CURRENT_PATH}${KSH_RESET}"
    print -n "$(get_git_branch)"
    print -n "${PROMPT_SYMBOL}"
}

export PS1='$(build_prompt)'