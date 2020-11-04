#include <sys/socket.h>
#include <linux/if_packet.h>
#include <net/ethernet.h>
#include <netinet/ip.h>
#include <netinet/udp.h>
#include <arpa/inet.h>

#include <cstdio>
#include <cstdint>
#include <cstdlib>
#include <cstring>
#include <type_traits>

#include "config.hh"

int main () {
  int32_t sock_r = socket(AF_PACKET, SOCK_RAW, htons(ETH_P_ALL));
  if (sock_r < 0) {
    printf("Error in opening raw socket\n");
    return -1;
  }
  const char *opt = "ens37";
  const size_t optlen = strnlen(opt, BUFFER_SIZE);
  setsockopt(sock_r, SOL_SOCKET, SO_BINDTODEVICE, opt, optlen);

  uint8_t* buffer = new uint8_t[BUFFER_SIZE];
  sockaddr s_addr;
  size_t s_addr_len = sizeof(s_addr);

  while (true) {
    size_t pkt_size = recvfrom(sock_r, buffer, BUFFER_SIZE, 0,
                               &s_addr, reinterpret_cast<socklen_t*>(&s_addr_len));
    ethhdr *eth = reinterpret_cast<ethhdr*>(buffer);

    //if (ntohs(eth->h_proto) == 0x0000) {
      printf("%02X.%02X.%02X.%02X.%02X.%02X\n", eth->h_source[0], eth->h_source[1],
                                                eth->h_source[2], eth->h_source[3],
                                                eth->h_source[4], eth->h_source[5]);
    //}

  }

  delete [] buffer;

  return 0;
}
