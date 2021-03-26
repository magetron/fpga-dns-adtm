#pragma once

int test_reply_dns(filter_t& f) {
  mac_addr_t srcmac = random_mac();
  ip_addr_t srcip = random_local_ip();
  ip_addr_t dstip = random_local_ip();
  udp_port_t srcport = random_unused_port();
  udp_port_t dstport = random_unused_port();
  f.replyType = 1;
  write_to_admin_pkt(f, ADMIN_PKT_TMP_FILENAME);
  read_file(ADMIN_PKT_TMP_FILENAME);
  form_packet(srcmac, admin_dst_mac, srcip, dstip, srcport, dstport,
    file_payload, file_payload_length);
  trigger_send();
  if (!check_fpga_filter_matches(f)) {
    print_admin_mismatch_msg();
    return -1;
  }

  for (size_t i = 0; i < 10; i++) {
    mac_addr_t srcmac = random_mac();
    mac_addr_t dstmac = random_mac();

    ip_addr_t srcip = random_local_ip();
    ip_addr_t dstip = random_local_ip();
    udp_port_t srcport = random_unused_port();
    udp_port_t dstport = random_unused_port();
    uint64_t payload = i + rand();
    const size_t payload_length = 8;
    form_packet(srcmac, dstmac, srcip, dstip, srcport, dstport,
      reinterpret_cast<uint8_t *>(&payload), payload_length);
    trigger_send();

    uint8_t expect_dns_response[12];
    expect_dns_response[0] = reinterpret_cast<uint8_t *>(&payload)[0];
    expect_dns_response[1] = reinterpret_cast<uint8_t *>(&payload)[1];
    expect_dns_response[2] = 0x84;
    expect_dns_response[3] = 0x33;
    for (size_t j = 4; j < 12; j++) expect_dns_response[j] = 0x00;

    if (!expect_receive(reinterpret_cast<uint8_t *>(expect_dns_response), 12, 1000)) {
      print_not_recv_msg();
      return -1;
    }
    usleep(100);
  }
  return 0;
}


int test_reply(filter_t& f) {
  f = {}; if (test_reply_dns(f) == -1) { return -1; }
  return 0;
}
