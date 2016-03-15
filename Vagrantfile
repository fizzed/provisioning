Vagrant.configure(2) do |config|


  config.vm.define "ubuntu1404", primary: true do |guest|
    guest.vm.box = "minimal/trusty64"

    # oracle java 8: arg is jre, server-jre, or jdk
    #config.vm.provision "shell", path: "linux/bootstrap-java8.sh", args: "server-jre"
  end


  config.vm.define "debian8", autostart: false do |guest|
    guest.vm.box = "minimal/jessie64"

    # oracle java 8: arg is jre, server-jre, or jdk
    config.vm.provision "shell", path: "linux/bootstrap-java8.sh", args: "server-jre"
  end


  config.vm.define "centos7", autostart: false do |guest|
    guest.vm.box = "minimal/centos7"

    # oracle java 8: arg is jre, server-jre, or jdk
    config.vm.provision "shell", path: "linux/bootstrap-java8.sh", args: "server-jre"
  end
end
