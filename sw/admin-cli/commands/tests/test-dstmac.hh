int test_mac_dstmac_empty(filter_t& f) {
  mac_addr_t srcmac = random_mac();
  ip_addr_t srcip = random_local_ip();
  ip_addr_t dstip = random_local_ip();
  udp_port_t srcport = random_unused_port();
  udp_port_t dstport = random_unused_port();
  f.dstMACBW = 0;
  f.dstMACLength = 0;
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
      printf("FPGA validation failed, expect packet not received.\n");
      return -1;
    }
    usleep(100);
  }
  return 0;
}

int test_mac_dstmac_filter_one(filter_t& f) {
  mac_addr_t srcmac = random_mac();
  ip_addr_t srcip = random_local_ip();
  ip_addr_t dstip = random_local_ip();
  udp_port_t srcport = random_unused_port();
  udp_port_t dstport = random_unused_port();
  f.dstMACBW = 0;
  f.dstMACLength = 1;
  f.dstMACList[0] = random_mac();
  write_to_admin_pkt(f, ADMIN_PKT_TMP_FILENAME);
  read_file(ADMIN_PKT_TMP_FILENAME);
  form_packet(srcmac, admin_dst_mac, srcip, dstip, srcport, dstport,
    file_payload, file_payload_length);
  trigger_send();
  probe_fpga_update_local();
  
  for (size_t i = 0; i < 10; i++) {
    // dstmac doesn't match filtered mac
    mac_addr_t srcmac = random_mac();

    mac_addr_t dstmac;
    do { dstmac = random_mac(); } while (memcmp(&srcmac, &f.dstMACList[0], sizeof(mac_addr_t)) == 0);

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
      printf("FPGA validation failed, expect packet not received.\n");
      return -1;
    }
    usleep(100);
  }

  for (size_t i = 0; i < 10; i++) {
    // srcmac does match filtered mac
    mac_addr_t srcmac = random_mac();
    mac_addr_t dstmac = f.dstMACList[0];

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
      printf("FPGA validation failed, block not successful.\n");
      return -1;
    }
    usleep(100);
  }
  return 0;
}

int test_mac_dstmac_filter_two(filter_t& f) {
  mac_addr_t srcmac = random_mac();
  ip_addr_t srcip = random_local_ip();
  ip_addr_t dstip = random_local_ip();
  udp_port_t srcport = random_unused_port();
  udp_port_t dstport = random_unused_port();
  f.dstMACBW = 0;
  f.dstMACLength = 2;
  f.dstMACList[0] = random_mac();
  f.dstMACList[1] = random_mac();
  write_to_admin_pkt(f, ADMIN_PKT_TMP_FILENAME);
  read_file(ADMIN_PKT_TMP_FILENAME);
  form_packet(srcmac, admin_dst_mac, srcip, dstip, srcport, dstport,
    file_payload, file_payload_length);
  trigger_send();
  probe_fpga_update_local();
  
  for (size_t i = 0; i < 10; i++) {
    // dstmac doesn't match filtered mac
    mac_addr_t srcmac = random_mac();

    mac_addr_t dstmac;
    do { dstmac = random_mac(); } while (memcmp(&dstmac, &f.dstMACList[0], sizeof(mac_addr_t)) == 0 ||
                                         memcmp(&dstmac, &f.dstMACList[1], sizeof(mac_addr_t)) == 0);

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
      printf("FPGA validation failed, expect packet not received.\n");
      return -1;
    }
    usleep(100);
  }

  for (size_t i = 0; i < 10; i++) {
    // srcmac does match filtered mac
    mac_addr_t srcmac = random_mac();
    mac_addr_t dstmac = f.dstMACList[rand() % 2];

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
      printf("FPGA validation failed, block not successful.\n");
      return -1;
    }
    usleep(100);
  }

  return 0;
}

int test_dstmac_filters(filter_t& f) {
  if (test_mac_dstmac_empty(f)      == -1) { return -1; }
  if (test_mac_dstmac_filter_one(f) == -1) { return -1; }
  if (test_mac_dstmac_filter_two(f) == -1) { return -1; }
  return 0;
}
