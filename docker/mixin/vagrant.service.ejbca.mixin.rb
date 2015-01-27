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
config.vm.define "#{EJBCA_FQDN}" do |m|
  # JBoss Console ports
  m.vm.network "forwarded_port", guest: 9990, host: 9990
  # EJBCA Service ports
  m.vm.network "forwarded_port", guest: 8080, host: 8080
  m.vm.network "forwarded_port", guest: 8443, host: 8443
  # Docker provider
  m.vm.provider "docker" do |vm|
    vm.name            = "#{EJBCA_FQDN}"
    vm.image           = "registry1-eu1.moneysupermarket.com:5000/docker-centos6-ejbca-mysql"
    vm.has_ssh         = true
    vm.create_args = ["--privileged", "--dns-search=#{TRUSTRAP_DOMAIN}", "--hostname=#{EJBCA_FQDN}"]
    vm.vagrant_machine = "dockerhost"
    vm.vagrant_vagrantfile = "../../Vagrantfile.proxy"
    if TRUSTRAP_WITH_SKYDNS
      vm.link("#{SKYDNS_NAME}.#{TRUSTRAP_DOMAIN}:#{SKYDNS_NAME}")
    end
  end
  if TRUSTRAP_WITH_SKYDNS
    m.vm.provision :shell, :path => "bin/shell.sh", :args => "-n #{SKYDNS_NAME} -m hosts -d #{TRUSTRAP_DOMAIN}"
    m.vm.provision :shell, :path => "bin/shell.sh", :args => "-n #{SKYDNS_NAME} -m resolv -d #{TRUSTRAP_DOMAIN} -o #{TRUSTRAP_NAMESERVER}"
    m.vm.provision :file, source: "puppet", destination: "etc/puppet/"
  end
  m.vm.provision :shell, inline: "echo \"After skydns registration, ant deploy(approx 1 min), wait to complete then ant install(approx 2mins)\""
  m.vm.provision :shell, :path => "bin/shell.sh", :args => "-n #{EJBCA_NAME} -m ejbca -d #{TRUSTRAP_DOMAIN}"
  m.vm.provision :shell, inline: "echo Node #{EJBCA_NAME} is very handsome!"
end

