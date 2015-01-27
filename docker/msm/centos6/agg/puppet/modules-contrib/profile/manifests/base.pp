class profile::base {
  include ::timezone

  service { 'crond': }

  package { 'bash': ensure => latest }

  # fix puppet here
  if versioncmp($::puppetversion,'3.6.1') >= 0 {
    $allow_virtual_packages = hiera('allow_virtual_packages',false)

    Package {
      allow_virtual => $allow_virtual_packages,
    }
  }
   
}
