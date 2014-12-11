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
# config.vm.network "forwarded_port", guest: 9999, host: 9999
config.vm.define "#{EJBCA_FQDN}" do |m|
  m.vm.provider "docker" do |vm|
    vm.name            = "#{EJBCA_FQDN}"
    vm.image           = "pauldavidgilligan/docker-centos6-ejbca-mysql"
    vm.has_ssh         = true
    vm.create_args = ["--privileged", "--dns-search=#{TRUSTRAP_DOMAIN}", "--dns=8.8.8.8", "--hostname=#{EJBCA_FQDN}"]
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
  #m.vm.provision :shell, inline: "echo \"ant deploy(approx 1 min), wait to complete then ant install(approx 2mins)\""
  # m.vm.provision :shell, :path => "bin/shell.sh", :args => "-n #{EJBCA_NAME} -m ejbca -d #{TRUSTRAP_DOMAIN}"
end

