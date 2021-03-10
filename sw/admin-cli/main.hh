#pragma once

filter_t f, f_curr; // f -> fpga configuration, f_cur -> current user configuration

int done = 0;

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
