class profile::skydns_client ($entries){
  include ::skydns_client
  create_resources ( skydns_client::client, $entries )
}

