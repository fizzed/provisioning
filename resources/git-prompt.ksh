red='\033[31m'
green='\033[32m'
cyan='\033[36m'
white='\033[37m'
bold='\033[1m'
reset='\033[0m'

function get_git_branch {
    # Get the branch name (suppressing errors)
    # Using 'git rev-parse --abbrev-ref HEAD' is the best way to get just the branch name.
    BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)

    # Check if a branch name was returned (i.e., we are in a repo)
    if [ -n "$BRANCH" ]; then
        # Return the colored branch name in parentheses, followed by the RESET code
        # Note: We include the KSH_RESET here to ensure it's evaluated with the branch.
        print "(${BRANCH}) "
    fi
}

function build_prompt {
    local HOST_SHORT=$(hostname -s)
    local CURRENT_PATH=$PWD
    local HOME_PATH=$HOME

    # Path Shortening: Use an 'if' statement, which is reliably supported
    if [[ "$CURRENT_PATH" = "$HOME_PATH"* ]]; then
        # Replace the beginning of the path with '~'
        CURRENT_PATH="~${CURRENT_PATH#$HOME_PATH}"
    fi

    # Assemble the final prompt string with colors and the dynamic git branch
    # The output is sent via 'print -n' so it becomes the value of PS1
    print -n "${green}${USER}${reset}@${green}${HOST_SHORT}${reset} ${cyan}${CURRENT_PATH}${reset} $(get_git_branch)\$ "
}

export PS1='$(build_prompt)'