#pragma once
#include <cstdlib>
#include <cstdint>
#include <arpa/inet.h>

#define max(a,b) \
  ({ __typeof__ (a) _a = (a); \
      __typeof__ (b) _b = (b); \
    _a > _b ? _a : _b; })

enum class e_ethertype : uint16_t {
  IPv4 = 0x0800
};

enum class e_ip_proto : uint8_t {
  TCP = 0x06,
  UDP = 0x11
};

struct [[gnu::packed]] mac_addr_t {
  uint8_t byte[6];
};

struct [[gnu::packed]] ip_addr_t {
  uint8_t num[4];
};

struct [[gnu::packed]] udp_port_t {
  uint16_t port;
};

struct [[gnu::packed]] dns_filter_item_t {
  unsigned char c[16];
};

struct filter_t {
  unsigned srcMACBW : 1;
  unsigned srcMACLength : 2; // 0,1,2 FILTER_DEPTH related
  mac_addr_t srcMACList[FILTER_DEPTH];
  unsigned dstMACBW : 1;
  unsigned dstMACLength : 2; // 0,1,2 FILTER_DEPTH related
  mac_addr_t dstMACList[FILTER_DEPTH];
  unsigned srcIPBW : 1;
  unsigned srcIPLength : 2; // 0,1,2 FILTER_DEPTH related
  ip_addr_t srcIPList[FILTER_DEPTH];
  unsigned dstIPBW : 1;
  unsigned dstIPLength : 2; // 0,1,2 FILTER_DEPTH related
  ip_addr_t dstIPList[FILTER_DEPTH];
  unsigned srcPortBW : 1;
  unsigned srcPortLength : 2;
  udp_port_t srcPortList[FILTER_DEPTH];
  unsigned dstPortBW : 1;
  unsigned dstPortLength : 2;
  udp_port_t dstPortList[FILTER_DEPTH];
  unsigned dnsBW : 1;
  unsigned dnsLength : 2;
  uint8_t dnsItemEndPtr[FILTER_DEPTH];
  dns_filter_item_t dnsList[FILTER_DEPTH];
};

static inline uint16_t IPchecksum (uint16_t *buff, int32_t _16bitword) {
  uint32_t sum;
  for (sum = 0; _16bitword > 0; _16bitword--) {
    sum += htons(*(buff)++);
  }
  sum = ((sum >> 16) + (sum & 0xFFFF));
  sum += (sum >> 16);
  return (uint16_t)(~sum);
}
