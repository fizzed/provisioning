Provisioning Scripts
====================

Scripts for provisioning machines.  Primarly used to provision
vagrant instances, but can be used for config of machines in the
cloud or bare metal.

### Vagrant

```ruby
Vagrant.configure(2) do |config|
  config.vm.define "ubuntu1404", primary: true do |guest|
    guest.vm.box = "minimal/trusty64"

    # oracle java 8: arg is jre, server-jre, or jdk
    config.vm.provision "shell", path: "https://raw.githubusercontent.com/jjlauer/vagrant-provision/master/linux/bootstrap-java8.sh", args: "server-jre"
  end
end
```

### Outside vagrant

```
curl -O https://raw.githubusercontent.com/jjlauer/vagrant-provision/master/linux/bootstrap-java8.sh
chmod +x ./bootstrap-java8.sh
sudo ./bootstrap-java8.sh
```
