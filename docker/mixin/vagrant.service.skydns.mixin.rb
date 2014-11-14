# -*- mode: ruby -*-
# vi: set ft=ruby :
#
# Vagrantfile   Provision MSM trustrap services.
#
# Authors:      Paul Gilligan, <Paul.Gilligan@moneysupermarket.com>
#
# Description:  Mixin ruby for provisioning Vagrantfile.

# -----------------------------------------------------------------------------
# Provision SkyDNS on ETCD
# -----------------------------------------------------------------------------
config.vm.define "#{SKYDNS_NAME}" do |m|
  m.vm.provider "docker" do |vm|
    vm.name            = "#{SKYDNS_NAME}.#{TRUSTRAP_DOMAIN}"
    vm.image           = "pauldavidgilligan/go-skydns"
    vm.has_ssh         = true
    vm.create_args = ["--privileged", "--dns-search=#{TRUSTRAP_DOMAIN}", "--dns=8.8.8.8", "--hostname=#{SKYDNS_NAME}"]
    vm.vagrant_machine = "dockerhost"
    vm.vagrant_vagrantfile = "../../Vagrantfile.proxy"
  end
end
config.vm.provision :shell, :path => "bin/dockerenv.py"
config.vm.provision :shell, :path => "bin/hosts.sh"
config.vm.provision :shell, :path => "bin/startskydns.sh"

