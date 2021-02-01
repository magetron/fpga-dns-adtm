#pragma once
#include <cstdlib>
#include <cstdint>

static const size_t BUFFER_SIZE = 65536;

enum class e_ethertype : uint16_t {
  IPv4 = 0x0800
};

enum class e_ip_proto : uint8_t {
  TCP = 0x06,
  UDP = 0x11
};