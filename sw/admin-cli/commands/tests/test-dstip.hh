#pragma once

int test_ip_dstip_empty(filter_t& f) {
  mac_addr_t srcmac = random_mac();
  ip_addr_t srcip = random_local_ip();
  ip_addr_t dstip = random_local_ip();
  udp_port_t srcport = random_unused_port();
  udp_port_t dstport = random_unused_port();
  f.dstIPBW = 0;
  f.dstIPLength = 0;
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
    if (!expect_receive(reinterpret_cast<uint8_t *>(&payload), payload_length, 1000)) {
      print_not_recv_msg();
      return -1;
    }
    usleep(100);
  }
  return 0;
}

int test_ip_dstip_filter_one(filter_t& f) {
  mac_addr_t srcmac = random_mac();
  ip_addr_t srcip = random_local_ip();
  ip_addr_t dstip = random_local_ip();
  udp_port_t srcport = random_unused_port();
  udp_port_t dstport = random_unused_port();
  f.dstIPBW = 0;
  f.dstIPLength = 1;
  f.dstIPList[0] = random_local_ip();
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
    // srcip doesn't match filtered ip
    mac_addr_t srcmac = random_mac();
    mac_addr_t dstmac = random_mac();

    ip_addr_t srcip = random_local_ip();
    ip_addr_t dstip;
    do { dstip = random_local_ip(); } while (memcmp(&dstip, &f.dstIPList[0], sizeof(ip_addr_t)) == 0);

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

  for (size_t i = 0; i < 10; i++) {
    mac_addr_t srcmac = random_mac();
    mac_addr_t dstmac = random_mac();

    ip_addr_t srcip = random_local_ip();
    ip_addr_t dstip = f.dstIPList[0];
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

int test_ip_dstip_filter_two(filter_t& f) {
  mac_addr_t srcmac = random_mac();
  ip_addr_t srcip = random_local_ip();
  ip_addr_t dstip = random_local_ip();
  udp_port_t srcport = random_unused_port();
  udp_port_t dstport = random_unused_port();
  f.dstIPBW = 0;
  f.dstIPLength = 2;
  f.dstIPList[0] = random_local_ip();
  f.dstIPList[1] = random_local_ip();
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

    ip_addr_t srcip= random_local_ip();
    ip_addr_t dstip;
    do { dstip = random_local_ip(); } while (memcmp(&dstip, &f.dstIPList[0], sizeof(ip_addr_t)) == 0 ||
                                             memcmp(&dstip, &f.dstIPList[1], sizeof(ip_addr_t)) == 0);

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

  for (size_t i = 0; i < 10; i++) {
    mac_addr_t srcmac = random_mac();
    mac_addr_t dstmac = random_mac();

    ip_addr_t srcip = random_local_ip();
    ip_addr_t dstip = f.dstIPList[rand() % 2];
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

int test_ip_dstip_empty_white(filter_t& f) {
  mac_addr_t srcmac = random_mac();
  ip_addr_t srcip = random_local_ip();
  ip_addr_t dstip = random_local_ip();
  udp_port_t srcport = random_unused_port();
  udp_port_t dstport = random_unused_port();
  f.dstIPBW = 1;
  f.dstIPLength = 0;
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
    if (!expect_block(reinterpret_cast<uint8_t *>(&payload), payload_length, 1000)) {
      print_not_block_msg();
      return -1;
    }
    usleep(100);
  }
  return 0;
}

int test_ip_dstip_filter_one_white(filter_t& f) {
  mac_addr_t srcmac = random_mac();
  ip_addr_t srcip = random_local_ip();
  ip_addr_t dstip = random_local_ip();
  udp_port_t srcport = random_unused_port();
  udp_port_t dstport = random_unused_port();
  f.dstIPBW = 1;
  f.dstIPLength = 1;
  f.dstIPList[0] = random_local_ip();
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
    // srcip doesn't match filtered ip
    mac_addr_t srcmac = random_mac();
    mac_addr_t dstmac = random_mac();

    ip_addr_t srcip = random_local_ip();
    ip_addr_t dstip;
    do { dstip = random_local_ip(); } while (memcmp(&dstip, &f.dstIPList[0], sizeof(ip_addr_t)) == 0);

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

  for (size_t i = 0; i < 10; i++) {
    mac_addr_t srcmac = random_mac();
    mac_addr_t dstmac = random_mac();

    ip_addr_t srcip = random_local_ip();
    ip_addr_t dstip = f.dstIPList[0];
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

int test_ip_dstip_filter_two_white(filter_t& f) {
  mac_addr_t srcmac = random_mac();
  ip_addr_t srcip = random_local_ip();
  ip_addr_t dstip = random_local_ip();
  udp_port_t srcport = random_unused_port();
  udp_port_t dstport = random_unused_port();
  f.dstIPBW = 1;
  f.dstIPLength = 2;
  f.dstIPList[0] = random_local_ip();
  f.dstIPList[1] = random_local_ip();
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

    ip_addr_t srcip= random_local_ip();
    ip_addr_t dstip;
    do { dstip = random_local_ip(); } while (memcmp(&dstip, &f.dstIPList[0], sizeof(ip_addr_t)) == 0 ||
                                             memcmp(&dstip, &f.dstIPList[1], sizeof(ip_addr_t)) == 0);

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

  for (size_t i = 0; i < 10; i++) {
    mac_addr_t srcmac = random_mac();
    mac_addr_t dstmac = random_mac();

    ip_addr_t srcip = random_local_ip();
    ip_addr_t dstip = f.dstIPList[rand() % 2];
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

int test_dstip_filters(filter_t& f) {
  f = {}; if (test_ip_dstip_empty(f)      == -1) { return -1; }
  f = {}; if (test_ip_dstip_filter_one(f) == -1) { return -1; }
  f = {}; if (test_ip_dstip_filter_two(f) == -1) { return -1; }
  f = {}; if (test_ip_dstip_empty_white(f)      == -1) { return -1; }
  f = {}; if (test_ip_dstip_filter_one_white(f) == -1) { return -1; }
  f = {}; if (test_ip_dstip_filter_two_white(f) == -1) { return -1; }
  return 0;
}


