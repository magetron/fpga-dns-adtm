#pragma once

struct [[gnu::packed]] probe_response_t {
  filter_t f;
  stats_t s;
};

uint64_t extract_bits_from_arr (uint8_t* pkt, size_t s, size_t e) {
  uint64_t buf = 0;
  size_t sb = s / 8;
  size_t so = s % 8;
  size_t eb = e / 8;
  size_t eo = e % 8 + 1;
  if (sb == eb) {
    buf = (pkt[sb] & (0xff - ((1 << so) - 1) - (((1 << (8 - eo)) - 1) << eo))) >> so;
  } else {
    for (size_t i = sb; i <= eb; i++) {
      if (i == sb) {
        buf = ((uint64_t)pkt[sb] & (0xff - ((1 << so) - 1))) >> so;
      } else if (i == eb) {
        buf |= ((uint64_t)pkt[eb] & (0xff - (((1 << (8 - eo)) - 1) << eo))) << ((i - sb) * 8 - so);
      } else {
        buf |= (uint64_t)pkt[i] << ((i - sb) * 8 - so);
      }
    }
  }

  return buf;
}

filter_t parse_admin_bin(uint8_t* payload, size_t length) {
  if (length < 85) {
    fprintf(stderr, "ERROR invalid admin payload");
    return f_curr;
  }

  filter_t f = {};

  f.srcMACBW       = extract_bits_from_arr(payload, 0, 0);
  f.srcMACLength   = extract_bits_from_arr(payload, 1, 2);
  f.dstMACBW       = extract_bits_from_arr(payload, 99, 99);
  f.dstMACLength   = extract_bits_from_arr(payload, 100, 101);
  for (size_t i = 0; i < 2; i++) {
    for (size_t j = 0; j < 6; j++) {
      f.srcMACList[i].byte[j] = extract_bits_from_arr(payload, 3 + i * 48 + j * 8, 10 + i * 48 + j * 8);
      f.dstMACList[i].byte[j] = extract_bits_from_arr(payload, 102 + i * 48 + j * 8, 109 + i * 48 + j * 8);
    }
  }
  f.srcIPBW        = extract_bits_from_arr(payload, 198, 198);
  f.srcIPLength    = extract_bits_from_arr(payload, 199, 200);
  f.dstIPBW        = extract_bits_from_arr(payload, 265, 265);
  f.dstIPLength    = extract_bits_from_arr(payload, 266, 267);
  for (size_t i = 0; i < 2; i++) {
    for (size_t j = 0; j < 4; j++) {
      f.srcIPList[i].num[j] = extract_bits_from_arr(payload, 201 + i * 32 + j * 8, 208 + i * 32 + j * 8);
      f.dstIPList[i].num[j] = extract_bits_from_arr(payload, 268 + i * 32 + j * 8, 275 + i * 32 + j * 8);
    }
  }
  f.srcIPBW        = extract_bits_from_arr(payload, 198, 198);
  f.srcIPLength    = extract_bits_from_arr(payload, 199, 200);
  f.dstIPBW        = extract_bits_from_arr(payload, 265, 265);
  f.dstIPLength    = extract_bits_from_arr(payload, 266, 267);
  for (size_t i = 0; i < 2; i++) {
    for (size_t j = 0; j < 4; j++) {
      f.srcIPList[i].num[j] = extract_bits_from_arr(payload, 201 + i * 32 + j * 8, 208 + i * 32 + j * 8);
      f.dstIPList[i].num[j] = extract_bits_from_arr(payload, 268 + i * 32 + j * 8, 275 + i * 32 + j * 8);
    }
  }
  f.srcPortBW      = extract_bits_from_arr(payload, 332, 332);
  f.srcPortLength  = extract_bits_from_arr(payload, 333, 334);
  f.dstPortBW      = extract_bits_from_arr(payload, 367, 367);
  f.dstPortLength  = extract_bits_from_arr(payload, 368, 369);
  for (size_t i = 0; i < 2; i++) {
    f.srcPortList[i].port = ntohs((uint16_t)extract_bits_from_arr(payload, 335 + i * 16, 350 + i * 16));
    f.dstPortList[i].port = ntohs((uint16_t)extract_bits_from_arr(payload, 370 + i * 16, 385 + i * 16));
  }

  f.dnsBW          = extract_bits_from_arr(payload, 402, 402);
  f.dnsLength      = extract_bits_from_arr(payload, 403, 404);
  for (size_t i = 0; i < 2; i++) {
    f.dnsItemEndPtr[i] = extract_bits_from_arr(payload, 405 + i * 8, 412 + i * 8);
    for (size_t j = 0; j < 16; j++) {
      f.dnsList[i].c[j] = extract_bits_from_arr(payload, 421 + i * 128 + j * 8, 428 + i * 128 + j * 8);
    }
  }

  return f;
}

probe_response_t parse_probe_pkt(uint8_t* pkt, size_t length) {
  probe_response_t pr;

  auto* eth_hdr = reinterpret_cast<ethhdr*>(pkt);
  auto* ip_hdr = reinterpret_cast<ip*>(eth_hdr + 1);
  auto* udp_hdr = reinterpret_cast<udphdr*>(ip_hdr + 1);
  auto* payload = reinterpret_cast<uint8_t*>(udp_hdr + 1);
  length -= sizeof(eth_hdr) + sizeof(ip_hdr) + sizeof(udp_hdr);
  //printf("len = %ld\n", length);

  if (length < 128) {
    fprintf(stderr, "ERROR invalid return probe pkt\n");
    return {};
  }

  pr.f = parse_admin_bin(payload, length);
  pr.s.stc = extract_bits_from_arr(payload, 678, 741);
  pr.s.sfc = extract_bits_from_arr(payload, 742, 805);
  pr.s.smc = extract_bits_from_arr(payload, 806, 869);
  pr.s.sic = extract_bits_from_arr(payload, 870, 933);
  pr.s.spc = extract_bits_from_arr(payload, 934, 997);


  return pr;
}

probe_response_t probe_fpga () {
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
    return {};
  }

  return parse_probe_pkt(probe_pkt_buf, probe_pkt_length);
}

void probe_fpga_update_local () {
  printf("probing FPGA for on-board configurations and stats...\n");
  probe_response_t pr = probe_fpga();
  f = pr.f;
  s = pr.s;
  printf("probe done\n");
}
