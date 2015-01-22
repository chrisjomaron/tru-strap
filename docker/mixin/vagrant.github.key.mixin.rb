# -*- mode: ruby -*-
# vi: set ft=ruby :
#
# Vagrantfile   Provision MSM trustrap services.
#
# Authors:      Paul Gilligan, <Paul.Gilligan@moneysupermarket.com>
#
# Description:  Mixin ruby for provisioning Vagrantfile.
#

if File.exists?(File.join(Dir.home, ".ssh", "github_rsa"))
  github_ssh_key = File.read(File.join(Dir.home, ".ssh", "github_rsa"))
    m.vm.provision :shell, :inline => "echo 'Copying local GitHub SSH Key to VM for provisioning...' && mkdir -p /root/.ssh && echo '#{github_ssh_key}' > /root/.ssh/id_rsa && chmod 600 /root/.ssh/id_rsa"
else
  raise Vagrant::Errors::VagrantError, "\n\nERROR: GitHub SSH Key not found at ~/.ssh/github_rsa (required on Windows).\nYou can generate this key manually! \n\n"
end
