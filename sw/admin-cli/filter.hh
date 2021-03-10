#pragma once

#include <cstdlib>
#include <cstdint>
#include <cstdio>

FILE* admin_pkt;
uint64_t admin_buf = 0;
uint8_t admin_buf_bits_clean = 64;
uint32_t admin_buf_key = 0xdecaface;
uint32_t admin_buf_hash_val;

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
  admin_buf_hash_val ^= (admin_buf & 0xffffffff);
  admin_buf_hash_val ^= (admin_buf & 0xffffffff00000000) >> 32;
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
  uint32_t save_admin_buf_hash_val = admin_buf_hash_val;
  write_admin_buf(save_admin_buf_hash_val, 32);
  write_admin_buf(0, 0);
}

void write_to_admin_pkt (filter_t& f) {
  printf("writing admin pkt to %s...\n", ADMIN_PKT_TMP_FILENAME);

  admin_pkt = fopen(ADMIN_PKT_TMP_FILENAME, "wb");
  admin_buf_hash_val = admin_buf_key;

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
    write_admin_buf(f.srcPortList[i].port, 16);

  write_admin_buf(f.dstPortBW, 1);
  write_admin_buf(f.dstPortLength, 2);
  for (size_t i = 0; i < FILTER_DEPTH; i++)
    write_admin_buf(f.dstPortList[i].port, 16);

  write_admin_buf(f.dnsBW, 1);
  write_admin_buf(f.dnsLength, 2);
  for (size_t i = 0; i < FILTER_DEPTH; i++)
    write_admin_buf(f.dnsItemEndPtr[i], 8);
  for (size_t i = 0; i < FILTER_DEPTH; i++)
    for (size_t j = 0; j < 16; j++)
      write_admin_buf(f.dnsList[i].c[j], 8);

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
  f.srcPortList[0].port = __bswap_16(53);
  f.srcPortList[1].port = __bswap_16(12345);

  f.dstPortBW = 1;
  f.dstPortLength = 2;
  f.dstPortList[0].port = __bswap_16(53);
  f.dstPortList[1].port = __bswap_16(23456);

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

  f_curr = f;
}
