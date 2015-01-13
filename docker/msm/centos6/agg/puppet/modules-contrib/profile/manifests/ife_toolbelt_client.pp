class profile::ife_toolbelt_client($entries){
  include ::toolbelt

  create_resources ( toolbelt::init, $entries )

}

