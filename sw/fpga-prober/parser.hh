#pragma once
#include <unistd.h>
#include <cstdlib>
#include <cstring>
#include <cstdint>
#include <cstdio>

#include "fpga-prober.hh"

static inline uint8_t parse_hex(char c) {
  // assume c being 0..9,a..f
  return (c >= '0' && c <= '9') ? c - 48 : c - 87;
}

static inline void parse_mac(char* str) {
  size_t len = strnlen(str, INT16_MAX);
  uint8_t cur_byte = 0;
  size_t j = 0, k = 0;
  for (size_t i = 0; i <= len; i++) {
    if (str[i] != ':' && str[i] != ',' && str[i] != '\0') {
      cur_byte = (cur_byte << 4) + parse_hex(str[i]);
    } else if (str[i] == ':') {
      MAC_ADDRS[j].byte[k] = cur_byte;
      cur_byte = 0;
      k++;
    } else {
      MAC_ADDRS[j].byte[k] = cur_byte;
      cur_byte = 0;
      k = 0;
      j++;
    }
  }
}

static inline void parse_ip(char* str) {
  size_t len = strnlen(str, INT16_MAX);
  uint8_t cur_number = 0;
  size_t j = 0, k = 0;
  for (size_t i = 0; i <= len; i++) {
    if (str[i] != ',' && str[i] != '.' && str[i] != '\0') {
      cur_number = cur_number * 10 + (str[i] - 48);
    } else if (str[i] == '.') {
      IP_ADDRS[j].num[k] = cur_number;
      cur_number = 0;
      k++;
    } else {
      IP_ADDRS[j].num[k] = cur_number;
      cur_number = 0;
      k = 0;
      j++;
    }
  }
}

static inline void parse_udp(char* str) {
  size_t len = strnlen(str, INT16_MAX);
  uint16_t cur_number = 0;
  size_t j = 0;
  for (size_t i = 0; i <= len; i++) {
    if (str[i] != ',' && str[i] != '\0') {
      cur_number = cur_number * 10 + (str[i] - 48);
    } else {
      UDP_PORTS[j].port = cur_number;
      cur_number = 0;
      j++;
    }
  }
}

static inline void read_file(char* filename) {
  FILE* fileptr = fopen(filename, "rb");
  fseek(fileptr, 0, SEEK_END);
  PAYLOAD_LENGTH = ftell(fileptr);
  if (PAYLOAD_LENGTH > BUFFER_SIZE) { PAYLOAD_LENGTH = BUFFER_SIZE; }
  rewind(fileptr);
  fread(PAYLOAD, PAYLOAD_LENGTH, 1, fileptr);
  fclose(fileptr);
}

static inline void parse_args (int argc, char** argv) {
  int c;
  opterr = 0;
  while ((c = getopt(argc, argv, "r:t:s:m:i:u:")) != -1) {
    switch (c) {
      case 'r':
      // read file
        PACKET_MODE = packet_mode_t::FILE_TEST;
        read_file(optarg);
        break;
      case 't':
      // time interval
        SEND_TIME = atoi(optarg) * MS_IN_USEC;
        break;
      case 's':
      // send mode
        if (!strncmp(optarg, "daemon", 7)) {
          SEND_MODE = send_mode_t::DAEMON;
        } else if (!strncmp(optarg, "once", 5)) {
          SEND_MODE = send_mode_t::ONCE;
        }
        break;
      case 'm':
      // mac address
        parse_mac(optarg);
        break;
      case 'i':
      // ip address
        parse_ip(optarg);
        break;
      case 'u':
      // udp port number
        parse_udp(optarg);
        break;
      case 'h':
      default:
        printf("Unrecognised argument\n");
        printf("Usage:\n"
               "./fpga-prober -r dnspacket.bin -t 500 -s daemon "
               "-m 0a:0b:0c:0d:0e:0f,1a:1b:1c:1d:1e:1f -i 10.0.1.14,192.168.5.1 "
               "-u 12345,23456\n");
        exit(0);
    }
  }
}
