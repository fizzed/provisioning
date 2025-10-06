# Provisioning Scripts
======================

Scripts for provisioning machines.  Primarly used to provision vagrant instances,
but can be used with cloud images or traditional machines as well.

## Install Java (only works on linux)

```shell
curl -sfL https://raw.githubusercontent.com/fizzed/provisioning/master/linux/bootstrap-java.sh | sudo sh -s -- --version=17
```

## Install Maven (cross platform: e.g. Linux, MacOS, FreeBSD, etc)

```shell
curl -sfL https://raw.githubusercontent.com/fizzed/provisioning/master/scripts/install-maven.sh | sudo sh
```

## Install FastFetch (cross platform: e.g. Linux, MacOS, FreeBSD, etc)

NOTE: `sudo` needs to have `java` in its path (this script leverages blaze to help install the app)

```shell
curl -sfL https://raw.githubusercontent.com/fizzed/provisioning/master/scripts/install-fastfetch.sh | sudo sh
```

Or if you need a specific version, such as for Ubuntu 20.04

```shell
curl -sfL https://raw.githubusercontent.com/fizzed/provisioning/master/scripts/install-fastfetch.sh | sudo sh -s -- --fastfetch.version 2.40.4
```


## Development

### Install Git Prompt

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
```