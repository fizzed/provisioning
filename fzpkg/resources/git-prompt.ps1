# Sets the Prompt which contains the Current git branch name
# Prompt format - current_directory [ current_branch ] >
function prompt {
    $green = "$([char]27)[32m"
    $cyan = "$([char]27)[36m"
    $reset = "$([char]27)[0m"

    $user = $env:USERNAME
    $hostname = $env:COMPUTERNAME.ToLower()

    $homePath = [Environment]::GetFolderPath('UserProfile')
    $currentPath = (Get-Location).Path
    $displayPath = $currentPath

    if ($currentPath.StartsWith($homePath, [System.StringComparison]::OrdinalIgnoreCase)) {
        $displayPath = $currentPath.Replace($homePath, "~")
    }

    # redirects error to null
    # Gets the current branch which will contains '*' at the front
    $currentBranchExt = $(git branch);
    $currentBranchMatches = $currentBranchExt -match "\*";
    if ($currentBranchMatches) {
        Try {
            $currentBranchOn = $($currentBranchExt | Select-String -Pattern "\*")
            # Holds the pattern for extracting the branch name
            $currentBranchMatchPattern = "[^*]*";
            # Executes the regular expression against the matched branch
            $currentBranchNameMatches = [regex]::matches($currentBranchOn, $currentBranchMatchPattern);
            # Gets the current branch from the matches
            $currentBranchName = $currentBranchNameMatches.Captures[1].Value.Trim();

            # Sets the Prompt which contains the Current git branch name
            # Prompt format - current_directory [ current_branch ] >
            "PS $($green)$($user)$($reset)@$($green)$($hostname)$reset $cyan$($displayPath)$($reset + ' (' + $currentBranchName + ') >' * ($nestedPromptLevel + 1)) ";
        }
        Catch {
            # Calls the default prompt
            "PS $($green)$($user)$($reset)@$($green)$($hostname)$reset $cyan$($displayPath)$($reset + ' >' * ($nestedPromptLevel + 1)) ";
        }
    } else {
        # Calls the default prompt
        "PS $($green)$($user)$($reset)@$($green)$($hostname)$reset $cyan$($displayPath)$($reset + ' >' * ($nestedPromptLevel + 1)) ";
    }
}