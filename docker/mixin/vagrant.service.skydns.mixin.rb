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
$script = <<SCRIPT
echo Setting go-skydns environment
echo # profile.d env file for go-skydns                 > /etc/profile.d/go-skydns.sh
echo export ETCD_ADDR=etcd.msm.internal:4001           >> /etc/profile.d/go-skydns.sh 
echo export ETCD_BIND_ADDR=0.0.0.0:4001                >> /etc/profile.d/go-skydns.sh
echo export ETCD_PEER_ADDR=etcd.msm.internal:7001      >> /etc/profile.d/go-skydns.sh
echo export ETCD_PEER_BIND_ADDR=etcd.msm.internal:7001 >> /etc/profile.d/go-skydns.sh
echo export SKYDNS_ADDR=0.0.0.0:53                     >> /etc/profile.d/go-skydns.sh
echo export SKYDNS_DOMAIN=msm.internal                 >> /etc/profile.d/go-skydns.sh
echo export SKYDNS_NAMESERVERS=8.8.8.8:53,8.8.4.4:53   >> /etc/profile.d/go-skydns.sh
echo export ETCD_MACHINES="http://localhost:4001,http://etcd.msm.internal:4001" >> /etc/profile.d/go-skydns.sh
SCRIPT

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

config.vm.provision "shell", inline: $script
config.vm.provision :shell, :path => "bin/hosts.sh"
config.vm.provision :shell, :path => "bin/startskydns.sh"
