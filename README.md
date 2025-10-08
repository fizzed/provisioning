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
what architecture you are on, or whether you on on GLIBC or MUSL linux, and install the appropriate JDK. Java will
be installed system-wide and will be prepended to your PATH as well.

```shell

# Install jdk 17
curl -sfL https://cdn.fizzed.com/provisioning/bootstrap-java.sh | sudo sh -s -- --version=17

# Install jdk 21 and set it as the default
curl -sfL https://cdn.fizzed.com/provisioning/bootstrap-java.sh | sudo sh -s -- --version=21 --default
```



## Cross Platform Scripts

The scripts below are designed to work across all platforms including Linux, Windows, MacOS, FreeBSD, and OpenBSD.


### Java Path

This script will detect all JDKs installed on the system and properly setup your environment variables to use the
appropriate JDK. If you provide no arguments, it will find the greatest JDK version and set it as the default. 
Alternatively, you can provide a version to force it to use 21, 17, 11, etc. as your default instead. This script will
first create a "jdk-current" symlink (in the standard location for JVMs for that particular operating system) that points
to your default JDK. Then it will set your JAVA_HOME environment variable to point to that "jdk-current" symlink, plus
prepend "path-to-it/jdk-current/bin" to your PATH. By leveraging symlinks, you can easily switch/upgrade JDKs without
having to modify your PATH.

```shell
# On Linux, MacOS, and FreeBSD.
curl -sfL https://cdn.fizzed.com/provisioning/install-java-path.sh | sudo sh

# On OpenBSD
curl -sfL https://cdn.fizzed.com/provisioning/install-java-path.sh | doas sh

# On Windows
sudo powershell -Command 'iwr "https://cdn.fizzed.com/provisioning/install-java-path.ps1" | iex'
```

Or to force a specific version such as Java 17

```shell
# On Linux, MacOS, and FreeBSD.
curl -sfL https://cdn.fizzed.com/provisioning/install-java-path.sh | sudo sh -s -- --version 17

# On OpenBSD
curl -sfL https://cdn.fizzed.com/provisioning/install-java-path.sh | doas sh -s -- --version 17

# On Windows
sudo powershell -Command 'iwr "https://cdn.fizzed.com/provisioning/install-java-path.ps1" | iex'
```


### Maven

This script will install Maven system-wide (by default) or just for the current user if you specify the `--scope user`
argument. It will also make sure the M2_HOME environment variable is set, plus prepend the maven bin directory to
your PATH.

```shell
# On Linux, MacOS, and FreeBSD.
curl -sfL https://cdn.fizzed.com/provisioning/install-maven.sh | sudo sh

# On OpenBSD
curl -sfL https://cdn.fizzed.com/provisioning/install-maven.sh | doas sh

# On Windows
sudo powershell -Command 'iwr "https://cdn.fizzed.com/provisioning/install-maven.ps1" | iex'
```



### Shell Git Prompt

This script will install an opinionated shell prompt user-specific (by default) that supports coloring and the git branch
if you are in a git repository. Supports bash, zsh, tcsh, ksh, and powershell. Since its user-specific, sudo is not
required.

```shell
# On Linux, MacOS, FreeBSD, and OpenBSD
curl -sfL https://cdn.fizzed.com/provisioning/install-git-prompt.sh | sh

# On Windows
powershell -Command 'iwr "https://cdn.fizzed.com/provisioning/install-git-prompt.ps1" | iex'
```



### FastFetch

This script will install FastFetch system-wide (by default) or just for the current user if you specify the `--scope user`
argument. It will also prepend the fastfetch bin directory to your PATH (if needed).

```shell
# On Linux, MacOS, and FreeBSD.
curl -sfL https://cdn.fizzed.com/provisioning/install-fastfetch.sh | sudo sh

# On OpenBSD
curl -sfL https://cdn.fizzed.com/provisioning/install-fastfetch.sh | doas sh

# On Windows
sudo powershell -Command 'iwr "https://cdn.fizzed.com/provisioning/install-fastfetch.ps1" | iex'
```

Or if you need a specific version, such as for Ubuntu 20.04

```shell
curl -sfL https://cdn.fizzed.com/provisioning/install-fastfetch.sh | sudo sh -s -- --fastfetch.version 2.40.4
```
