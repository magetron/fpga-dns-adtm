

#include "fpga-prober.hh"
#include "parser.hh"

FILE* file;
uint64_t buf = 0;
uint8_t bits_clean = 64;

void write_buf (uint64_t info, uint8_t bits) {
  if (bits == 0) {
    // dump all buf to file, ready to close
    uint8_t bytes_to_write = ((64 - bits_clean) + 7) / 8;
    buf = __bswap_64(buf);
    fwrite(&buf, bytes_to_write, 1, file);
  } else if (bits_clean >= bits) {
    // normal case
    buf |= (info << (bits_clean - bits)); bits_clean -= bits;
  } else {
    // write partially, write to file, write the other part
    uint8_t bits_after_write = bits - bits_clean;
    buf |= (info >> bits_after_write);
    buf = __bswap_64(buf);
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
  write_buf(0, 0);
  fclose(file);
}

int main (int argc, char** argv) {
  parse_args_builder(argc, argv);
  filter_t f;
  f.srcMACBW = 1;
  f.srcMACLength = 1;

  f.srcMACList[0].byte[0] = 0xae;
  f.srcMACList[0].byte[1] = 0x29;
  f.srcMACList[0].byte[2] = 0x5f;
  f.srcMACList[0].byte[3] = 0x29;
  f.srcMACList[0].byte[4] = 0x0c;
  f.srcMACList[0].byte[5] = 0x00;
  for (size_t i = 1; i < FILTER_DEPTH; i++) {
    for (size_t j = 0; j < 6; j++) f.srcMACList[i].byte[j] = 0x00;
  }

  f.dstMACBW = 0;
  f.dstMACLength = 1;

  f.dstMACList[0].byte[0] = 0xff;
  f.dstMACList[0].byte[1] = 0xff;
  f.dstMACList[0].byte[2] = 0xff;
  f.dstMACList[0].byte[3] = 0x35;
  f.dstMACList[0].byte[4] = 0x0a;
  f.dstMACList[0].byte[5] = 0x00;
  for (size_t i = 1; i < FILTER_DEPTH; i++) {
    for (size_t j = 0; j < 6; j++) f.dstMACList[i].byte[j] = 0x00;
  }

  write_to_file(f);

  return 0;
}
