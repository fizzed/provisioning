# Provisioning Scripts
======================

Scripts for provisioning machines.  Primarly used to provision vagrant instances,
but can be used with cloud images or traditional machines as well.

## Install Java (only works on linux)

```
curl -sfL https://raw.githubusercontent.com/fizzed/provisioning/master/linux/bootstrap-java.sh | sudo sh -s -- --version=17
```

## Install Maven (Linux, MacOS, FreeBSD, etc)

```
curl -sfL https://raw.githubusercontent.com/fizzed/provisioning/master/linux/bootstrap-maven.sh | sudo sh
```

## Install FastFetch (Linux, MacOS, FreeBSD, etc)

NOTE: `sudo` needs to have `java` in its path (this script leverages blaze to help install the app)

```
curl -sfL https://raw.githubusercontent.com/fizzed/provisioning/master/scripts/install-fastfetch.sh | sudo sh
```
