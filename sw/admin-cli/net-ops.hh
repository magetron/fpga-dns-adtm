#pragma once

#include <ctime>
#include <cmath>

void initialise_network_randomiser () {
  srand((unsigned) time(0));
}

mac_addr_t random_mac () {
  mac_addr_t mac;
  do {
    for (size_t i = 0; i < 6; i++) mac.byte[i] = rand() % 256;
  } while (memcmp(&mac, &admin_dst_mac, sizeof(mac_addr_t)) == 0 ||
           memcmp(&mac, &probe_dst_mac, sizeof(mac_addr_t)) == 0);
  return mac;
}

ip_addr_t random_ip () {
  ip_addr_t ip;
  for (size_t i = 0; i < 4; i++) ip.num[i] = rand() % 256;
  return ip;
}

ip_addr_t random_local_ip () {
  ip_addr_t ip;
  ip.num[0] = 10;
  for (size_t i = 1; i < 4; i++) ip.num[i] = rand() % 256;
  return ip;
}

udp_port_t random_unused_port () {
  udp_port_t port;
  port.port = __bswap_16(rand() % 55536 + 10000);
  return port;
}
