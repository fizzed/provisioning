Provisioning Scripts
====================

Scripts for provisioning Vagrant virtual machines or even bare
metal installs of various operating systems.

### Vagrant

```ruby
Vagrant.configure(2) do |config|
  config.vm.define "ubuntu1404", primary: true do |guest|
    guest.vm.box = "minimal/trusty64"

    # oracle java 8: arg is jre, server-jre, or jdk
    config.vm.provision "shell", path: "linux/bootstrap-java8.sh", args: "server-jre"
  end
end
```

### Outside vagrant

```
curl -O https://github.com/jjlauer/vagrant-provision/blah
sudo chmod +x 
sudo 
```
