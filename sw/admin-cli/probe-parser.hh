#pragma once

struct [[gnu::packed]] probe_response_t {
  filter_t filter;
  uint64_t stc, sfc, smc, sic, spc;
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

  printf("%01lx %01lx\n", extract_bits_from_arr(payload, 0, 0), extract_bits_from_arr(payload, 1, 2));
  printf("%012lx %012lx\n", extract_bits_from_arr(payload, 3, 50), extract_bits_from_arr(payload, 51, 98));
  printf("%01lx %01lx\n", extract_bits_from_arr(payload, 99, 99), extract_bits_from_arr(payload, 100, 101));
  printf("%012lx %012lx\n", extract_bits_from_arr(payload, 102, 149), extract_bits_from_arr(payload, 150, 197));
  
  printf("%01lx %01lx\n", extract_bits_from_arr(payload, 198, 198), extract_bits_from_arr(payload, 199, 200));
  printf("%08ld %08ld\n", extract_bits_from_arr(payload, 201, 232), extract_bits_from_arr(payload, 233, 264));
  printf("%01lx %01lx\n", extract_bits_from_arr(payload, 265, 265), extract_bits_from_arr(payload, 266, 267));
  printf("%08ld %08ld\n", extract_bits_from_arr(payload, 268, 299), extract_bits_from_arr(payload, 300, 331));
  
  printf("%01lx %01lx\n", extract_bits_from_arr(payload, 332, 332), extract_bits_from_arr(payload, 333, 334));
  printf("%05d %05d\n", __bswap_16((uint16_t)extract_bits_from_arr(payload, 335, 350)), __bswap_16((uint16_t)extract_bits_from_arr(payload, 351, 366)));
  printf("%01lx %01lx\n", extract_bits_from_arr(payload, 367, 367), extract_bits_from_arr(payload, 368, 369));
  printf("%05d %05d\n", __bswap_16((uint16_t)extract_bits_from_arr(payload, 370, 385)), __bswap_16((uint16_t)extract_bits_from_arr(payload, 386, 401)));

  printf("%01lx %01lx\n", extract_bits_from_arr(payload, 402, 402), extract_bits_from_arr(payload, 403, 404));
  printf("%ld %ld\n", extract_bits_from_arr(payload, 405, 412), extract_bits_from_arr(payload, 413, 420));
  for (size_t i = 421; i <= 541; i += 8) {
    uint8_t c = (uint8_t)extract_bits_from_arr(payload, i, i + 7);
    printf("%c", c);
  }
  printf("\n");
  for (size_t i = 549; i <= 669; i += 8) {
    uint8_t c = (uint8_t)extract_bits_from_arr(payload, i, i + 7);
    printf("%c", c);
  }
  printf("\n");

  printf("%ld %ld\n", extract_bits_from_arr(payload, 677, 740), extract_bits_from_arr(payload, 741, 804));
  printf("%ld %ld %ld\n", extract_bits_from_arr(payload, 805, 868), extract_bits_from_arr(payload, 869, 932), extract_bits_from_arr(payload, 933, 996));

  //for (size_t i = 0; i < length; i++) printf("%02x ", payload[i]);
  //printf("\n");
 
  pr = {};
  return pr;
}
