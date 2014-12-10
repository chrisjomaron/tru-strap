# -*- mode: ruby -*-
# vi: set ft=ruby :
#
# Vagrantfile   Provision MSM trustrap services.
#
# Authors:      Paul Gilligan, <Paul.Gilligan@moneysupermarket.com>
#
# Description:  Mixin ruby for provisioning Vagrantfile.

# -----------------------------------------------------------------------------
# Provision TANGO (dual haproxy gateways, one external on FE one internal on BE
# -----------------------------------------------------------------------------
TANGO_FE_FQDN = "#{TANGO_NAME}.#{TRUSTRAP_FE_DOMAIN}"
TANGO_BE_FQDN = "#{TANGO_NAME}.#{TRUSTRAP_BE_DOMAIN}"
config.vm.define "#{TANGO_FE_FQDN}" do |m|
  m.vm.provider "docker" do |vm|
    vm.name            = "#{TANGO_FE_FQDN}"
    vm.image           = "pauldavidgilligan/docker-centos6-haproxy"
    vm.has_ssh         = true
    vm.create_args = ["--privileged", "--dns-search=#{TRUSTRAP_DOMAIN}", "--dns=8.8.8.8", "--hostname=#{TANGO_FE_FQDN}"]
    vm.vagrant_machine = "dockerhost"
    vm.vagrant_vagrantfile = "../../Vagrantfile.proxy"
    if TRUSTRAP_WITH_SKYDNS
      vm.link("#{SKYDNS_NAME}.#{TRUSTRAP_DOMAIN}:#{SKYDNS_NAME}")
    end
  end
  if TRUSTRAP_WITH_SKYDNS
    m.vm.provision "file", source: "puppet", destination: "etc/"
    m.vm.provision :shell, :path => "bin/shell.sh", :args => "-n #{SKYDNS_NAME} -m resolv -d #{TRUSTRAP_DOMAIN}"
  end
end

config.vm.define "#{TANGO_BE_FQDN}" do |m|
  m.vm.provider "docker" do |vm|
    vm.name            = "#{TANGO_BE_FQDN}"
    vm.image           = "pauldavidgilligan/docker-centos6-haproxy"
    vm.has_ssh         = true
    vm.create_args = ["--privileged", "--dns-search=#{TRUSTRAP_DOMAIN}", "--dns=8.8.8.8", "--hostname=#{TANGO_BE_FQDN}"]
    vm.vagrant_machine = "dockerhost"
    vm.vagrant_vagrantfile = "../../Vagrantfile.proxy"
    if TRUSTRAP_WITH_SKYDNS
      vm.link("#{SKYDNS_NAME}.#{TRUSTRAP_DOMAIN}:#{SKYDNS_NAME}")
    end
  end
  if TRUSTRAP_WITH_SKYDNS
    m.vm.provision "file", source: "puppet", destination: "etc/"
    m.vm.provision :shell, :path => "bin/shell.sh", :args => "-n #{SKYDNS_NAME} -m resolv -d #{TRUSTRAP_DOMAIN}"
  end
end


