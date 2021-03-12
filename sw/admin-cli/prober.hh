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

probe_response_t parse_probe_pkt(uint8_t* pkt, size_t length) {
  probe_response_t pr;
  
  auto* eth_hdr = reinterpret_cast<ethhdr*>(pkt);
  auto* ip_hdr = reinterpret_cast<ip*>(eth_hdr + 1);
  auto* udp_hdr = reinterpret_cast<udphdr*>(ip_hdr + 1);
  auto* payload = reinterpret_cast<uint8_t*>(udp_hdr + 1);
  length -= sizeof(eth_hdr) + sizeof(ip) + sizeof(udp_hdr);
  //printf("len = %ld\n", length);
  
  if (length < 128) {
    fprintf(stderr, "ERROR invalid return probe pkt\n");
    return {};
  }
 
  pr.f.srcMACBW       = extract_bits_from_arr(payload, 0, 0);
  pr.f.srcMACLength   = extract_bits_from_arr(payload, 1, 2);
  pr.f.dstMACBW       = extract_bits_from_arr(payload, 99, 99);
  pr.f.dstMACLength   = extract_bits_from_arr(payload, 100, 101);
  for (size_t i = 0; i < 2; i++) {
    for (size_t j = 0; j < 6; j++) {
      pr.f.srcMACList[i].byte[j] = extract_bits_from_arr(payload, 3 + i * 48 + j * 8, 10 + i * 48 + j * 8);
      pr.f.dstMACList[i].byte[j] = extract_bits_from_arr(payload, 102 + i * 48 + j * 8, 109 + i * 48 + j * 8);
    }
  }
  pr.f.srcIPBW        = extract_bits_from_arr(payload, 198, 198);
  pr.f.srcIPLength    = extract_bits_from_arr(payload, 199, 200);
  pr.f.dstIPBW        = extract_bits_from_arr(payload, 265, 265);
  pr.f.dstIPLength    = extract_bits_from_arr(payload, 266, 267);
  for (size_t i = 0; i < 2; i++) {
    for (size_t j = 0; j < 4; j++) {
      pr.f.srcIPList[i].num[j] = extract_bits_from_arr(payload, 201 + i * 32 + j * 8, 208 + i * 32 + j * 8);
      pr.f.dstIPList[i].num[j] = extract_bits_from_arr(payload, 268 + i * 32 + j * 8, 275 + i * 32 + j * 8);
    }
  }
  pr.f.srcIPBW        = extract_bits_from_arr(payload, 198, 198);
  pr.f.srcIPLength    = extract_bits_from_arr(payload, 199, 200);
  pr.f.dstIPBW        = extract_bits_from_arr(payload, 265, 265);
  pr.f.dstIPLength    = extract_bits_from_arr(payload, 266, 267);
  for (size_t i = 0; i < 2; i++) {
    for (size_t j = 0; j < 4; j++) {
      pr.f.srcIPList[i].num[j] = extract_bits_from_arr(payload, 201 + i * 32 + j * 8, 208 + i * 32 + j * 8);
      pr.f.dstIPList[i].num[j] = extract_bits_from_arr(payload, 268 + i * 32 + j * 8, 275 + i * 32 + j * 8);
    }
  }
  pr.f.srcPortBW      = extract_bits_from_arr(payload, 332, 332);
  pr.f.srcPortLength  = extract_bits_from_arr(payload, 333, 334);
  pr.f.dstPortBW      = extract_bits_from_arr(payload, 367, 367);
  pr.f.dstPortLength  = extract_bits_from_arr(payload, 368, 369);
  for (size_t i = 0; i < 2; i++) {
    pr.f.srcPortList[i].port = (uint16_t)extract_bits_from_arr(payload, 335 + i * 16, 350 + i * 16);
    pr.f.dstPortList[i].port = (uint16_t)extract_bits_from_arr(payload, 370 + i * 16, 385 + i * 16);
  }

  pr.f.dnsBW          = extract_bits_from_arr(payload, 402, 402);
  pr.f.dnsLength      = extract_bits_from_arr(payload, 403, 404);
  for (size_t i = 0; i < 2; i++) {
    pr.f.dnsItemEndPtr[i] = extract_bits_from_arr(payload, 405 + i * 8, 412 + i * 8);
    for (size_t j = 0; j < 16; j++) {
      pr.f.dnsList[i].c[j] = extract_bits_from_arr(payload, 421 + i * 128 + j * 8, 428 + i * 128 + j * 8);
    }
  }

  pr.s.stc = extract_bits_from_arr(payload, 677, 740);
  pr.s.sfc = extract_bits_from_arr(payload, 741, 804);
  pr.s.smc = extract_bits_from_arr(payload, 805, 868);
  pr.s.sic = extract_bits_from_arr(payload, 869, 932);
  pr.s.spc = extract_bits_from_arr(payload, 933, 996);

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
