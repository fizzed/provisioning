Provisioning Scripts
====================

Scripts for provisioning machines.  Primarly used to provision vagrant instances,
but can be used with cloud images or traditional machines as well.

### Vagrant

```ruby
Vagrant.configure(2) do |config|
  config.vm.define "ubuntu1404", primary: true do |guest|
    guest.vm.box = "minimal/trusty64"

    # oracle java 8
    #  optional arguments
    #   type: defaults to "server-jre", but could also be "jre" or "jdk"
    #   version: defaults to "1.8.0_91", but could also be "1.8.0_74"
    config.vm.provision "shell", path: "https://raw.githubusercontent.com/jjlauer/vagrant-provision/master/linux/bootstrap-java8.sh",
      args: ["--type=server-jre"]

    # mysql 5.7
    #  optional arguments
    #   rootpw: defaults to "test"
    #   version: defaults to "5.7.12" but could be any valid 5.7.x version
    #   createdb: defaults to empty but is a database name to create
    config.vm.provision "shell", path: "https://raw.githubusercontent.com/jjlauer/vagrant-provision/master/linux/bootstrap-mysql57.sh",
      args: ["--rootpw=test", "--version=5.7.12", "--createdb=mydb"]
  end
end
```

### Non-vagrant (e.g. in a shell)

```
curl -O https://raw.githubusercontent.com/jjlauer/vagrant-provision/master/linux/bootstrap-java8.sh
chmod +x ./bootstrap-java8.sh
sudo ./bootstrap-java8.sh
```
