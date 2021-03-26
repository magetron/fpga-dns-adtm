#pragma once

int com_admin_apply (char* arg) {
  printf("writing admin pkt to %s...\n", ADMIN_PKT_TMP_FILENAME);
  write_to_admin_pkt(f_curr, ADMIN_PKT_TMP_FILENAME);

  mac_addr_t srcmac = random_mac();
  ip_addr_t srcip = random_local_ip();
  ip_addr_t dstip = random_local_ip();
  udp_port_t srcport = random_unused_port();
  udp_port_t dstport = random_unused_port();
  read_file(ADMIN_PKT_TMP_FILENAME);
  form_packet(srcmac, admin_dst_mac, srcip, dstip, srcport, dstport,
    file_payload, file_payload_length);
  trigger_send();

  if (check_fpga_filter_matches(f_curr)) {
    printf("successful! apply confirmed via probing FPGA\n");
  } else {
    printf("failed! apply cannot be confirmed via probing FPGA\n");
  }

  return 0;
}
