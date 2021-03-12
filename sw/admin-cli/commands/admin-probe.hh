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

  probe_reply_received = 0;
  trigger_send();
  probe_reply_recv(PROBE_TIMEOUT);
  if (!probe_reply_received) {
    fprintf(stderr, "ERROR no probe reply received within timeout %ld set\n", PROBE_TIMEOUT);
    return -1;
  }

  auto probe_response = parse_probe_pkt(probe_pkt_buf, probe_pkt_length);

  //f = probe_response.filter;
  // metrics = metrics

  return 0;
}
