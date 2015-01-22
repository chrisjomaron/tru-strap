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
    vm.image           = "registry1-eu1.moneysupermarket.com:5000/docker-centos6-haproxy"
    vm.has_ssh         = true
    vm.create_args = ["--privileged", "--dns-search=#{TRUSTRAP_DOMAIN}", "--dns=8.8.8.8", "--hostname=#{TANGO_FE_FQDN}"]
    vm.vagrant_machine = "dockerhost"
    vm.vagrant_vagrantfile = "../../Vagrantfile.proxy"
    if TRUSTRAP_WITH_SKYDNS
      vm.link("#{SKYDNS_NAME}.#{TRUSTRAP_DOMAIN}:#{SKYDNS_NAME}")
    end
    if TRUSTRAP_WITH_EJBCA
      vm.link("#{EJBCA_NAME}.#{TRUSTRAP_DOMAIN}:#{EJBCA_NAME}.#{TRUSTRAP_DOMAIN}")
    end
  end
  if TRUSTRAP_WITH_SKYDNS
    m.vm.provision :shell, :path => "bin/shell.sh", :args => "-n #{SKYDNS_NAME} -m hosts -d #{TRUSTRAP_DOMAIN}"
    m.vm.provision :shell, :path => "bin/shell.sh", :args => "-n #{SKYDNS_NAME} -m resolv -d #{TRUSTRAP_DOMAIN}"
    m.vm.provision :file, source: "puppet", destination: "etc/puppet/"
    eval(IO.read("../../../mixin/vagrant.github.key.mixin.rb"), binding)
    m.vm.provision :shell, :path => "bin/shell.sh", :args => "-n #{SKYDNS_NAME} -m app_client -d #{TRUSTRAP_DOMAIN}"
  end
  m.vm.provision :shell, inline: "echo Node #{TANGO_FE_FQDN} is very handsome!"
end

config.vm.define "#{TANGO_BE_FQDN}" do |m|
  m.vm.provider "docker" do |vm|
    vm.name            = "#{TANGO_BE_FQDN}"
    vm.image           = "registry1-eu1.moneysupermarket.com:5000/docker-centos6-haproxy"
    vm.has_ssh         = true
    vm.create_args = ["--privileged", "--dns-search=#{TRUSTRAP_DOMAIN}", "--dns=8.8.8.8", "--hostname=#{TANGO_BE_FQDN}"]
    vm.vagrant_machine = "dockerhost"
    vm.vagrant_vagrantfile = "../../Vagrantfile.proxy"
    if TRUSTRAP_WITH_SKYDNS
      vm.link("#{SKYDNS_NAME}.#{TRUSTRAP_DOMAIN}:#{SKYDNS_NAME}")
    end
    if TRUSTRAP_WITH_EJBCA
      vm.link("#{EJBCA_NAME}.#{TRUSTRAP_DOMAIN}:#{EJBCA_NAME}.#{TRUSTRAP_DOMAIN}")
    end
  end
  if TRUSTRAP_WITH_SKYDNS
    m.vm.provision :shell, :path => "bin/shell.sh", :args => "-n #{SKYDNS_NAME} -m hosts -d #{TRUSTRAP_DOMAIN}"
    m.vm.provision :shell, :path => "bin/shell.sh", :args => "-n #{SKYDNS_NAME} -m resolv -d #{TRUSTRAP_DOMAIN}"
    m.vm.provision :file, source: "puppet", destination: "etc/puppet/"
    m.vm.provision :shell, :path => "bin/shell.sh", :args => "-n #{SKYDNS_NAME} -m app_client -d #{TRUSTRAP_DOMAIN}"
  end
  m.vm.provision :shell, inline: "echo Node #{TANGO_BE_FQDN} is very handsome!"
end

#
# Create 3 backend sample web apps a, b and c.
# The virtual DNS entries n1, n2, n3 do not match a, b and c.
#

WEB_1_FQDN="na.web.#{TRUSTRAP_BE_DOMAIN}"
WEB_2_FQDN="nb.web.#{TRUSTRAP_BE_DOMAIN}"
WEB_3_FQDN="nc.web.#{TRUSTRAP_BE_DOMAIN}"

