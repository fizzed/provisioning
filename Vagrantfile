Vagrant.configure(2) do |config|

  config.vm.define "ubuntu14", primary: true do |guest|
    guest.vm.box = "minimal/trusty64"

    config.vm.provision "shell", path: "linux/bootstrap-java8.sh",
      args: ["--type=server-jre", "--version=1.8.0_102"]
    # to verify it installed:
    #  vagrant ssh -c "java -version"

    #config.vm.provision "shell", path: "linux/bootstrap-elasticsearch.sh",
    #  args: ["--version=2.3.2"]
    #config.vm.network "forwarded_port", guest: 9200, host: 9200
    # to verify it installed:
    #  curl http://localhost:9200

    #config.vm.provision "shell", path: "linux/bootstrap-mysql57.sh",
    #  args: ["--version=5.7.12", "--rootpw=test", "--createdb=mydb"]
    #config.vm.network "forwarded_port", guest: 3306, host: 3306

    #config.vm.provision "shell", path: "linux/bootstrap-postgres95.sh"
    #config.vm.network "forwarded_port", guest: 5432, host: 5432

    #config.vm.provision "shell", path: "linux/bootstrap-redis.sh",
    #  args: ["--version=3.2.3", "--host=0.0.0.0", "--password=test"]
    #config.vm.network "forwarded_port", guest: 6379, host: 6379
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
