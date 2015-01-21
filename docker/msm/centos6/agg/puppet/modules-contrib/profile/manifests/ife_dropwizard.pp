class profile::ife_dropwizard($entries){
  include ::toolbelt

  create_resources ( toolbelt::examples::dropwizard, $entries )

}

