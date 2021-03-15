#pragma once

#include "tests/test-srcmac.hh"
#include "tests/test-dstmac.hh"
#include "tests/test-srcip.hh"
#include "tests/test-dstip.hh"
#include "tests/test-srcport.hh"
#include "tests/test-dstport.hh"
#include "tests/test-dns.hh"

int com_test (char* arg) {
  filter_t f;
  int result[7] = {};
  f = {}; result[0] = test_srcmac_filters(f);
  f = {}; result[1] = test_dstmac_filters(f);
  f = {}; result[2] = test_srcip_filters(f);
  f = {}; result[3] = test_dstip_filters(f);
  f = {}; result[4] = test_srcport_filters(f);
  f = {}; result[5] = test_dstport_filters(f);
  f = {}; result[6] = test_dns_filters(f);

  int final_result = 0;
  for (uint8_t i = 0; i < 7; i++) {
    if (result[i] == -1) {
      printf("test suite %d failed\n", i);
    }
    final_result |= result[i];
  }
  if (final_result == 0) printf("FPGA validation completed. SUCCESSFUL!\n");
  return 0;
}
