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
    m.vm.provision :shell, :path => "bin/shell.sh", :args => "-n #{SKYDNS_NAME} -m hosts -d #{TRUSTRAP_DOMAIN}"
    m.vm.provision :shell, :path => "bin/shell.sh", :args => "-n #{SKYDNS_NAME} -m resolv -d #{TRUSTRAP_DOMAIN}"
    m.vm.provision :file, source: "puppet", destination: "etc/puppet/"
    m.vm.provision :shell, inline: "mkdir -p /root/.ssh && touch /root/.ssh/known_hosts && ssh-keyscan -H github.com >> /root/.ssh/known_hosts && chmod 600 /root/.ssh/known_hosts"
    m.vm.provision :shell, inline: "cd /home/dev-ops/etc/puppet && librarian-puppet install --verbose --path modules-contrib"
    m.vm.provision :shell, inline: "puppet apply --modulepath=/home/dev-ops/etc/puppet/modules-contrib --hiera_config=/home/dev-ops/etc/puppet/hiera.yaml -e \"include role::skydns_client\""
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
    m.vm.provision :shell, :path => "bin/shell.sh", :args => "-n #{SKYDNS_NAME} -m hosts -d #{TRUSTRAP_DOMAIN}"
    m.vm.provision :shell, :path => "bin/shell.sh", :args => "-n #{SKYDNS_NAME} -m resolv -d #{TRUSTRAP_DOMAIN}"
    m.vm.provision :file, source: "puppet", destination: "etc/puppet/"
    m.vm.provision :shell, inline: "mkdir -p /root/.ssh && touch /root/.ssh/known_hosts && ssh-keyscan -H github.com >> /root/.ssh/known_hosts && chmod 600 /root/.ssh/known_hosts"
    m.vm.provision :shell, inline: "cd /home/dev-ops/etc/puppet && librarian-puppet install --verbose --path modules-contrib"
    m.vm.provision :shell, inline: "puppet apply --modulepath=/home/dev-ops/etc/puppet/modules-contrib --hiera_config=/home/dev-ops/etc/puppet/hiera.yaml -e \"include role::skydns_client\""
  end
end


