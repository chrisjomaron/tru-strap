class profile::os_limits ($sysctl_vm_max_map_count=0, $sysctl_net_core_somaxconn=128, $sysctl_net_ipv4_tcp_tw_recycle=0, $sysctl_net_ipv4_tcp_tw_reuse) {

  if $sysctl_vm_max_map_count != 0 {
    sysctl { 'vm.max_map_count': value => $sysctl_vm_max_map_count }
  }
  sysctl { 'net.core.somaxconn': value => $sysctl_net_core_somaxconn }
  sysctl { 'net.ipv4.tcp_tw_recycle': value => $sysctl_net_ipv4_tcp_tw_recycle }
  sysctl { 'net.ipv4.tcp_tw_reuse': value => $sysctl_net_ipv4_tcp_tw_reuse }
  include ::limits

}
