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
@mopts = Hash["ETCD_MACHINES" => "http://go-skydns.#{TRUSTRAP_DOMAIN}:4001",
              "SKYDNS_ADDR" => "0.0.0.0:53",
              "SKYDNS_NAMESERVERS" => "8.8.8.8:53",
              "SKYDNS_DOMAIN" => "#{TRUSTRAP_DOMAIN}"]

config.vm.define "go-skydns" do |m|
  m.vm.provider "docker" do |vm|
    vm.name            = "go-skydns.#{TRUSTRAP_DOMAIN}"
    vm.image           = "pauldavidgilligan/go-skydns"
    vm.has_ssh         = false
    vm.env             = @mopts
    vm.create_args = ["--privileged", "--dns=8.8.8.8"]
    vm.vagrant_machine = "dockerhost"
    vm.vagrant_vagrantfile = "../../Vagrantfile.proxy"
  end
end




