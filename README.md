# Provisioning Scripts by Fizzed

Scripts for provisioning systems and applications with cross platform recipes that are BETTER than the default methods
that most package managers will do for you.  For example, these scripts help you install the latest JDK, Maven, plus
correctly setup your environment variables and PATH. Unlike package managers, these scripts will give you verbose
information about what is happening and how to fix any issues that you may encounter.

Here is an example of installing the "Java Path" script on an OpenBSD host:

```shell
bmh-build-x64-openbsd76-1$ curl -sfL https://cdn.fizzed.com/fzpkg/install-java-path.sh | doas sh -s -- --version 17
doas (builder@bmh-build-x64-openbsd76-1) password: 
mkdir: /tmp/provisioning-helpers: File exists
[INFO] Resolving dependencies...
[INFO] Resolved dependencies in 370 ms
[INFO] Compiling script...
[INFO] Compiled script in 442 ms
[INFO] Executing ../../tmp/provisioning-helpers/blaze.java:install_java_path...
[INFO] Detected platform OPENBSD (arch X64) (abi DEFAULT)
[INFO] Using install scope SYSTEM
[INFO] Confirmed you are running with elevated permissions :-)
[INFO] Deleting /root/.provisioning-ok-to-delete
[INFO] Creating directory /root/.provisioning-ok-to-delete
[INFO] Detected the following java homes:
[INFO] 
[INFO]   JDK 17.0.12 (/usr/local/jdk-17)
[INFO]   JDK 21.0.4 (/usr/local/jdk-21)
[INFO]   JDK 11.0.24 (/usr/local/jdk-11)
[INFO]   JDK 8.0.422 (/usr/local/jdk-1.8.0)
[INFO] 
[INFO] Preferred major java version: 17
[INFO] Preferred java home: JDK 17.0.12 (/usr/local/jdk-17)
[INFO] Creating symlinks for current & major java homes...
[INFO] 
[INFO]   /usr/local/jdk-current -> /usr/local/jdk-17
[INFO] 
[WARN] Unable to locate system-wide profile file for KSH, will use ~/.profile instead
[INFO] Installed the system ksh environment by appending/replacing the following to /home/builder/.profile:
[INFO] 
[INFO]   # begin java environment
[INFO]   # do not edit any text from begin to end comments
[INFO]   
[INFO]   export JAVA_HOME="/usr/local/jdk-current"
[INFO]   case ":$PATH:" in *:"/usr/local/jdk-current/bin":*) ;; *) PATH="/usr/local/jdk-current/bin${PATH:+:$PATH}" ;; esac; export PATH
[INFO]   
[INFO]   # end java environment
[INFO] 
[INFO] Deleting /root/.provisioning-ok-to-delete
[INFO] Executed ../../tmp/provisioning-helpers/blaze.java:install_java_path in 16 ms
[INFO] Blazed in 858 ms
```

## Windows Requirements

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
curl -sfL https://cdn.fizzed.com/fzpkg/install-java.sh | sudo sh -s -- --version=17

# Install jdk 21 and set it as the default
curl -sfL https://cdn.fizzed.com/fzpkg/install-java.sh | sudo sh -s -- --version=21 --default
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
curl -sfL https://cdn.fizzed.com/fzpkg/install-java-path.sh | sudo sh

# On OpenBSD
curl -sfL https://cdn.fizzed.com/fzpkg/install-java-path.sh | doas sh

# On Windows
sudo powershell -Command 'iwr https://cdn.fizzed.com/fzpkg/install-java-path.ps1 | iex'
```

Or to force a specific version such as Java 17

```shell
# On Linux, MacOS, and FreeBSD.
curl -sfL https://cdn.fizzed.com/fzpkg/install-java-path.sh | sudo sh -s -- --version 17

# On OpenBSD
curl -sfL https://cdn.fizzed.com/fzpkg/install-java-path.sh | doas sh -s -- --version 17

# On Windows
sudo powershell -Command "& ([ScriptBlock]::Create((New-Object System.Net.WebClient).DownloadString('https://cdn.fizzed.com/fzpkg/install-java-path.ps1'))) --version 17"
```



### Maven

This script will install Maven system-wide (by default) or just for the current user if you specify the `--scope user`
argument. It will also make sure the M2_HOME environment variable is set, plus prepend the maven bin directory to
your PATH.

```shell
# On Linux, MacOS, and FreeBSD.
curl -sfL https://cdn.fizzed.com/fzpkg/install-maven.sh | sudo sh

# On OpenBSD
curl -sfL https://cdn.fizzed.com/fzpkg/install-maven.sh | doas sh

# On Windows
sudo powershell -Command 'iwr https://cdn.fizzed.com/fzpkg/install-maven.ps1 | iex'
```



### Blaze

This script will install Blaze wrapper script system-wide (by default) or just for the current user if you specify the `--scope user`
argument.

```shell
# On Linux, MacOS, and FreeBSD.
curl -sfL https://cdn.fizzed.com/fzpkg/install-blaze.sh | sudo sh

# On OpenBSD
curl -sfL https://cdn.fizzed.com/fzpkg/install-blaze.sh | doas sh

# On Windows
sudo powershell -Command 'iwr https://cdn.fizzed.com/fzpkg/install-blaze.ps1 | iex'
```



### Shell Git Prompt

This script will install an opinionated shell prompt user-specific (by default) that supports coloring and the git branch
if you are in a git repository. Supports bash, zsh, tcsh, ksh, and powershell. Since its user-specific, sudo is not
required.

```shell
# On Linux, MacOS, FreeBSD, and OpenBSD
curl -sfL https://cdn.fizzed.com/fzpkg/install-git-prompt.sh | sh

# On Windows
iwr https://cdn.fizzed.com/fzpkg/install-git-prompt.ps1 | iex
```



### FastFetch

This script will install FastFetch system-wide (by default) or just for the current user if you specify the `--scope user`
argument. It will also prepend the fastfetch bin directory to your PATH (if needed).

```shell
# On Linux, MacOS, and FreeBSD.
curl -sfL https://cdn.fizzed.com/fzpkg/install-fastfetch.sh | sudo sh

# On OpenBSD
curl -sfL https://cdn.fizzed.com/fzpkg/install-fastfetch.sh | doas sh

# On Windows
sudo powershell -Command 'iwr https://cdn.fizzed.com/fzpkg/install-fastfetch.ps1 | iex'
```

Or if you only wanted to install for the current user

```shell
# On Linux, MacOS, and FreeBSD.
curl -sfL https://cdn.fizzed.com/fzpkg/install-fastfetch.sh | sudo sh -s -- --scope user

# On OpenBSD
curl -sfL https://cdn.fizzed.com/fzpkg/install-fastfetch.sh | doas sh -s -- --scope user
```

For older versions of Linux or other systems, you can also request a specific version of FastFetch to install.

```shell
curl -sfL https://cdn.fizzed.com/fzpkg/install-fastfetch.sh | sudo sh -s -- --version 2.40.4
```
