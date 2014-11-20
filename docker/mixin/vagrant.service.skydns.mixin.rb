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
$script = <<SCRIPT
RESULT=`pgrep etcd`
if [ "${RESULT:-null}" = null ]; then
  echo
else
  echo "Configuring skydns"
  /usr/bin/curl -XPUT http://127.0.0.1:4001/v2/keys/skydns/config \
    -d value='{"dns_addr":"0.0.0.0:53","ttl":3600, "domain":"msm.internal", "nameservers": ["8.8.8.8:53","8.8.4.4:53"]}'
fi
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
  m.vm.provision "shell", inline: $script
  m.vm.provision :shell, :path => "bin/shell.sh", :args => "-n #{SKYDNS_NAME} -m hosts -d #{TRUSTRAP_DOMAIN}"
  m.vm.provision :shell, :path => "bin/shell.sh", :args => "-n #{SKYDNS_NAME} -m start -d #{TRUSTRAP_DOMAIN}"
end

