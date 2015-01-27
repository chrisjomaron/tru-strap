class profile::ife_dropwizard($entries){
  include ::toolbelt

  $defaults = {
    truststore_password   => 'changeit'
  }

  create_resources ( toolbelt::examples::dropwizard, $entries, $defaults )

}

