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

    # domain
    domain = params.detect {|param| param['domain']}
    TRUSTRAP_DOMAIN = domain['domain']
    if TRUSTRAP_DOMAIN
      puts "TRUSTRAP_DOMAIN       #{TRUSTRAP_DOMAIN}"
    else
      abort("Domain variable: 'domain' is not set in file #{YAML_OPTIONS}, exiting ...")
    end

    fe_domain = params.detect {|param| param['fe-domain']}
    TRUSTRAP_FE_DOMAIN = fe_domain['fe-domain']
    if TRUSTRAP_FE_DOMAIN
      puts "TRUSTRAP_FE_DOMAIN    #{TRUSTRAP_FE_DOMAIN}"
    else
      abort("Domain variable: 'fe-domain' is not set in file #{YAML_OPTIONS}, exiting ...")
    end

    be_domain = params.detect {|param| param['be-domain']}
    TRUSTRAP_BE_DOMAIN = be_domain['be-domain']
    if TRUSTRAP_BE_DOMAIN
      puts "TRUSTRAP_BE_DOMAIN    #{TRUSTRAP_BE_DOMAIN}"
    else
      abort("Domain variable: 'be-domain' is not set in file #{YAML_OPTIONS}, exiting ...")
    end

    # dns
    skydns = params.detect {|param| param['skydns']}
    if skydns
      TRUSTRAP_WITH_SKYDNS = skydns['skydns']
    else
      TRUSTRAP_WITH_SKYDNS = false
    end
    puts "TRUSTRAP_WITH_SKYDNS  #{TRUSTRAP_WITH_SKYDNS}"

    # ca
    ejbca = params.detect {|param| param['ejbca']}
    if ejbca
      TRUSTRAP_WITH_EJBCA = ejbca['ejbca']
    else
      TRUSTRAP_WITH_EJBCA = false
    end
    puts "TRUSTRAP_WITH_EBJCA   #{TRUSTRAP_WITH_EJBCA}"

    # haproxy gw's aka tango
    tango = params.detect {|param| param['tango']}
    if tango
      TRUSTRAP_WITH_TANGO = tango['tango']
    else
      TRUSTRAP_WITH_TANGO = false
    end
    puts "TRUSTRAP_WITH_TANGO   #{TRUSTRAP_WITH_TANGO}"

  else
    abort("Service variable: #{TRUSTRAP_ENV}-#{TRUSTRAP_SERVICE} is not set in file #{YAML_OPTIONS}, exiting ...")
  end
end # if service == "#{TRUSTRAP_ENV}-#{TRUSTRAP_SERVICE}"


