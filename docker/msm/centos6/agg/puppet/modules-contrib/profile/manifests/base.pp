class profile::base {
  include ::timezone

  service { 'crond': }

  package { 'bash': ensure => latest }
}
