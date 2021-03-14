#pragma once

#include "tests/test-srcmac.hh"
#include "tests/test-dstmac.hh"
#include "tests/test-srcip.hh"
#include "tests/test-dstip.hh"
#include "tests/test-srcport.hh"
#include "tests/test-dstport.hh"

int test_mac_filters(filter_t& f) {
  f = {}; if (test_srcmac_filters(f) == -1) { return -1; }
  //f = {}; if (test_dstmac_filters(f) == -1) { return -1; }
  return 0;
}

int test_ip_filters(filter_t& f) {
  f = {}; if (test_srcip_filters(f) == -1) { return -1; }
  f = {}; if (test_dstip_filters(f) == -1) { return -1; }
  return 0;
}

int test_udp_filters(filter_t& f) {
  //f = {}; if (test_srcport_filters(f) == -1) { return -1; }
  //f = {}; if (test_dstport_filters(f) == -1) { return -1; }
  return 0;
}

int test_dns_filters(filter_t& f) {
  
  return 0;
}

int com_test (char* arg) {
  filter_t f = {};
  if (test_mac_filters(f) == -1) { return -1; }
  if (test_ip_filters(f) == -1) { return -1; }
  if (test_udp_filters(f) == -1) { return -1; }
  if (test_dns_filters(f) == -1) { return -1; }

  printf("FPGA validation completed. SUCCESSFUL!\n");
  return 0;
}
