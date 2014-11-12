# -*- mode: ruby -*-
# vi: set ft=ruby :
#
# Vagrantfile   Provision MSM trustrap services.
#
# Authors:      Paul Gilligan, <Paul.Gilligan@moneysupermarket.com>
#
# Description:  Mixin ruby for provisioning Vagrantfile.

# -----------------------------------------------------------------------------
# Environment Options
# -----------------------------------------------------------------------------
ENV['VAGRANT_DEFAULT_PROVIDER'] = 'docker'

if ENV['TRUSTRAP_ACCOUNT']
    TRUSTRAP_ACCOUNT = ENV['TRUSTRAP_ACCOUNT']
else
  abort("Environment variable: 'TRUSTRAP_ACCOUNT' is not set, exiting ...")
end

if ENV['TRUSTRAP_USERBASE']
    TRUSTRAP_USERBASE = ENV['TRUSTRAP_USERBASE']
else
  abort("Environment variable: 'TRUSTRAP_USERBASE' is not set, exiting ...")
end

if ENV['TRUSTRAP_ENV']
    TRUSTRAP_ENV = ENV['TRUSTRAP_ENV']
else
  abort("Environment variable: 'TRUSTRAP_ENV' is not set, exiting ...")
end

if ENV['TRUSTRAP_SERVICE']
    TRUSTRAP_SERVICE = ENV['TRUSTRAP_SERVICE']
else
  abort("Environment variable: 'TRUSTRAP_SERVICE' is not set, exiting ...")
end

