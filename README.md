# Provisioning Scripts
======================

Scripts for provisioning machines.  Primarly used to provision vagrant instances,
but can be used with cloud images or traditional machines as well.

## Shell - Install Java

```
curl -s https://raw.githubusercontent.com/jjlauer/provisioning/master/linux/bootstrap-java.sh | sudo sh -s -- --version=17
```

## Shell - Install Maven

```
curl -s https://raw.githubusercontent.com/jjlauer/provisioning/master/linux/bootstrap-maven.sh | sudo sh
```

## Shell - Install FastFetch

NOTE: `sudo` needs to have `java` in its path (this script leverages blaze to help install the app)

```
curl -s https://raw.githubusercontent.com/jjlauer/provisioning/master/scripts/install-fastfetch.sh | sudo sh
```
