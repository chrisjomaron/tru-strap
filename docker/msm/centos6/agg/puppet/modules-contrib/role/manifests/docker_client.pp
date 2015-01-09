class role::docker_client {
  include ::profile::java
  include ::profile::maven
  include ::profile::skydns_client

  $alias_ca              = "root.msm.internal"
  $path                  = "/etc/pki/msm"
  $combined_password     = "8ruNestu"
  $truststore_password   = "changeit"
  $challenge_password    = "sW6Qecra"
  $combined_algorithm    = "SHA256WithRSAEncryption"
  $key_size              = "4096"
  $cert_days             = "7"
  $x509_cn               = "*.web.be.msm.internal"
  $x509_ou               = "OPS"
  $x509_o                = "Moneysupermarket.com Group PLC"
  $x509_l                = "Chester"
  $x509_s                = "Cheshire"
  $x509_c                = "UK"
  $ejbca_url             = "http://ejbca.msm.internal:8080/ejbca/publicweb/apply/scep/pkiclient.exe"
  $ejbca_ca              = "MSMCA"

  # java -jar /opt/ife-toolbelt/ife-spring-shell/target/ife-spring-shell-1.1.4.one-jar.jar

  file { "/etc/pki/msm":
    ensure => "directory",
    owner  => "root",
    group  => "wheel",
    mode   => 777
  }

  vcsrepo { "/opt/ife-toolbelt":
    ensure   => present,
    provider => git,
    source   => "https://github.com/pauldavidgilligan-msm/ife-toolbelt.git",
    revision => '1.1.4',
  } ->
  exec { "ife-toolbelt-mvn":
    cwd     => "/opt/ife-toolbelt",
    command => "mvn clean install",
    path    => "/usr/local/bin/:/usr/bin:/bin/",
    require => Class['Maven::Maven']
  } ->
  file { "ife-toolbelt-cfg":
    path    => '/etc/ife-toolbelt.cfg',
    ensure  => file,
    content => template('role/ife-toolbelt/ife-toolbelt.cfg.erb')
  }

  if versioncmp($::puppetversion,'3.6.1') >= 0 {

    $allow_virtual_packages = hiera('allow_virtual_packages',false)

    Package {
      allow_virtual => $allow_virtual_packages,
    }
}

}
