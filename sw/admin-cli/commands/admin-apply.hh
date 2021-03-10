#pragma once

int com_admin_apply (char* arg) {
  write_to_admin_pkt(f_curr);

  mac_addr_t srcmac = {0x0a, 0x97, 0x4f, 0x48, 0xc9, 0xfe};
  ip_addr_t srcip = {0, 0, 0, 0};
  ip_addr_t dstip = {10, 0, 0, 0};
  udp_port_t srcport = {12345};
  udp_port_t dstport = {23456};
  read_file(ADMIN_PKT_TMP_FILENAME);
  form_packet(srcmac, admin_dst_mac, srcip, dstip, srcport, dstport,
    file_payload, file_payload_length);
  trigger_send();

  f = f_curr;

  return 0;
}
