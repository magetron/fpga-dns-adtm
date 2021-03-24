#pragma once

#include <cstdlib>
#include <cstdint>
#include <cstdio>

extern "C" {
  #include "siphash-ref-impl/siphash.c"
}

FILE* admin_pkt;
uint64_t admin_buf = 0;
uint8_t admin_buf_bits_clean = 64;
uint64_t admin_buf_key[2] = {0xdecaface1eadf1a9UL, 0x1713440219990927UL};
size_t admin_buf_data_ptr = 0;
uint64_t admin_buf_data[15] = {}; // 15 * 64 = 960 bits

uint64_t reverse_bits_64 (uint64_t n) {
  size_t s = sizeof(n) * 8;
  uint64_t mask = ~0;
  while ((s >>= 1) > 0) {
    mask ^= (mask << s);
    n = ((n >> s) & mask) | ((n << s) & ~mask);
  }
  return n;
}

uint64_t reverse_bits_byte_64 (uint64_t n) {
  uint8_t* p = reinterpret_cast<uint8_t*>(&n);
  for (uint8_t i = 0; i < 8; i++, p++) {
    *p = (*p * 0x0202020202ULL & 0x010884422010ULL) % 1023;
  }
  return n;
}

void write_admin_buf_item_and_hash (uint64_t admin_buf, uint8_t bytes_to_write) {
  admin_buf_data[admin_buf_data_ptr++] = admin_buf;
  fwrite(&admin_buf, bytes_to_write, 1, admin_pkt);
}

void write_admin_buf (uint64_t info, uint8_t bits) {
  // write_admin_buf(0, 0) means closing
  info = reverse_bits_64(info) >> (64 - bits);
  if (bits == 0) {
    // dump all admin_buf to admin_pkt, ready to close
    uint8_t bytes_to_write = (((64 - admin_buf_bits_clean) + 7) / 8 + 3) & ~0x03;
    admin_buf = reverse_bits_byte_64(__bswap_64(admin_buf));
    write_admin_buf_item_and_hash(admin_buf, bytes_to_write);
    admin_buf_bits_clean = 64;
    admin_buf = 0;
  } else if (admin_buf_bits_clean >= bits) {
    // normal case
    admin_buf |= (info << (admin_buf_bits_clean - bits)); admin_buf_bits_clean -= bits;
  } else {
    // write partially, write to admin_pkt, write the other part
    uint8_t bits_after_write = bits - admin_buf_bits_clean;
    admin_buf |= (info >> bits_after_write);
    admin_buf = reverse_bits_byte_64(__bswap_64(admin_buf));
    write_admin_buf_item_and_hash(admin_buf, sizeof(admin_buf));
    admin_buf_bits_clean = 64 - bits_after_write;
    admin_buf = (info & ((1 << (bits_after_write + 1)) - 1)) << admin_buf_bits_clean;
  }
}

void append_auth_hash () {
  uint64_t admin_buf_hash_val = 0;
  siphash(admin_buf_data, 120, admin_buf_key, reinterpret_cast<uint8_t*>(&admin_buf_hash_val), 8);
  write_admin_buf(admin_buf_hash_val, 64);
  write_admin_buf(0, 0);
}

void write_to_admin_pkt (filter_t& f, const char* filename) {
  admin_pkt = fopen(filename, "wb");
  if (!admin_pkt) {
    fprintf(stderr, "ERROR invalid filename to write\n");
  }

  admin_buf_data_ptr = 0;
  memset(admin_buf_data, 0, 120); // 960 bits = 120 bytes

  write_admin_buf(f.srcMACBW, 1);
  write_admin_buf(f.srcMACLength, 2);
  for (size_t i = 0; i < FILTER_DEPTH; i++)
    for (size_t j = 0; j < 6; j++) write_admin_buf(f.srcMACList[i].byte[j], 8);

  write_admin_buf(f.dstMACBW, 1);
  write_admin_buf(f.dstMACLength, 2);
  for (size_t i = 0; i < FILTER_DEPTH; i++)
    for (size_t j = 0; j < 6; j++) write_admin_buf(f.dstMACList[i].byte[j], 8);

  write_admin_buf(f.srcIPBW, 1);
  write_admin_buf(f.srcIPLength, 2);
  for (size_t i = 0; i < FILTER_DEPTH; i++)
    for (size_t j = 0; j < 4; j++) write_admin_buf(f.srcIPList[i].num[j], 8);

  write_admin_buf(f.dstIPBW, 1);
  write_admin_buf(f.dstIPLength, 2);
  for (size_t i = 0; i < FILTER_DEPTH; i++)
    for (size_t j = 0; j < 4; j++) write_admin_buf(f.dstIPList[i].num[j], 8);

  write_admin_buf(f.srcPortBW, 1);
  write_admin_buf(f.srcPortLength, 2);
  for (size_t i = 0; i < FILTER_DEPTH; i++)
    write_admin_buf(htons(f.srcPortList[i].port), 16);

  write_admin_buf(f.dstPortBW, 1);
  write_admin_buf(f.dstPortLength, 2);
  for (size_t i = 0; i < FILTER_DEPTH; i++)
    write_admin_buf(htons(f.dstPortList[i].port), 16);

  write_admin_buf(f.dnsBW, 1);
  write_admin_buf(f.dnsLength, 2);
  for (size_t i = 0; i < FILTER_DEPTH; i++)
    write_admin_buf(f.dnsItemEndPtr[i], 8);
  for (size_t i = 0; i < FILTER_DEPTH; i++)
    for (size_t j = 0; j < 16; j++)
      write_admin_buf(f.dnsList[i].c[j], 8);

  write_admin_buf(f.replyType, 1);

  write_admin_buf(0, 26);
  for (size_t i = 0; i < 4; i++) write_admin_buf(0, 64);

  // closing
  write_admin_buf(0, 0);
  append_auth_hash();
  fclose(admin_pkt);
}

