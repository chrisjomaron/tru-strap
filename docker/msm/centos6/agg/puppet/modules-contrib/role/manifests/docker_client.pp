class role::docker_client {
  include ::profile::java
  include ::profile::maven
  include ::profile::skydns_client
}
