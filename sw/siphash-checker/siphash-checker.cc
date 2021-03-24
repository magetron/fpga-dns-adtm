#define DEBUG

#include <cstdint>
#include <cstdlib>

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

extern "C" {
#include "siphash-ref-impl/siphash.c"
}

int main (int argc, char** argv) {
  uint64_t* in_key = new uint64_t[2];    // 128 bits
  uint8_t* in_data = new uint8_t[120];  // 960 bits


/*in_key[0]   = 0xde;
  in_key[1]   = 0xca;
  in_key[2]   = 0xfa;
  in_key[3]   = 0xce;
  in_key[4]   = 0x1e;
  in_key[5]   = 0xad;
  in_key[6]   = 0xf1;
  in_key[7]   = 0xa9;
  in_key[8]   = 0x17;
  in_key[9]   = 0x13;
  in_key[10]  = 0x44;
  in_key[11]  = 0x02;
  in_key[12]  = 0x19;
  in_key[13]  = 0x99;
  in_key[14]  = 0x09;
  in_key[15]  = 0x27; */

  in_key[0] = (0xdecaface1eadf1a9UL);
  in_key[1] = (0x1713440219990927UL);


  memset(in_data, 0, 120);


  uint8_t *out_data = new uint8_t[8]; // 64bits;
  siphash(in_data, 120, in_key, out_data, 8);

  printf("%016" PRIx64 "\n", *reinterpret_cast<uint64_t*>(out_data));

  return 0;
}

