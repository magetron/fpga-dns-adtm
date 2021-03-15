#pragma once

#pragma once

int test_dns_empty(filter_t& f) {
  mac_addr_t srcmac = random_mac();
  ip_addr_t srcip = random_local_ip();
  ip_addr_t dstip = random_local_ip();
  udp_port_t srcport = random_unused_port();
  udp_port_t dstport = random_unused_port();
  f.dnsBW = 0;
  f.dnsLength = 0;
  write_to_admin_pkt(f, ADMIN_PKT_TMP_FILENAME);
  read_file(ADMIN_PKT_TMP_FILENAME);
  form_packet(srcmac, admin_dst_mac, srcip, dstip, srcport, dstport,
    file_payload, file_payload_length);
  trigger_send();
  probe_fpga_update_local();
  
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
    if (!expect_receive(reinterpret_cast<uint8_t *>(&payload), payload_length, 1000)) {
      print_not_recv_msg();
      return -1;
    }
    usleep(100);
  }
  return 0;
}

int test_dns_filter_one(filter_t& f) {
  mac_addr_t srcmac = random_mac();
  ip_addr_t srcip = random_local_ip();
  ip_addr_t dstip = random_local_ip();
  udp_port_t srcport = random_unused_port();
  udp_port_t dstport = random_unused_port();
  f.dnsBW = 0;
  f.dnsLength = 1;
  f.dnsItemEndPtr[0] = 8 * 9;
  memcpy(&f.dnsList[0], "apple.com", 9);
  write_to_admin_pkt(f, ADMIN_PKT_TMP_FILENAME);
  read_file(ADMIN_PKT_TMP_FILENAME);
  form_packet(srcmac, admin_dst_mac, srcip, dstip, srcport, dstport,
    file_payload, file_payload_length);
  trigger_send();
  probe_fpga_update_local();
  
  for (size_t i = 0; i < 10; i++) {
    mac_addr_t srcmac = random_mac();
    mac_addr_t dstmac = random_mac();
    
    ip_addr_t srcip = random_local_ip();
    ip_addr_t dstip = random_local_ip();
    udp_port_t srcport = random_unused_port();
    udp_port_t dstport = random_unused_port();

    uint8_t payload[20];
    size_t pos = rand() % (20 - 9);
    for (size_t i = 0; i < pos; i++) { payload[i] = rand() % 255; }
    memcpy(&payload[pos], &f.dnsList[0], f.dnsItemEndPtr[0] / 8);
    payload[pos + rand() % (f.dnsItemEndPtr[0] / 8)]++;
    const size_t payload_length = 20;

    form_packet(srcmac, dstmac, srcip, dstip, srcport, dstport,
      reinterpret_cast<uint8_t *>(&payload), payload_length);
    trigger_send();
    if (!expect_receive(reinterpret_cast<uint8_t *>(&payload), payload_length, 1000)) {
      print_not_recv_msg();
      return -1;
    }
    usleep(100);
  }

  for (size_t i = 0; i < 10; i++) {
    mac_addr_t srcmac = random_mac();
    mac_addr_t dstmac = random_mac();

    ip_addr_t srcip = random_local_ip();
    ip_addr_t dstip = random_local_ip();
    udp_port_t srcport = random_unused_port();
    udp_port_t dstport = random_unused_port();

    uint8_t payload[20];
    size_t pos = rand() % (20 - 9);
    for (size_t i = 0; i < pos; i++) { payload[i] = rand() % 255; }
    memcpy(&payload[pos], &f.dnsList[0], f.dnsItemEndPtr[0] / 8);
    //payload[pos + rand() % (f.dnsItemEndPtr[0] / 8)]++;
    const size_t payload_length = 20;

    form_packet(srcmac, dstmac, srcip, dstip, srcport, dstport,
      reinterpret_cast<uint8_t *>(&payload), payload_length);
    trigger_send();
    if (!expect_block(reinterpret_cast<uint8_t *>(&payload), payload_length, 1000)) {
      print_not_block_msg();
      return -1;
    }
    usleep(100);
  }
  return 0;
}

