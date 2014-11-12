# -*- mode: ruby -*-
# vi: set ft=ruby :
#
# Vagrantfile   Provision MSM trustrap services.
#
# Authors:      Paul Gilligan, <Paul.Gilligan@moneysupermarket.com>
#
# Description:  Mixin ruby for provisioning Vagrantfile.

# -----------------------------------------------------------------------------
# Provision SkyDNS
# -----------------------------------------------------------------------------
config.vm.define "etcd" do |m|
  m.vm.provider "docker" do |vm|
    vm.name            = "etcd.#{TRUSTRAP_DOMAIN}"
    vm.image           = "registry1-eu1.moneysupermarket.com:5000/etcd"
    vm.has_ssh         = false
    vm.cmd             = ["-peer-addr=etcd.#{TRUSTRAP_DOMAIN}:7001", "-addr=etcd.#{TRUSTRAP_DOMAIN}:4001"]
    vm.vagrant_machine = "dockerhost"
    vm.vagrant_vagrantfile = "../../Vagrantfile.proxy"
  end
end

@mopts = Hash["ETCD_MACHINES" => "http://etcd.#{TRUSTRAP_DOMAIN}:4001",
              "SKYDNS_ADDR" => "0.0.0.0:53",
              "SKYDNS_NAMESERVERS" => "8.8.8.8:53",
              "SKYDNS_DOMAIN" => "#{TRUSTRAP_DOMAIN}"]

config.vm.define "skydns" do |m|
  m.vm.provider "docker" do |vm|
    vm.name            = "skydns.#{TRUSTRAP_DOMAIN}"
    vm.image           = "skynetservices/skydns"
    vm.has_ssh         = false
    vm.env             = @mopts
    vm.vagrant_machine = "dockerhost"
    vm.vagrant_vagrantfile = "../../Vagrantfile.proxy"
    vm.link("etcd.#{TRUSTRAP_DOMAIN}:etcd")
  end
end




