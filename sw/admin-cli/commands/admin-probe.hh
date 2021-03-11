#pragma once



int com_admin_probe (char* arg) {

  mac_addr_t srcmac = random_mac();
  ip_addr_t srcip = random_local_ip();
  ip_addr_t dstip = random_local_ip();
  udp_port_t srcport = random_unused_port();
  udp_port_t dstport = random_unused_port();
  const char* payload = "probe packet";
  fake_file(payload, strnlen(payload, 16));
  form_packet(srcmac, probe_dst_mac, srcip, dstip, srcport, dstport,
    file_payload, file_payload_length);
  trigger_send();
  trigger_recv(probe_dst_mac, 10);
  
  uint8_t* save_probe_pkt = reinterpret_cast<uint8_t *>(malloc(recv_pkt_length));
  size_t save_probe_size = recv_pkt_length;
  memcpy(save_probe_pkt, recv_pkt_buf, save_probe_size);
  auto probe_response = parse_probe_pkt(save_probe_pkt, save_probe_size);

  f = probe_response.filter;
  // metrics = metrics

  return 0;
}
 