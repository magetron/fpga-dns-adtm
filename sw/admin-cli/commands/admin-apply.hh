#pragma once

int com_admin_apply (char* arg) {
  write_to_admin_pkt(f_curr);

  mac_addr_t srcmac = random_mac();
  ip_addr_t srcip = random_local_ip();
  ip_addr_t dstip = random_local_ip();
  udp_port_t srcport = random_unused_port();
  udp_port_t dstport = random_unused_port();
  read_file(ADMIN_PKT_TMP_FILENAME);
  form_packet(srcmac, admin_dst_mac, srcip, dstip, srcport, dstport,
    file_payload, file_payload_length);
  trigger_send();

  f = f_curr;

  return 0;
}
