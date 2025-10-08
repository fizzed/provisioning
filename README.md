# Provisioning Scripts

Scripts for provisioning machines, applications, and configuration. Support for cross platform installers, as well
as letting you decide if you want to install SYSTEM-WIDE or USER-SPECIFIC.

### Windows

On Windows, the examples below will leverage PowerShell and the new `sudo` command you can optionally activate in
the Windows Developer settings. You'll also need to change your security policy to allow running PowerShell scripts
from remote locations.



## Linux Only Scripts

The scripts below are only designed to work on Linux across many architectures such as X64, ARM64, RISCV64, etc.

### Java (JVM)

You can provide the version of Java you would like to install such as 25, 21, 17, 11, or 8. The script will detect
what architecture you are on, or whether you on on GLIBC or MUSL linux, and install the appropriate version.

```shell

# Install jdk 17
curl -sfL https://cdn.fizzed.com/provisioning/bootstrap-java.sh | sudo sh -s -- --version=17

# Install jdk 21 and set it as the default
curl -sfL https://cdn.fizzed.com/provisioning/bootstrap-java.sh | sudo sh -s -- --version=21 --default
```



## Cross Platform Scripts

The scripts below are designed to work across all platforms including Linux, Windows, MacOS, FreeBSD, and OpenBSD.



### Maven

```shell
# On systems with bourne shell and sudo such as Linux, MacOS, and FreeBSD.
curl -sfL https://cdn.fizzed.com/provisioning/install-maven.sh | sudo sh

# On systems with bourne shell and doas such as OpenBSD
curl -sfL https://cdn.fizzed.com/provisioning/install-maven.sh | doas sh

# On systems with powershell and sudo enabled such as Windows.
sudo powershell -Command 'iwr "https://cdn.fizzed.com/provisioning/install-maven.ps1" | iex'
```



## Install Git Shell Prompt (cross platform: e.g. Linux, MacOS, FreeBSD, etc)

```shell
curl -sfL https://cdn.fizzed.com/provisioning/install-git-prompt.sh | sh
```

```powershell
powershell -Command 'iwr "https://cdn.fizzed.com/provisioning/install-git-prompt.ps1" | iex'
```



## Install FastFetch (cross platform: e.g. Linux, MacOS, FreeBSD, etc)

NOTE: `sudo` needs to have `java` in its path (this script leverages blaze to help install the app)

```shell
curl -sfL https://cdn.fizzed.com/provisioning/install-fastfetch.sh | sudo sh
```

```powershell
sudo powershell -Command 'iwr "https://cdn.fizzed.com/provisioning/install-fastfetch.ps1" | iex'
```

Or if you need a specific version, such as for Ubuntu 20.04

```shell
curl -sfL https://cdn.fizzed.com/provisioning/install-fastfetch.sh | sudo sh -s -- --fastfetch.version 2.40.4
```


=======

## Install Shell Prompt w/ Git Branch

```shell
curl -sfL https://cdn.fizzed.com/provisioning/install-git-prompt.sh | sh
```

```powershell
powershell -Command 'iwr "https://cdn.fizzed.com/provisioning/install-git-prompt.ps1" | iex'
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

# for csh
source ~/.tcshrc

# for ksh
. ~/.kshrc

# for powershell
. $PROFILE
```