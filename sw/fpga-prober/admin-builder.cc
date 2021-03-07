#include "fpga-prober.hh"
#include "parser.hh"

FILE* file;
uint64_t buf = 0;
uint8_t bits_clean = 64;

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

void write_buf (uint64_t info, uint8_t bits) {
  // write_buf(0, 0) means closing
  info = reverse_bits_64(info) >> (64 - bits);
  if (bits == 0) {
    // dump all buf to file, ready to close
    uint8_t bytes_to_write = ((64 - bits_clean) + 7) / 8;
    buf = reverse_bits_byte_64(__bswap_64(buf));
    fwrite(&buf, bytes_to_write, 1, file);
  } else if (bits_clean >= bits) {
    // normal case
    buf |= (info << (bits_clean - bits)); bits_clean -= bits;
  } else {
    // write partially, write to file, write the other part
    uint8_t bits_after_write = bits - bits_clean;
    buf |= (info >> bits_after_write);
    buf = reverse_bits_byte_64(__bswap_64(buf));
    fwrite(&buf, sizeof(buf), 1, file);
    bits_clean = 64 - bits_after_write;
    buf = (info & ((1 << (bits_after_write + 1)) - 1)) << bits_clean;
  }
}

void write_to_file (filter_t& f) {
  file = fopen(WRITE_FILENAME, "wb");
  write_buf(f.srcMACBW, 1);
  write_buf(f.srcMACLength, 2);
  for (size_t i = 0; i < FILTER_DEPTH; i++)
    for (size_t j = 0; j < 6; j++) write_buf(f.srcMACList[i].byte[j], 8);

  write_buf(f.dstMACBW, 1);
  write_buf(f.dstMACLength, 2);
  for (size_t i = 0; i < FILTER_DEPTH; i++)
    for (size_t j = 0; j < 6; j++) write_buf(f.dstMACList[i].byte[j], 8);

  write_buf(f.srcIPBW, 1);
  write_buf(f.srcIPLength, 2);
  for (size_t i = 0; i < FILTER_DEPTH; i++)
    for (size_t j = 0; j < 4; j++) write_buf(f.srcIPList[i].num[j], 8);

  write_buf(f.dstIPBW, 1);
  write_buf(f.dstIPLength, 2);
  for (size_t i = 0; i < FILTER_DEPTH; i++)
    for (size_t j = 0; j < 4; j++) write_buf(f.dstIPList[i].num[j], 8);

  write_buf(f.srcPortBW, 1);
  write_buf(f.srcPortLength, 2);
  for (size_t i = 0; i < FILTER_DEPTH; i++)
    write_buf(f.srcPortList[i].port, 16);

  write_buf(f.dstPortBW, 1);
  write_buf(f.dstPortLength, 2);
  for (size_t i = 0; i < FILTER_DEPTH; i++)
    write_buf(f.dstPortList[i].port, 16);

  write_buf(f.dnsBW, 1);
  write_buf(f.dnsLength, 2);
  for (size_t i = 0; i < FILTER_DEPTH; i++)
    write_buf(f.dnsItemEndPtr[i], 8);
  for (size_t i = 0; i < FILTER_DEPTH; i++)
    for (size_t j = 0; j < 16; j++)
      write_buf(f.dnsList[i].c[j], 8);

  // closing
  write_buf(0, 0);
  fclose(file);
}

int main (int argc, char** argv) {
  parse_args_builder(argc, argv);
  filter_t f;

  f.srcMACBW = 1;
  f.srcMACLength = 1;
  f.srcMACList[0].byte[0] = 0x00;
  f.srcMACList[0].byte[1] = 0x0c;
  f.srcMACList[0].byte[2] = 0x29;
  f.srcMACList[0].byte[3] = 0x5f;
  f.srcMACList[0].byte[4] = 0x29;
  f.srcMACList[0].byte[5] = 0xaf;
  for (size_t i = 1; i < FILTER_DEPTH; i++) {
    for (size_t j = 0; j < 6; j++) f.srcMACList[i].byte[j] = 0x00;
  }

  f.dstMACBW = 0;
  f.dstMACLength = 1;
  f.dstMACList[0].byte[0] = 0x00;
  f.dstMACList[0].byte[1] = 0x0a;
  f.dstMACList[0].byte[2] = 0x35;
  f.dstMACList[0].byte[3] = 0x11;
  f.dstMACList[0].byte[4] = 0x11;
  f.dstMACList[0].byte[5] = 0x11;
  for (size_t i = 1; i < FILTER_DEPTH; i++) {
    for (size_t j = 0; j < 6; j++) f.dstMACList[i].byte[j] = 0x00;
  }

  f.srcIPBW = 1;
  f.srcIPLength = 2;
  f.srcIPList[0].num[0] = 0;
  f.srcIPList[0].num[1] = 1;
  f.srcIPList[0].num[2] = 2;
  f.srcIPList[0].num[3] = 3;
  f.srcIPList[1].num[0] = 192;
  f.srcIPList[1].num[1] = 168;
  f.srcIPList[1].num[2] = 127;
  f.srcIPList[1].num[3] = 127;

  f.dstIPBW = 0;
  f.dstIPLength = 2;
  f.dstIPList[0].num[0] = 2;
  f.dstIPList[0].num[1] = 3;
  f.dstIPList[0].num[2] = 4;
  f.dstIPList[0].num[3] = 5;
  f.dstIPList[1].num[0] = 250;
  f.dstIPList[1].num[1] = 250;
  f.dstIPList[1].num[2] = 250;
  f.dstIPList[1].num[3] = 250;

  f.srcPortBW = 0;
  f.srcPortLength = 2;
  f.srcPortList[0].port = __bswap_16(12345);
  f.srcPortList[1].port = __bswap_16(55553);

  f.dstPortBW = 0;
  f.dstPortLength = 0;
  f.dstPortList[0].port = __bswap_16(0);
  f.dstPortList[1].port = __bswap_16(0);

  f.dnsBW = 1;
  f.dnsLength = 2;
  f.dnsItemEndPtr[0] = 10 * 8;
  f.dnsList[0].c[0] = 'g';
  f.dnsList[0].c[1] = 'o';
  f.dnsList[0].c[2] = 'o';
  f.dnsList[0].c[3] = 'g';
  f.dnsList[0].c[4] = 'l';
  f.dnsList[0].c[5] = 'e';
  f.dnsList[0].c[6] = '.';
  f.dnsList[0].c[7] = 'c';
  f.dnsList[0].c[8] = 'o';
  f.dnsList[0].c[9] = 'm';
  for (size_t i = 10; i < 16; i++) {
    f.dnsList[0].c[i] = 0;
  }

  f.dnsItemEndPtr[1] = 13 * 8;
  f.dnsList[1].c[0] = 'm';
  f.dnsList[1].c[1] = 'i';
  f.dnsList[1].c[2] = 'c';
  f.dnsList[1].c[3] = 'r';
  f.dnsList[1].c[4] = 'o';
  f.dnsList[1].c[5] = 's';
  f.dnsList[1].c[6] = 'o';
  f.dnsList[1].c[7] = 'f';
  f.dnsList[1].c[8] = 't';
  f.dnsList[1].c[9] = '.';
  f.dnsList[1].c[10] = 'c';
  f.dnsList[1].c[11] = 'o';
  f.dnsList[1].c[12] = 'm';
  for (size_t i = 13; i < 16; i++) {
    f.dnsList[1].c[i] = 0;
  }

  write_to_file(f);

  return 0;
}
