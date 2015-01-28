# -*- mode: ruby -*-
# vi: set ft=ruby :
#
# Vagrantfile   Provision MSM trustrap services.
#
# Authors:      Paul Gilligan, <Paul.Gilligan@moneysupermarket.com>
#
# Description:  Mixin ruby for provisioning Vagrantfile.

# -----------------------------------------------------------------------------
# Provision SkyDNS via ETCD
# -----------------------------------------------------------------------------
SKYDNS_FQDN = "#{SKYDNS_NAME}.#{TRUSTRAP_DOMAIN}"
config.vm.define "#{SKYDNS_FQDN}" do |m|
  m.vm.provider "docker" do |vm|
    vm.name            = "#{SKYDNS_FQDN}"
    vm.image           = "registry1-eu1.moneysupermarket.com:5000/go-skydns"
    vm.has_ssh         = true
    vm.create_args     = ["--privileged", "--dns-search=#{TRUSTRAP_DOMAIN}", "--hostname=#{SKYDNS_FQDN}"]
    vm.cmd             = ['/usr/bin/supervisord', '--configuration=/etc/supervisord.conf']
    vm.vagrant_machine = "dockerhost"
    vm.vagrant_vagrantfile = "../../Vagrantfile.proxy"
  end
  m.vm.provision :shell, :path => "bin/shell.sh", :args => "-n #{SKYDNS_NAME} -m config -d #{TRUSTRAP_DOMAIN}"
  m.vm.provision :shell, :path => "bin/shell.sh", :args => "-n #{SKYDNS_NAME} -m hosts -d  #{TRUSTRAP_DOMAIN}"
  m.vm.provision :shell, :path => "bin/shell.sh", :args => "-n #{SKYDNS_NAME} -m start -d  #{TRUSTRAP_DOMAIN}"
end

