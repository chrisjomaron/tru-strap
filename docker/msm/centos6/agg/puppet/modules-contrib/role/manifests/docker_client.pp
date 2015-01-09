class role::docker_client {
  include ::profile::java
  include ::profile::maven
  include ::profile::skydns_client

  # java -jar /opt/ife-toolbelt/ife-spring-shell/target/ife-spring-shell-1.1.4.one-jar.jar

  file { "/etc/pki/msm":
    ensure => "directory",
    owner  => "root",
    group  => "wheel",
    mode   => 777
  }

  vcsrepo { '/opt/ife-toolbelt':
    ensure   => present,
    provider => git,
    source   => 'https://github.com/pauldavidgilligan-msm/ife-toolbelt.git',
    revision => '1.1.4',
  } ->
  exec { "ife-toolbelt":
    cwd     => "/opt/ife-toolbelt",
    command => "mvn clean install",
    path    => "/usr/local/bin/:/usr/bin:/bin/",
    require => Class['Maven::Maven']
  }

}
