class profile::ife_toolbelt_client($entries){
  include ::toolbelt

  $defaults = {
    alias_ca              => 'root.msm.internal',
    path                  => '/etc/pki/msm',
    truststore_password   => 'changeit',
    combined_algorithm    => 'SHA256WithRSAEncryption',
    key_size              => '4096',
    cert_days             => '7',
    x509_ou               => 'OPS',
    x509_o                => 'Moneysupermarket.com Group PLC',
    x509_l                => 'Chester',
    x509_s                => 'Cheshire',
    x509_c                => 'UK',
    ejbca_url             => 'http://ejbca.msm.internal:8080/ejbca/publicweb/apply/scep/pkiclient.exe',
    ejbca_ca              => 'MSMCA'
  }

  create_resources ( toolbelt::client, $entries, $defaults )

}

