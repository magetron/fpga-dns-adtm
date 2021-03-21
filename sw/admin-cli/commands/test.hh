#pragma once

void print_not_recv_msg() {
  printf("FPGA validation failed, expect packet not received.\n");
}

void print_not_block_msg() {
  printf("FPGA validation failed, block not successful.\n");
}

#include "tests/test-srcmac.hh"
#include "tests/test-dstmac.hh"
#include "tests/test-srcip.hh"
#include "tests/test-dstip.hh"
#include "tests/test-srcport.hh"
#include "tests/test-dstport.hh"
#include "tests/test-dns.hh"

int com_test_all(char*);
int com_test_first_fail(char*);
int com_test_mac(char*);
int com_test_ip(char*);
int com_test_udp(char*);
int com_test_dns(char*);
int com_test_help(char*);

COMMAND test_commands[] = {
  { "all", com_test_all, "run all test cases regardless of failling, report all" },
  { "f-fail", com_test_first_fail, "run all tests and stop at first fail" },
  { "mac", com_test_mac, "run Ethernet MAC related tests" },
  { "ip", com_test_ip, "run IPv4 related tests"},
  { "udp", com_test_udp, "run UDP related tests"},
  { "dns", com_test_dns, "run DNS related tests"},
  { "help", com_test_help, "display this text" },
  { "?", com_test_help, "synonym for `help'" },
  { (char *)nullptr, (rl_icpfunc_t *)nullptr, (char *)nullptr }
};

int com_test (char* arg) {
  if (!*arg) {
    com_test_help(arg);
  } else {
    execute(arg, test_commands);
  }
  return 0;
}

int com_test_help (char* arg) {
  print_help(arg, test_commands);
  return 0;
}

static inline const char* index_to_test_type(int i) {
  switch (i) {
    case 0:
    return "srcmac";
    case 1:
    return "dstmac";
    case 2:
    return "srcip";
    case 3:
    return "dstip";
    case 4:
    return "srcport";
    case 5:
    return "dstport";
    case 6:
    return "dns";
    default:
    return "UNKNOWN";
  }
}

static inline void print_fail_test_suite(int i) {
  printf("test suite [%s] failed\n", index_to_test_type(i));
}

int com_test_all (char* arg) {
  filter_t f = {};
  int result[7] = {};
  result[0] = test_srcmac_filters(f);
  result[1] = test_dstmac_filters(f);
  result[2] = test_srcip_filters(f);
  result[3] = test_dstip_filters(f);
  result[4] = test_srcport_filters(f);
  result[5] = test_dstport_filters(f);
  result[6] = test_dns_filters(f);

  int final_result = 0;
  for (uint8_t i = 0; i < 7; i++) {
    if (result[i] == -1) {
      print_fail_test_suite(i);
    }
    final_result |= result[i];
  }
  if (final_result == 0) printf("FPGA validation completed. SUCCESSFUL!\n");
  else printf("FPGA validation failed. UNSUCCESSFUL!\n");
  return 0;
}

int com_test_first_fail(char* arg) {
  filter_t f = {};
  int result = 0;
  result = test_srcmac_filters(f); if (result == -1)    { print_fail_test_suite(0); return -1; }
  result = test_dstmac_filters(f); if (result == -1)    { print_fail_test_suite(1); return -1; }
  result = test_srcip_filters(f); if (result == -1)     { print_fail_test_suite(2); return -1; }
  result = test_dstip_filters(f); if (result == -1)     { print_fail_test_suite(3); return -1; }
  result = test_srcport_filters(f); if (result == -1)   { print_fail_test_suite(4); return -1; }
  result = test_dstport_filters(f); if (result == -1)   { print_fail_test_suite(5); return -1; }
  result = test_dns_filters(f); if (result == -1)       { print_fail_test_suite(6); return -1; }
  printf("FPGA validation completed. SUCCESSFUL!\n");
  return 0;
}

int com_test_mac(char* arg) {
  filter_t f = {};
  int result[7] = {};
  result[0] = test_srcmac_filters(f);
  result[1] = test_dstmac_filters(f);
  int final_result = 0;
  for (uint8_t i = 0; i < 7; i++) {
    if (result[i] == -1) {
      print_fail_test_suite(i);
    }
    final_result |= result[i];
  }
  if (final_result == 0) printf("FPGA partial validation completed. SUCCESSFUL!\n");
  else printf("FPGA partial validation failed. UNSUCCESSFUL!\n");
  return 0;
}

int com_test_ip(char* arg) {
  filter_t f = {};
  int result[7] = {};
  result[2] = test_srcip_filters(f);
  result[3] = test_dstip_filters(f);
  int final_result = 0;
  for (uint8_t i = 0; i < 7; i++) {
    if (result[i] == -1) {
      print_fail_test_suite(i);
    }
    final_result |= result[i];
  }
  if (final_result == 0) printf("FPGA partial validation completed. SUCCESSFUL!\n");
  else printf("FPGA partial validation failed. UNSUCCESSFUL!\n");
  return 0;
}

int com_test_udp(char* arg) {
  filter_t f = {};
  int result[7] = {};
  result[4] = test_srcport_filters(f);
  result[5] = test_dstport_filters(f);
  int final_result = 0;
  for (uint8_t i = 0; i < 7; i++) {
    if (result[i] == -1) {
      print_fail_test_suite(i);
    }
    final_result |= result[i];
  }
  if (final_result == 0) printf("FPGA partial validation completed. SUCCESSFUL!\n");
  else printf("FPGA partial validation failed. UNSUCCESSFUL!\n");
  return 0;
}

int com_test_dns(char* arg) {
  filter_t f = {};
  int result[7] = {};
  result[6] = test_dns_filters(f);
  int final_result = 0;
  for (uint8_t i = 0; i < 7; i++) {
    if (result[i] == -1) {
      print_fail_test_suite(i);
    }
    final_result |= result[i];
  }
  if (final_result == 0) printf("FPGA partial validation completed. SUCCESSFUL!\n");
  else printf("FPGA partial validation failed. UNSUCCESSFUL!\n");
  return 0;
}
