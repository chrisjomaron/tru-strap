# -*- mode: ruby -*-
# vi: set ft=ruby :
#
# Vagrantfile   Provision MSM trustrap services.
#
# Authors:      Paul Gilligan, <Paul.Gilligan@moneysupermarket.com>
#
# Description:  Mixin ruby for provisioning Vagrantfile.

# -----------------------------------------------------------------------------
# Service Options
# -----------------------------------------------------------------------------
services.each do |service, params|

  if service == "#{TRUSTRAP_ENV}-#{TRUSTRAP_SERVICE}"
    domain = params.detect {|param| param['domain']}
    TRUSTRAP_DOMAIN = domain['domain']
    if TRUSTRAP_DOMAIN
      puts "TRUSTRAP_DOMAIN       #{TRUSTRAP_DOMAIN}"
    else
      abort("Domain variable: 'domain' is not set in file #{YAML_OPTIONS}, exiting ...")
    end

    skydns = params.detect {|param| param['skydns']}
    if skydns
      TRUSTRAP_WITH_SKYDNS = skydns['skydns']
    else
     TRUSTRAP_WITH_SKYDNS = false
    end
    puts "TRUSTRAP_WITH_SKYDNS  #{TRUSTRAP_WITH_SKYDNS}"

  else
    abort("Service variable: #{TRUSTRAP_ENV}-#{TRUSTRAP_SERVICE} is not set in file #{YAML_OPTIONS}, exiting ...")
  end
end # if service == "#{TRUSTRAP_ENV}-#{TRUSTRAP_SERVICE}"