int test_dns_filter_two(filter_t& f) {
  mac_addr_t srcmac = random_mac();
  ip_addr_t srcip = random_local_ip();
  ip_addr_t dstip = random_local_ip();
  udp_port_t srcport = random_unused_port();
  udp_port_t dstport = random_unused_port();
  f.dnsBW = 0;
  f.dnsLength = 2;
  f.dnsItemEndPtr[0] = 8 * 12;
  memcpy(&f.dnsList[0], "patrickwu.uk", 12);
  f.dnsItemEndPtr[1] = 8 * 16;
  memcpy(&f.dnsList[1], "zitongli.mepaloa", 16);
  write_to_admin_pkt(f, ADMIN_PKT_TMP_FILENAME);
  read_file(ADMIN_PKT_TMP_FILENAME);
  form_packet(srcmac, admin_dst_mac, srcip, dstip, srcport, dstport,
    file_payload, file_payload_length);
  trigger_send();
  probe_fpga_update_local();
  
  for (size_t i = 0; i < 10; i++) {
    mac_addr_t srcmac = random_mac();
    mac_addr_t dstmac = random_mac();

    ip_addr_t srcip = random_local_ip();
    ip_addr_t dstip = random_local_ip();
    udp_port_t srcport = random_unused_port();
    udp_port_t dstport = random_unused_port();

    uint8_t payload[20];
    size_t pos = rand() % (20 - 16);
    for (size_t i = 0; i < pos; i++) { payload[i] = rand() % 255; }
    memcpy(&payload[pos], &f.dnsList[1], f.dnsItemEndPtr[1] / 8);
    payload[pos + rand() % (f.dnsItemEndPtr[1] / 8)]++;
    const size_t payload_length = 20;

    form_packet(srcmac, dstmac, srcip, dstip, srcport, dstport,
      reinterpret_cast<uint8_t *>(&payload), payload_length);
    trigger_send();
    if (!expect_receive(reinterpret_cast<uint8_t *>(&payload), payload_length, 1000)) {
      print_not_recv_msg();
      return -1;
    }
    usleep(100);
  }

  for (size_t i = 0; i < 10; i++) {
    mac_addr_t srcmac = random_mac();
    mac_addr_t dstmac = random_mac();

    ip_addr_t srcip = random_local_ip();
    ip_addr_t dstip = random_local_ip();
    udp_port_t srcport = random_unused_port();
    udp_port_t dstport = random_unused_port();

    size_t index = rand() % 2;
    
    form_packet(srcmac, dstmac, srcip, dstip, srcport, dstport,
      reinterpret_cast<uint8_t *>(&f.dnsList[index]), f.dnsItemEndPtr[index] / 8);
    trigger_send();
    if (!expect_block(reinterpret_cast<uint8_t *>(&f.dnsList[index]), f.dnsItemEndPtr[index] / 8, 1000)) {
      print_not_block_msg();
      return -1;
    }
    usleep(100);
  }

  return 0;
}

int test_dns_empty_white(filter_t& f) {
  mac_addr_t srcmac = random_mac();
  ip_addr_t srcip = random_local_ip();
  ip_addr_t dstip = random_local_ip();
  udp_port_t srcport = random_unused_port();
  udp_port_t dstport = random_unused_port();
  f.dnsBW = 1;
  f.dnsLength = 0;
  write_to_admin_pkt(f, ADMIN_PKT_TMP_FILENAME);
  read_file(ADMIN_PKT_TMP_FILENAME);
  form_packet(srcmac, admin_dst_mac, srcip, dstip, srcport, dstport,
    file_payload, file_payload_length);
  trigger_send();
  probe_fpga_update_local();
  
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
    if (!expect_block(reinterpret_cast<uint8_t *>(&payload), payload_length, 1000)) {
      print_not_block_msg();
      return -1;
    }
    usleep(100);
  }
  return 0;
}

int test_dns_filter_one_white(filter_t& f) {
  mac_addr_t srcmac = random_mac();
  ip_addr_t srcip = random_local_ip();
  ip_addr_t dstip = random_local_ip();
  udp_port_t srcport = random_unused_port();
  udp_port_t dstport = random_unused_port();
  f.dnsBW = 1;
  f.dnsLength = 1;
  f.dnsItemEndPtr[0] = 8 * 9;
  memcpy(&f.dnsList[0], "apple.com", 9);
  write_to_admin_pkt(f, ADMIN_PKT_TMP_FILENAME);
  read_file(ADMIN_PKT_TMP_FILENAME);
  form_packet(srcmac, admin_dst_mac, srcip, dstip, srcport, dstport,
    file_payload, file_payload_length);
  trigger_send();
  probe_fpga_update_local();
  
  for (size_t i = 0; i < 10; i++) {
    mac_addr_t srcmac = random_mac();
    mac_addr_t dstmac = random_mac();
    
    ip_addr_t srcip = random_local_ip();
    ip_addr_t dstip = random_local_ip();
    udp_port_t srcport = random_unused_port();
    udp_port_t dstport = random_unused_port();

    uint8_t payload[20];
    size_t pos = rand() % (20 - 9);
    for (size_t i = 0; i < pos; i++) { payload[i] = rand() % 255; }
    memcpy(&payload[pos], &f.dnsList[0], f.dnsItemEndPtr[0] / 8);
    payload[pos + rand() % (f.dnsItemEndPtr[0] / 8)]++;
    const size_t payload_length = 20;

    form_packet(srcmac, dstmac, srcip, dstip, srcport, dstport,
      reinterpret_cast<uint8_t *>(&payload), payload_length);
    trigger_send();
    if (!expect_block(reinterpret_cast<uint8_t *>(&payload), payload_length, 1000)) {
      print_not_block_msg();
      return -1;
    }
    usleep(100);
  }

  for (size_t i = 0; i < 10; i++) {
    mac_addr_t srcmac = random_mac();
    mac_addr_t dstmac = random_mac();

    ip_addr_t srcip = random_local_ip();
    ip_addr_t dstip = random_local_ip();
    udp_port_t srcport = random_unused_port();
    udp_port_t dstport = random_unused_port();

    uint8_t payload[20];
    size_t pos = rand() % (20 - 9);
    for (size_t i = 0; i < pos; i++) { payload[i] = rand() % 255; }
    memcpy(&payload[pos], &f.dnsList[0], f.dnsItemEndPtr[0] / 8);
    //payload[pos + rand() % (f.dnsItemEndPtr[0] / 8)]++;
    const size_t payload_length = 20;

    form_packet(srcmac, dstmac, srcip, dstip, srcport, dstport,
      reinterpret_cast<uint8_t *>(&payload), payload_length);
    trigger_send();
    if (!expect_receive(reinterpret_cast<uint8_t *>(&payload), payload_length, 1000)) {
      print_not_recv_msg();
      return -1;
    }
    usleep(100);
  }
  return 0;
}

