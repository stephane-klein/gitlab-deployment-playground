$logger = Log4r::Logger.new('vagrantfile')
def read_ip_address(machine)
  command = "ip -o addr show dev enp0s8 | grep 'inet ' | cut -d: -f2 | awk '{ print $3 }' | cut -f1 -d\"/\""
  result  = ""

  $logger.info "Processing #{ machine.name } ... "

  begin
    # sudo is needed for ifconfig
    machine.communicate.sudo(command) do |type, data|
      result << data if type == :stdout
    end
    $logger.info "Processing #{ machine.name } ... success"
  rescue
    result = "# NOT-UP"
    $logger.info "Processing #{ machine.name } ... not running"
  end

  # the second inet is more accurate
  result.chomp.split("\n").select { |hash| hash != "" }[0]
end

Vagrant.configure("2") do |config|
  config.vm.provider :virtualbox do |vb|
    vb.customize [ "modifyvm", :id, "--uartmode1", "disconnected" ] # to disable ubuntu-*-cloudimg-console.log
  end

  config.hostmanager.enabled = true
  config.hostmanager.manage_host = true
  config.hostmanager.manage_guest = true

  if Vagrant.has_plugin?("HostManager")
  config.hostmanager.ip_resolver = proc do |vm, resolving_vm|
    read_ip_address(vm)
  end
  end

  config.vm.define :gitlab_server do |gitlab_server|
    gitlab_server.vm.box = "ubuntu/bionic64"
    gitlab_server.vm.hostname = "gitlab"
    gitlab_server.vm.synced_folder '.', '/vagrant/', disabled: false
    gitlab_server.vm.network "private_network", type: "dhcp"

    gitlab_server.vm.provision "shell", path: "install.sh"
    gitlab_server.hostmanager.aliases = ["gitlab.example.com"]
    gitlab_server.vm.provider :virtualbox do |vb|
      vb.memory = '4024'
      vb.cpus = '1'
    end
  end
end
