## Development

### Develop Shell Git Prompt

The shell prompt code is all in resources/ such as resources/git-prompt.bash

You can install the various prompts locally by running the following:

```
java -jar helpers/blaze.jar helpers/blaze.java install_git_prompt
```

Then you can activate the prompt by running the following:

```
# for bash
. ~/.bashrc

# for zsh
. ~/.zshrc

# for csh
source ~/.tcshrc

# for ksh
. ~/.kshrc

# for powershell
. $PROFILE
```