filter_t f, f_curr; // f -> fpga configuration, f_cur -> current user configuration

void initialise_fpga_configuration () {
  f.srcMACBW = 1;
  f.srcMACLength = 1;
  f.srcMACList[0].byte[0] = 0x00;
  f.srcMACList[0].byte[1] = 0x0c;
  f.srcMACList[0].byte[2] = 0x29;
  f.srcMACList[0].byte[3] = 0x5f;
  f.srcMACList[0].byte[4] = 0x29;
  f.srcMACList[0].byte[5] = 0xae;
  for (size_t i = 1; i < FILTER_DEPTH; i++) {
    for (size_t j = 0; j < 6; j++) f.srcMACList[i].byte[j] = 0x00;
  }

  f.dstMACBW = 0;
  f.dstMACLength = 1;
  f.dstMACList[0].byte[0] = 0x00;
  f.dstMACList[0].byte[1] = 0x0a;
  f.dstMACList[0].byte[2] = 0x35;
  f.dstMACList[0].byte[3] = 0xff;
  f.dstMACList[0].byte[4] = 0xff;
  f.dstMACList[0].byte[5] = 0xff;
  for (size_t i = 1; i < FILTER_DEPTH; i++) {
    for (size_t j = 0; j < 6; j++) f.dstMACList[i].byte[j] = 0x00;
  }

  f.srcIPBW = 1;
  f.srcIPLength = 2;
  f.srcIPList[0].num[0] = 0;
  f.srcIPList[0].num[1] = 0;
  f.srcIPList[0].num[2] = 0;
  f.srcIPList[0].num[3] = 0;
  f.srcIPList[1].num[0] = 192;
  f.srcIPList[1].num[1] = 168;
  f.srcIPList[1].num[2] = 255;
  f.srcIPList[1].num[3] = 255;

  f.dstIPBW = 0;
  f.dstIPLength = 2;
  f.dstIPList[0].num[0] = 1;
  f.dstIPList[0].num[1] = 2;
  f.dstIPList[0].num[2] = 3;
  f.dstIPList[0].num[3] = 4;
  f.dstIPList[1].num[0] = 255;
  f.dstIPList[1].num[1] = 255;
  f.dstIPList[1].num[2] = 255;
  f.dstIPList[1].num[3] = 255;

  f.srcPortBW = 1;
  f.srcPortLength = 2;
  f.srcPortList[0].port = 53;
  f.srcPortList[1].port = 12345;

  f.dstPortBW = 1;
  f.dstPortLength = 2;
  f.dstPortList[0].port = 53;
  f.dstPortList[1].port = 23456;

  f.dnsBW = 0;
  f.dnsLength = 2;
  f.dnsItemEndPtr[0] = 9 * 8;
  f.dnsList[0].c[0] = 'a';
  f.dnsList[0].c[1] = 'p';
  f.dnsList[0].c[2] = 'p';
  f.dnsList[0].c[3] = 'l';
  f.dnsList[0].c[4] = 'e';
  f.dnsList[0].c[5] = '.';
  f.dnsList[0].c[6] = 'c';
  f.dnsList[0].c[7] = 'o';
  f.dnsList[0].c[8] = 'm';
  for (size_t i = 9; i < 16; i++) {
    f.dnsList[0].c[i] = 0;
  }

  f.dnsItemEndPtr[1] = 10 * 8;
  f.dnsList[1].c[0] = 'g';
  f.dnsList[1].c[1] = 'o';
  f.dnsList[1].c[2] = 'o';
  f.dnsList[1].c[3] = 'g';
  f.dnsList[1].c[4] = 'l';
  f.dnsList[1].c[5] = 'e';
  f.dnsList[1].c[6] = '.';
  f.dnsList[1].c[7] = 'c';
  f.dnsList[1].c[8] = 'o';
  f.dnsList[1].c[9] = 'm';
  for (size_t i = 10; i < 16; i++) {
    f.dnsList[1].c[i] = 0;
  }

  f.replyType = 0;

  f_curr = f;
}

