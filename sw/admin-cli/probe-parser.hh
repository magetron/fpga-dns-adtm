#pragma once

struct [[gnu::packed]] probe_response_t {
  filter_t filter;
  uint64_t stc, sfc, smc, sic, spc;
};

uint64_t extract_bits_from_arr (uint8_t* pkt, size_t s, size_t e) {
  e++;
  uint64_t buf = 0;
  size_t sb = s / 8;
  size_t so = s % 8;
  size_t eb = (e - 1) / 8;
  size_t eo = e % 8;
  if (sb == eb) {
    buf = (pkt[sb] & (0xff - ((1 << so) - 1) - (((1 << (8 - eo)) - 1) << eo))) >> so;
  } else {
    for (size_t i = sb; i <= eb; i++) {
      if (i == sb) {
        buf = (pkt[sb] & (0xff - ((1 << so) - 1))) >> so;
      } else if (i == eb) {
        buf |= (pkt[eb] & (0xff - ((1 << (8 - eo)) - 1))) << ((i - sb) * 8 - so);
      } else {
        buf |= pkt[i] << ((i - sb) * 8 - so);
      }
      printf("%08lx\n", buf);
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

  printf("%01lx %01lx\n", extract_bits_from_arr(payload, 0, 0), extract_bits_from_arr(payload, 1, 2));
  printf("%06lx %06lx\n", extract_bits_from_arr(payload, 3, 50), extract_bits_from_arr(payload, 51, 98));

  //for (size_t i = 0; i < length; i++) printf("%02x ", payload[i]);
  //printf("\n");

  pr = {};
  return pr;
}
