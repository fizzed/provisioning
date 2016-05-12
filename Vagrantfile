Vagrant.configure(2) do |config|

  config.vm.define "ubuntu14", primary: true do |guest|
    guest.vm.box = "minimal/trusty64"

    #config.vm.provision "shell", path: "linux/bootstrap-java8.sh", args: "server-jre"

    #config.vm.provision "shell", path: "linux/bootstrap-mysql57.sh", args: "test"
    #config.vm.network "forwarded_port", guest: 3306, host: 3306, auto_correct: true

    config.vm.provision "shell", path: "linux/bootstrap-postgres95.sh"
    config.vm.network "forwarded_port", guest: 5432, host: 5432, auto_correct: true
  end


  config.vm.define "debian8", autostart: false do |guest|
    guest.vm.box = "minimal/jessie64"

    config.vm.provision "shell", path: "linux/bootstrap-java8.sh", args: "server-jre"
    config.vm.provision "shell", path: "linux/bootstrap-maven.sh"
  end


  config.vm.define "centos7", autostart: false do |guest|
    guest.vm.box = "minimal/centos7"

    config.vm.provision "shell", path: "linux/bootstrap-java8.sh", args: "server-jre"
  end
end