config.vm.define "#{WEB_1_FQDN}" do |m|
  m.vm.provider "docker" do |vm|
    vm.name            = "#{WEB_1_FQDN}"
    vm.image           = "registry1-eu1.moneysupermarket.com:5000/docker-centos6-dropwizard"
    vm.has_ssh         = true
    vm.create_args = ["--privileged", "--dns-search=#{TRUSTRAP_DOMAIN}", "--dns=8.8.8.8", "--hostname=#{WEB_1_FQDN}"]
    vm.vagrant_machine = "dockerhost"
    vm.vagrant_vagrantfile = "../../Vagrantfile.proxy"
    if TRUSTRAP_WITH_SKYDNS
      vm.link("#{SKYDNS_NAME}.#{TRUSTRAP_DOMAIN}:#{SKYDNS_NAME}")
    end
  end
  if TRUSTRAP_WITH_SKYDNS
    m.vm.provision :shell, :path => "bin/shell.sh", :args => "-n #{SKYDNS_NAME} -m hosts -d #{TRUSTRAP_DOMAIN}"
    m.vm.provision :shell, :path => "bin/shell.sh", :args => "-n #{SKYDNS_NAME} -m resolv -d #{TRUSTRAP_DOMAIN}"
    m.vm.provision :file, source: "puppet", destination: "etc/puppet/"
    m.vm.provision :shell, :path => "bin/shell.sh", :args => "-n #{SKYDNS_NAME} -m web_client -d #{TRUSTRAP_DOMAIN}"
  end
  m.vm.provision :shell, inline: "echo Node #{WEB_1_FQDN} is very handsome!"
end

config.vm.define "#{WEB_2_FQDN}" do |m|
  m.vm.provider "docker" do |vm|
    vm.name            = "#{WEB_2_FQDN}"
    vm.image           = "micktwomey/sample-dropwizard-service"
    vm.has_ssh         = false
    vm.create_args = ["--privileged", "--dns-search=#{TRUSTRAP_DOMAIN}", "--dns=8.8.8.8", "--hostname=#{WEB_2_FQDN}"]
    vm.vagrant_machine = "dockerhost"
    vm.vagrant_vagrantfile = "../../Vagrantfile.proxy"
    if TRUSTRAP_WITH_SKYDNS
      vm.link("#{SKYDNS_NAME}.#{TRUSTRAP_DOMAIN}:#{SKYDNS_NAME}")
    end
  end
  if TRUSTRAP_WITH_SKYDNS
    m.vm.provision :shell, :path => "bin/shell.sh", :args => "-n #{SKYDNS_NAME} -m hosts -d #{TRUSTRAP_DOMAIN}"
    m.vm.provision :shell, :path => "bin/shell.sh", :args => "-n #{SKYDNS_NAME} -m resolv -d #{TRUSTRAP_DOMAIN}"
    m.vm.provision :file, source: "puppet", destination: "etc/puppet/"
    m.vm.provision :shell, :path => "bin/shell.sh", :args => "-n #{SKYDNS_NAME} -m app_client -d #{TRUSTRAP_DOMAIN}"
  end
  m.vm.provision :shell, inline: "echo Node #{WEB_2_FQDN} is very handsome!"
end

config.vm.define "#{WEB_3_FQDN}" do |m|
  m.vm.provider "docker" do |vm|
    vm.name            = "#{WEB_3_FQDN}"
    vm.image           = "micktwomey/sample-dropwizard-service"
    vm.has_ssh         = false
    vm.create_args = ["--privileged", "--dns-search=#{TRUSTRAP_DOMAIN}", "--dns=8.8.8.8", "--hostname=#{WEB_3_FQDN}"]
    vm.vagrant_machine = "dockerhost"
    vm.vagrant_vagrantfile = "../../Vagrantfile.proxy"
    if TRUSTRAP_WITH_SKYDNS
      vm.link("#{SKYDNS_NAME}.#{TRUSTRAP_DOMAIN}:#{SKYDNS_NAME}")
    end
  end
  if TRUSTRAP_WITH_SKYDNS
    m.vm.provision :shell, :path => "bin/shell.sh", :args => "-n #{SKYDNS_NAME} -m hosts -d #{TRUSTRAP_DOMAIN}"
    m.vm.provision :shell, :path => "bin/shell.sh", :args => "-n #{SKYDNS_NAME} -m resolv -d #{TRUSTRAP_DOMAIN}"
    m.vm.provision :file, source: "puppet", destination: "etc/puppet/"
    m.vm.provision :shell, :path => "bin/shell.sh", :args => "-n #{SKYDNS_NAME} -m app_client -d #{TRUSTRAP_DOMAIN}"
  end
  m.vm.provision :shell, inline: "echo Node #{WEB_3_FQDN} is very handsome!"
end

