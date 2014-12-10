# -*- mode: ruby -*-
# vi: set ft=ruby :
#
# Vagrantfile   Provision MSM trustrap services.
#
# Authors:      Paul Gilligan, <Paul.Gilligan@moneysupermarket.com>
#
# Description:  Mixin ruby for provisioning Vagrantfile.

# -----------------------------------------------------------------------------
# Provision EJBCA
# -----------------------------------------------------------------------------
EJBCA_FQDN = "#{EJBCA_NAME}.#{TRUSTRAP_DOMAIN}"
# config.vm.network "forwarded_port", guest: 9999, host: 9999
config.vm.define "#{EJBCA_FQDN}" do |m|
  m.vm.provider "docker" do |vm|
    vm.name            = "#{EJBCA_FQDN}"
    vm.image           = "pauldavidgilligan/docker-centos6-ejbca-mysql"
    vm.has_ssh         = true
    vm.create_args = ["--privileged", "--dns-search=#{TRUSTRAP_DOMAIN}", "--dns=8.8.8.8", "--hostname=#{EJBCA_FQDN}"]
    vm.vagrant_machine = "dockerhost"
    vm.vagrant_vagrantfile = "../../Vagrantfile.proxy"
    if TRUSTRAP_WITH_SKYDNS
      vm.link("#{SKYDNS_NAME}.#{TRUSTRAP_DOMAIN}:#{SKYDNS_NAME}")
    end
  end
  #m.vm.provision "shell", inline: "echo \"ant deploy(approx 1 min), wait to complete then ant install(approx 2mins)\""
  #m.vm.provision :shell, :path => "bin/shell.sh", :args => "-n #{EJBCA_NAME} -m ejbca -d #{TRUSTRAP_DOMAIN}"
  if TRUSTRAP_WITH_SKYDNS
    m.vm.provision :shell, :path => "bin/shell.sh", :args => "-n #{SKYDNS_NAME} -m resolv -d #{TRUSTRAP_DOMAIN}"
  end
end

