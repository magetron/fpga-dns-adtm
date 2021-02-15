#pragma once

static const size_t BUFFER_SIZE = 65536;
static const uint64_t SEC_IN_USEC = 1e6;
static const uint64_t MS_IN_USEC = 1e3;

enum class e_ethertype : uint16_t {
  IPv4 = 0x0800
};

enum class e_ip_proto : uint8_t {
  TCP = 0x06,
  UDP = 0x11
};

enum class packet_mode_t {
  UDP_TEST,
  FILE_TEST
};

enum class send_mode_t {
  CHANGING,
  DAEMON,
  ONCE
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

static inline uint16_t IPchecksum(uint16_t *buff, int32_t _16bitword) {
  uint32_t sum;
  for (sum = 0; _16bitword > 0; _16bitword--) {
    sum += htons(*(buff)++);
  }
  sum = ((sum >> 16) + (sum & 0xFFFF));
  sum += (sum >> 16);
  return (uint16_t)(~sum);
}

packet_mode_t PACKET_MODE = packet_mode_t::UDP_TEST;
send_mode_t SEND_MODE = send_mode_t::ONCE;
uint64_t SEND_TIME = SEC_IN_USEC;
mac_addr_t MAC_ADDRS[2] = {{0x00, 0x0c, 0x29, 0x5f, 0x29, 0xae}, {0x00, 0x0a, 0x35, 0x00, 0x00, 0x00}};
ip_addr_t IP_ADDRS[2] = {{0, 0, 0, 0}, {192, 168, 5, 1}};
udp_port_t UDP_PORTS[2] = {12345, 23456};
uint8_t PAYLOAD[BUFFER_SIZE];
size_t PAYLOAD_LENGTH = 0;
uint8_t PKTBUF[BUFFER_SIZE];
