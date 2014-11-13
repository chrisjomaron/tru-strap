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
@mopts = Hash["ETCD_MACHINES" => "http://etcd.#{TRUSTRAP_DOMAIN}:4001",
              "SKYDNS_ADDR" => "0.0.0.0:53",
              "SKYDNS_NAMESERVERS" => "8.8.8.8:53",
              "SKYDNS_DOMAIN" => "#{TRUSTRAP_DOMAIN}"]

config.vm.define "#{SKYDNS_NAME}" do |m|
  m.vm.provider "docker" do |vm|
    vm.name            = "#{SKYDNS_NAME}.#{TRUSTRAP_DOMAIN}"
    vm.image           = "pauldavidgilligan/go-skydns"
    vm.has_ssh         = false # yes we have ssh, but fool vagrant so no shells are ran.
    vm.env             = @mopts
    vm.create_args = ["--privileged", "--dns-search=#{TRUSTRAP_DOMAIN}", "--dns=8.8.8.8", "--hostname=#{SKYDNS_NAME}"]
    vm.vagrant_machine = "dockerhost"
    vm.vagrant_vagrantfile = "../../Vagrantfile.proxy"
  end
end




