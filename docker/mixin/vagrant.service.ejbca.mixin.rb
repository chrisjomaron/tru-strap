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

config.vm.network "forwarded_port", guest: 8080, host: 8080
config.vm.network "forwarded_port", guest: 8443, host: 8443
config.vm.network "forwarded_port", guest: 9990, host: 9990
config.vm.network "forwarded_port", guest: 9999, host: 9999
config.vm.define "#{EJBCA_NAME}" do |m|
  m.vm.provider "docker" do |vm|
    vm.name            = "#{EJBCA_NAME}.#{TRUSTRAP_DOMAIN}"
    vm.image           = "pauldavidgilligan/docker-centos6-ejbca-mysql"
    vm.has_ssh         = true
    vm.create_args = ["--privileged", "--dns-search=#{TRUSTRAP_DOMAIN}", "--dns=8.8.8.8", "--hostname=#{EJBCA_NAME}"]
    vm.vagrant_machine = "dockerhost"
    vm.vagrant_vagrantfile = "../../Vagrantfile.proxy"
  end
  m.vm.provision :shell, :path => "bin/shell.sh", :args => "-n #{SKYDNS_NAME} -m ejbca -d #{TRUSTRAP_DOMAIN}"
  if TRUSTRAP_WITH_SKYDNS
    m.vm.provision :shell, :path => "bin/shell.sh", :args => "-n #{SKYDNS_NAME} -m resolv -d #{TRUSTRAP_DOMAIN}"
  end
end