static inline int print_filter_BW (unsigned bw) {
  return bw ? printf("\tWhitelisted") : printf("\tBlacklisted");
}

static inline int print_filter_None_BW (unsigned bw) {
  return bw ? printf("\tBlock ALL"): printf("\tAllow ALL");
}

static inline void print_MAC (mac_addr_t* mac) {
  printf("\t%02X:%02X:%02X:%02X:%02X:%02X",
    mac->byte[0], mac->byte[1],
    mac->byte[2], mac->byte[3],
    mac->byte[4], mac->byte[5]);
}

static inline void print_IP (ip_addr_t* ip) {
  printf("\t%d.%d.%d.%d",
    ip->num[0], ip->num[1], ip->num[2], ip->num[3]);
}

void print_filter_configuration (filter_t f) {
  printf("max filter item per section = %d\n", FILTER_DEPTH);

  printf("src MAC\n");
  if (f.srcMACLength > 0) {
    print_filter_BW(f.srcMACBW); printf("\n");
    for (unsigned i = 0; i < f.srcMACLength; i++) {
      print_MAC(&f.srcMACList[i]); printf("\n");
    }
  } else {
    print_filter_None_BW(f.srcMACBW); printf("\n");
  }

  printf("dst MAC\n");
  if (f.dstMACLength > 0) {
    print_filter_BW(f.dstMACBW); printf("\n");
    for (unsigned i = 0; i < f.dstMACLength; i++) {
      print_MAC(&f.dstMACList[i]); printf("\n");
    }
  } else {
    print_filter_None_BW(f.dstMACBW); printf("\n");
  }

  printf("src IP\n");
  if (f.srcIPLength > 0) {
    print_filter_BW(f.srcIPBW); printf("\n");
    for (unsigned i = 0; i < f.srcIPLength; i++) {
      print_IP(&f.srcIPList[i]); printf("\n");
    }
  } else {
    print_filter_None_BW(f.srcIPBW); printf("\n");
  }

  printf("dst IP\n");
  if (f.dstIPLength > 0) {
    print_filter_BW(f.dstIPBW); printf("\n");
    for (unsigned i = 0; i < f.dstIPLength; i++) {
      print_IP(&f.dstIPList[i]); printf("\n");
    }
  } else {
    print_filter_None_BW(f.dstIPBW); printf("\n");
  }

  printf("src UDP port\n");
  if (f.srcPortLength > 0) {
    print_filter_BW(f.srcPortBW); printf("\n");
    for (unsigned i = 0; i < f.srcPortLength; i++) {
      printf("\t%d", f.srcPortList[i].port);
    }
    printf("\n");
  } else {
    print_filter_None_BW(f.srcPortBW); printf("\n");
  }

  printf("dst UDP port\n");
  if (f.dstPortLength > 0) {
    print_filter_BW(f.dstPortBW); printf("\n");
    for (unsigned i = 0; i < f.dstPortLength; i++) {
      printf("\t%d",f.dstPortList[i].port);
    }
    printf("\n");
  } else {
    print_filter_None_BW(f.dstPortBW); printf("\n");
  }

  printf("DNS string\n");
  if (f.dnsLength > 0) {
    print_filter_BW(f.dnsBW); printf("\n");
    for (unsigned i = 0; i < f.dnsLength; i++) {
      printf("\t");
      printf("bits = %d [", f.dnsItemEndPtr[i]);
      unsigned l = ((unsigned)(f.dnsItemEndPtr[i]) + 7) / 8;
      for (unsigned j = 0; j < l; j++) {
        printf("%c", f.dnsList[i].c[j]);
      }
      printf("]\n");
    }
  } else {
    print_filter_None_BW(f.dnsBW); printf("\n");
  }

  printf("Reply Type\n");
  if (f.replyType == 0) {
    printf("\tMan-in-the-Middle Reply (Same Payload)\n");
  } else {
    printf("\tMan-on-the-Side Reply (DNS Name Error Response)\n");
  }
}
