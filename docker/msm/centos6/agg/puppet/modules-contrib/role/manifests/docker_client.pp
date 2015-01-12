class role::docker_client {

  include wait_for

  Wait_for {
    polling_frequency => 10,
    max_retries       => 15
  }

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
  $x509_cn               = $msmid_registered
  $x509_ou               = "OPS"
  $x509_o                = "Moneysupermarket.com Group PLC"
  $x509_l                = "Chester"
  $x509_s                = "Cheshire"
  $x509_c                = "UK"
  $ejbca_url             = "http://ejbca.msm.internal:8080/ejbca/publicweb/apply/scep/pkiclient.exe"
  $ejbca_ca              = "MSMCA"

  # java -jar /opt/ife-toolbelt/ife-spring-shell/target/ife-spring-shell-1.1.4.one-jar.jar

  $cmd = "ife pki generate --CN $msmid_registered\nife scep ca\nife scep enroll --CN $msmid_registered\nexit\n"

  file { "/etc/pki/msm":
    ensure => "directory",
    owner  => "root",
    group  => "wheel",
    mode   => 777
  } ->
  file { "/tmp/enrol.cmd":
    content => $cmd
  } ->
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
  wait_for { 'cat /etc/facter/facts.d/skydns_custom_values.txt':
    regex   => '.*msmid_registered.*'
  } ->
  file { "ife-toolbelt-cfg":
    path    => "/etc/ife-toolbelt.cfg",
    ensure  => file,
    content => template("role/ife-toolbelt/ife-toolbelt.cfg.erb"),
  } ->
  exec { "enrol_client":
    command => "/usr/bin/java -jar  /opt/ife-toolbelt/ife-spring-shell/target/ife-spring-shell-1.1.4.one-jar.jar --cmdfile /tmp/enrol.cmd ",
    path    => "/usr/local/bin/:/bin/"
  }

  # local message fix
  if versioncmp($::puppetversion,'3.6.1') >= 0 {

    $allow_virtual_packages = hiera('allow_virtual_packages',false)

    Package {
      allow_virtual => $allow_virtual_packages,
    }
}

}