int test_dns_filter_two_white(filter_t& f) {
  mac_addr_t srcmac = random_mac();
  ip_addr_t srcip = random_local_ip();
  ip_addr_t dstip = random_local_ip();
  udp_port_t srcport = random_unused_port();
  udp_port_t dstport = random_unused_port();
  f.dnsBW = 1;
  f.dnsLength = 2;
  f.dnsItemEndPtr[0] = 8 * 12;
  memcpy(&f.dnsList[0], "patrickwu.uk", 12);
  f.dnsItemEndPtr[1] = 8 * 16;
  memcpy(&f.dnsList[1], "zitongli.mepaloa", 16);
  write_to_admin_pkt(f, ADMIN_PKT_TMP_FILENAME);
  read_file(ADMIN_PKT_TMP_FILENAME);
  form_packet(srcmac, admin_dst_mac, srcip, dstip, srcport, dstport,
    file_payload, file_payload_length);
  trigger_send();
  probe_fpga_update_local();
  
  for (size_t i = 0; i < 10; i++) {
    mac_addr_t srcmac = random_mac();
    mac_addr_t dstmac = random_mac();

    ip_addr_t srcip = random_local_ip();
    ip_addr_t dstip = random_local_ip();
    udp_port_t srcport = random_unused_port();
    udp_port_t dstport = random_unused_port();

    uint8_t payload[20];
    size_t pos = rand() % (20 - 16);
    for (size_t i = 0; i < pos; i++) { payload[i] = rand() % 255; }
    memcpy(&payload[pos], &f.dnsList[1], f.dnsItemEndPtr[1] / 8);
    payload[pos + rand() % (f.dnsItemEndPtr[1] / 8)]++;
    const size_t payload_length = 20;

    form_packet(srcmac, dstmac, srcip, dstip, srcport, dstport,
      reinterpret_cast<uint8_t *>(&payload), payload_length);
    trigger_send();
    if (!expect_block(reinterpret_cast<uint8_t *>(&payload), payload_length, 1000)) {
      print_not_block_msg();
      return -1;
    }
    usleep(100);
  }

  for (size_t i = 0; i < 10; i++) {
    mac_addr_t srcmac = random_mac();
    mac_addr_t dstmac = random_mac();

    ip_addr_t srcip = random_local_ip();
    ip_addr_t dstip = random_local_ip();
    udp_port_t srcport = random_unused_port();
    udp_port_t dstport = random_unused_port();

    size_t index = rand() % 2;
    
    form_packet(srcmac, dstmac, srcip, dstip, srcport, dstport,
      reinterpret_cast<uint8_t *>(&f.dnsList[index]), f.dnsItemEndPtr[index] / 8);
    trigger_send();
    if (!expect_receive(reinterpret_cast<uint8_t *>(&f.dnsList[index]), f.dnsItemEndPtr[index] / 8, 1000)) {
      print_not_recv_msg();
      return -1;
    }
    usleep(100);
  }

  return 0;
}

int test_dns_filters(filter_t& f) {
  if (test_dns_empty(f)      == -1) { return -1; }
  if (test_dns_filter_one(f) == -1) { return -1; }
  if (test_dns_filter_two(f) == -1) { return -1; }
  if (test_dns_empty_white(f)      == -1) { return -1; }
  if (test_dns_filter_one_white(f) == -1) { return -1; }
  if (test_dns_filter_two_white(f) == -1) { return -1; }
  return 0;
}
